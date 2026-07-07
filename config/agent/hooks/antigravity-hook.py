#!/usr/bin/env python3
"""Run a shared Claude/Codex-format hook from an Antigravity (Jetski) plugin.

Antigravity hooks differ from Claude Code and Codex hooks where it matters here:
the payload is camelCase with the shell command under
`toolCall.args.CommandLine`; the command runs in the directory that holds the
plugin's hooks.json instead of the workspace; and the verdict is a JSON object
on stdout, where empty output means no opinion and a non-zero exit fails a
PreToolUse hook closed. This adapter translates the payload, runs the shared
hook from the workspace, and translates its verdict, so the shared hooks keep a
single format.

Usage: antigravity-hook.py <event> <hook>, where <event> is pre-tool-use or
stop and <hook> is a script path relative to this directory. Adapter errors
fail open, matching the Claude and Codex adapters, which skip the hooks when
python3 is missing.
"""

from __future__ import annotations

import json
import os
from pathlib import Path
import subprocess
import sys
from typing import Any, Callable

HOOKS_DIR = Path(__file__).resolve().parent
# Antigravity's default hook timeout is 30s; leave headroom for the adapter.
HOOK_TIMEOUT_SECONDS = 25


def hook_command(hook: str) -> list[str]:
    path = Path(hook)
    if not path.is_absolute():
        path = HOOKS_DIR / path
    if path.suffix == ".py":
        return [sys.executable, str(path)]
    return [str(path)]


def run_hook(hook: str, payload: dict[str, Any], cwd: str) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        hook_command(hook),
        input=json.dumps(payload),
        capture_output=True,
        text=True,
        cwd=cwd,
        timeout=HOOK_TIMEOUT_SECONDS,
        check=False,
    )


def first_workspace(data: dict[str, Any]) -> str | None:
    for path in data.get("workspacePaths") or []:
        if isinstance(path, str) and os.path.isdir(path):
            return path
    return None


def parse_object(text: str) -> dict[str, Any]:
    try:
        value = json.loads(text)
    except json.JSONDecodeError:
        return {}
    return value if isinstance(value, dict) else {}


def pre_tool_use(data: dict[str, Any], hook: str) -> dict[str, Any] | None:
    call = data.get("toolCall") or {}
    if call.get("name") != "run_command":
        return None
    args = call.get("args") or call.get("arguments") or {}
    command = args.get("CommandLine")
    if not isinstance(command, str) or not command.strip():
        return None
    cwd = args.get("Cwd")
    if not (isinstance(cwd, str) and os.path.isdir(cwd)):
        cwd = first_workspace(data) or os.getcwd()

    result = run_hook(
        hook,
        {
            "hook_event_name": "PreToolUse",
            "tool_name": "Bash",
            "tool_input": {"command": command},
            "cwd": cwd,
        },
        cwd,
    )
    # Shared PreToolUse hooks block with exit code 2 and explain on stderr.
    if result.returncode == 2:
        reason = result.stderr.strip() or f"Blocked by {Path(hook).name}."
        return {"decision": "deny", "reason": reason}
    return None


def stop(data: dict[str, Any], hook: str) -> dict[str, Any] | None:
    # Only nudge after a normal turn end, never after a cancel, error, or limit.
    if data.get("terminationReason") not in (None, "", "NO_TOOL_CALL"):
        return None
    cwd = first_workspace(data)
    if cwd is None:
        return None

    result = run_hook(
        hook,
        {"hook_event_name": "Stop", "stop_hook_active": False, "cwd": cwd},
        cwd,
    )
    verdict = parse_object(result.stdout)
    reason = verdict.get("reason")
    if verdict.get("decision") == "block" and isinstance(reason, str) and reason:
        return {"decision": "continue", "reason": reason}
    return None


HANDLERS: dict[str, Callable[[dict[str, Any], str], dict[str, Any] | None]] = {
    "pre-tool-use": pre_tool_use,
    "stop": stop,
}


def main(argv: list[str] | None = None) -> int:
    argv = sys.argv[1:] if argv is None else argv
    if len(argv) != 2 or argv[0] not in HANDLERS:
        print(f"usage: antigravity-hook.py {{{'|'.join(HANDLERS)}}} <hook>", file=sys.stderr)
        return 0
    try:
        data = json.load(sys.stdin)
        verdict = HANDLERS[argv[0]](data, argv[1]) if isinstance(data, dict) else None
    except Exception as error:  # noqa: BLE001 - a broken adapter must not block every tool call.
        print(f"antigravity-hook: {type(error).__name__}: {error}", file=sys.stderr)
        return 0
    if verdict:
        print(json.dumps(verdict, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
