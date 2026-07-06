#!/usr/bin/env python3
"""Block jj safety-bypass flags that prefix-based permission rules cannot see.

`--ignore-immutable` can appear after any jj subcommand, so neither Claude's
`Bash(prefix*)` deny patterns nor Codex execpolicy prefix rules can match it;
this PreToolUse hook inspects the full command string for both agents.

Defense-in-depth against careless invocations, not a sandbox: it scans every
pipeline segment where a `jj` token appears (wrappers such as `env`, `command`,
`xargs`, or variable assignments are therefore irrelevant) and recurses into
nested command strings (`bash -c '...'`), but deliberately obfuscated shell can
still evade it.
"""

from __future__ import annotations

import json
import re
import shlex
import sys
from typing import Any

BLOCKED_FLAGS = {"--ignore-immutable"}
# Options whose next token is a value jj will not parse as a flag.
VALUE_OPTIONS = {"-m", "--message"}
# Shell control operators, including forms glued to neighboring tokens.
OPERATOR_RE = re.compile(r"(?:&&|\|\||[;|&()\n])")
MAX_NESTING = 4


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


def explode_segments(tokens: list[str]) -> list[list[str]]:
    """Split a token stream into simple-command segments, honoring operators
    even when quoting glued them to a word (e.g. `true&&jj`)."""
    segments: list[list[str]] = [[]]
    for token in tokens:
        pieces = OPERATOR_RE.split(token)
        if len(pieces) == 1:
            segments[-1].append(token)
            continue
        for index, piece in enumerate(pieces):
            if index and segments[-1]:
                segments.append([])
            if piece:
                segments[-1].append(piece)
    return [segment for segment in segments if segment]


def scan_segment(segment: list[str]) -> str:
    """Return the blocked flag if this segment invokes jj with one.

    `jj` may sit anywhere in the segment (after `env`, assignments, `xargs`,
    ...). Tokens consumed as `-m`/`--message` values and anything after a bare
    `--` are not jj flags.
    """
    if "jj" not in segment:
        return ""
    index = segment.index("jj") + 1
    while index < len(segment):
        token = segment[index]
        if token == "--":
            break
        if token in VALUE_OPTIONS:
            index += 2
            continue
        if token.split("=", 1)[0] in BLOCKED_FLAGS:
            return token.split("=", 1)[0]
        index += 1
    return ""


def find_blocked(command: str, depth: int = 0) -> str:
    if depth > MAX_NESTING:
        return ""
    try:
        tokens = shlex.split(command, posix=True)
    except ValueError:
        # Unparseable quoting: fall back to whitespace tokens and keep scanning
        # rather than silently allowing.
        tokens = command.split()

    for segment in explode_segments(tokens):
        flag = scan_segment(segment)
        if flag:
            return flag

    # Nested command strings, e.g. `bash -c 'jj rebase --ignore-immutable'`.
    for token in tokens:
        if "jj" in token.split() and any(ch.isspace() for ch in token):
            flag = find_blocked(token, depth + 1)
            if flag:
                return flag
    return ""


def validate_command(command: str) -> int:
    flag = find_blocked(command)
    if flag:
        print(
            f"BLOCKED: `{flag}` bypasses jj's immutability protection and "
            "can rewrite pushed history. Never use it. If the rewrite is "
            "genuinely needed, ask the user to run it themselves.",
            file=sys.stderr,
        )
        return 2
    return 0


def main() -> int:
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
    if not command:
        return 0

    return validate_command(command)


if __name__ == "__main__":
    raise SystemExit(main())
