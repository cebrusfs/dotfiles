#!/usr/bin/env python3
"""Validate direct commit-message commands from agent PreToolUse hooks."""

from __future__ import annotations

import json
import os
import re
import shlex
import subprocess
import sys
from pathlib import Path
from typing import Any


DISALLOWED_COMPONENTS = {"feat", "fix", "chore", "refactor", "perf", "revert"}
MESSAGE_COMMANDS = {
    ("jj", "describe"),
    ("jj", "commit"),
    ("jj", "split"),
    ("jj", "new"),
    ("jj", "squash"),
    ("git", "commit"),
}

# Flags that supply or derive the commit message without opening an editor, so
# the '<component>: <title>' text is intentionally absent from the command line.
# Scoped per subcommand because each command exposes a different flag set (e.g.
# -u is jj squash, --stdin is jj describe, -C/-F are git commit).
NONINTERACTIVE_MESSAGE_FLAGS: dict[str, set[str]] = {
    "jj squash": {"-u", "--use-destination-message"},
    "jj describe": {"--stdin"},
    "jj new": {"--no-edit"},
    "git commit": {
        "-C",
        "--reuse-message",
        "-F",
        "--file",
        "--no-edit",
        "--fixup",
        "--squash",
    },
}

# Short flags that carry an inline value, e.g. -CHEAD or -Ffile.
VALUE_SHORT_FLAGS = {"-C", "-F"}
HELP_FLAGS = {"-h", "--help"}


def hook_string(data: dict[str, Any], *paths: tuple[str, ...]) -> str:
    for path in paths:
        value: Any = data
        for key in path:
            if not isinstance(value, dict):
                value = None
                break
            value = value.get(key)
        if isinstance(value, str) and value:
            return value
    return ""


def current_repo_root() -> Path | None:
    for command in (["jj", "root"], ["git", "rev-parse", "--show-toplevel"]):
        result = subprocess.run(
            command,
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
            text=True,
            check=False,
        )
        if result.returncode == 0 and result.stdout.strip():
            return Path(result.stdout.strip())
    return None


def project_owns_commit_style(root: Path | None) -> bool:
    if root is None:
        return False
    script_path = Path(__file__).resolve()
    markers = [
        root / "config/agent/hooks/validate-commit-message.py",
        root / ".agents/validate-commit-message-ignore",
        root / ".claude/validate-commit-message-ignore",
    ]
    for marker in markers:
        if not marker.exists():
            continue
        if marker.suffix == ".py" and marker.resolve() == script_path:
            continue
        return True
    return False


def is_google3(root: Path | None) -> bool:
    if not root:
        return False
    parts = str(root).split(os.sep)
    return "google3" in parts


def split_segments(command: str) -> list[list[str]]:
    try:
        tokens = shlex.split(command, posix=True)
    except ValueError:
        return []

    separators = {"&&", "||", ";", "|"}
    segments: list[list[str]] = []
    current: list[str] = []
    for token in tokens:
        if token in separators:
            if current:
                segments.append(current)
                current = []
        else:
            current.append(token)
    if current:
        segments.append(current)
    return segments


def has_noninteractive_message(segment: list[str], kind: str) -> bool:
    allowed = NONINTERACTIVE_MESSAGE_FLAGS.get(kind)
    if not allowed:
        return False
    for token in segment:
        if token in allowed:
            return True
        if token.startswith("--") and token.split("=", 1)[0] in allowed:
            return True
        if len(token) > 2 and token[:2] in VALUE_SHORT_FLAGS and token[:2] in allowed:
            return True
    return False


def is_help_request(segment: list[str]) -> bool:
    return any(token in HELP_FLAGS for token in segment)


def command_kind(segment: list[str]) -> str:
    if len(segment) >= 2 and (segment[0], segment[1]) in MESSAGE_COMMANDS:
        return f"{segment[0]} {segment[1]}"
    return ""


def has_message_command(command: str) -> bool:
    return any(command_kind(segment) for segment in split_segments(command))


def extract_messages(segment: list[str], errors: list[str]) -> list[str]:
    messages: list[str] = []
    idx = 0
    while idx < len(segment):
        token = segment[idx]
        if token in {"-m", "--message"}:
            if idx + 1 < len(segment):
                messages.append(segment[idx + 1])
                idx += 2
                continue
            errors.append("message flag is missing its value")
        elif token.startswith("--message="):
            messages.append(token.split("=", 1)[1])
        elif token.startswith("-m") and len(token) > 2:
            messages.append(token[2:])
        elif token.startswith("-") and not token.startswith("--") and "m" in token[1:]:
            if idx + 1 < len(segment):
                messages.append(segment[idx + 1])
                idx += 2
                continue
            errors.append("message flag is missing its value")
        idx += 1
    return messages


def validate_message(
    message: str, kind: str, errors: list[str], root: Path | None
) -> None:
    normalized = message.replace("\r\n", "\n").replace("\r", "\n").strip()
    if not normalized:
        errors.append(f"{kind}: commit message is empty")
        return

    if re.search(r"(?im)^Co-Authored-By:", normalized):
        errors.append(f"{kind}: remove Co-Authored-By trailers")
    if re.search(r"(?i)Generated with (Claude|Codex|Jetski)", normalized):
        errors.append(f"{kind}: remove AI attribution trailers")

    body = normalized.partition("\n")[2]
    if re.search(
        r"(?im)^[ \t]*(?:claude|codex|gemini|antigravity|jetski|cursor|copilot|ai|agent)"
        r"[-_][a-z0-9][a-z0-9_-]*[ \t]*:",
        body,
    ) or re.search(r"(?i)https?://claude\.ai/code/session[_/][a-z0-9_-]+", body):
        errors.append(f"{kind}: remove agent metadata from the commit message")

    title_line = normalized.split("\n", 1)[0]

    if title_line == "fixup":
        return

    if not is_google3(root):
        match = re.match(
            r"^([a-z0-9][a-z0-9_-]*(?:\([a-z0-9_-]+\))?): (.+)$", title_line
        )
        if not match:
            errors.append(f"{kind}: first line must be '<component>: <title>'")
            return

        component, _title = match.groups()
        bare_component = component.split("(", 1)[0]
        if bare_component in DISALLOWED_COMPONENTS:
            errors.append(
                f"{kind}: use a real component, not conventional type '{bare_component}:'"
            )

    if len(title_line) > 72:
        errors.append(f"{kind}: first line is {len(title_line)} chars; keep it <= 72")
    if title_line.endswith("."):
        errors.append(f"{kind}: first line should not end with a period")


def print_failure(errors: list[str]) -> None:
    print("BLOCKED: invalid commit message.", file=sys.stderr)
    print("", file=sys.stderr)
    for error in errors:
        print(f"- {error}", file=sys.stderr)
    print(
        """
Use:
  core: tighten commit validation
  docs: clarify setup steps
  agent: share hook scripts

Avoid:
  feat: tighten commit validation
  chore: update hooks

Body:
  Use short, unlabeled paragraphs: first any missing what or behavior, then
  why (the reason, constraint, or trade-off). Add risk, verification, or
  rollout detail only when it informs a future decision. Do not repeat the
  title or diff.
""".rstrip(),
        file=sys.stderr,
    )


def validate_command(command: str, root: Path | None = None) -> int:
    errors: list[str] = []
    message_commands: list[str] = []
    for segment in split_segments(command):
        kind = command_kind(segment)
        if not kind:
            continue
        if is_help_request(segment):
            continue

        messages = extract_messages(segment, errors)
        if kind == "jj new" and not messages:
            continue

        message_commands.append(kind)
        if not messages:
            if has_noninteractive_message(segment, kind):
                continue
            if kind == "jj squash":
                errors.append(
                    f"{kind}: use -m '<component>: <title>', or -u only when "
                    "discarding the source description is intended"
                )
            else:
                errors.append(
                    f"{kind}: use -m '<component>: <title>' instead of an editor"
                )
            continue

        validate_message("\n\n".join(messages), kind, errors, root)

    if not message_commands:
        return 0
    if errors:
        print_failure(errors)
        return 2
    return 0


def main() -> int:
    command = os.environ.get("AGENT_COMMIT_COMMAND", "")
    if command:
        if not has_message_command(command):
            return 0
        root = current_repo_root()
        if project_owns_commit_style(root):
            return 0
        return validate_command(command, root)

    try:
        data = json.load(sys.stdin)
    except json.JSONDecodeError:
        return 0

    tool = hook_string(
        data,
        ("tool_name",),
        ("tool",),
        ("toolName",),
        ("tool_call", "tool_name"),
        ("toolCall", "name"),
        ("name",),
    )
    if tool not in ("Bash", "run_command"):
        return 0

    command = hook_string(
        data,
        ("tool_input", "command"),
        ("input", "command"),
        ("arguments", "command"),
        ("tool_call", "input", "command"),
        ("toolCall", "arguments", "CommandLine"),
        ("arguments", "CommandLine"),
    )
    if not command or not has_message_command(command):
        return 0

    root = current_repo_root()
    if project_owns_commit_style(root):
        return 0

    return validate_command(command, root)


if __name__ == "__main__":
    raise SystemExit(main())
