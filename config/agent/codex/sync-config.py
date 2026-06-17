#!/usr/bin/env python3
"""Sync stable Codex config from the dotfiles template into local runtime config."""

from __future__ import annotations

import argparse
import datetime as dt
import difflib
import os
from pathlib import Path
import re
import shutil
import sys
import tomllib


TOP_LEVEL_KEYS = (
    "web_search",
    "model",
    "model_reasoning_effort",
    "approval_policy",
    "approvals_reviewer",
    "default_permissions",
)
LEGACY_TOP_LEVEL_KEYS = ("sandbox_mode",)
EXACT_SECTIONS = ("tui",)
SECTION_PREFIXES = ("permissions.",)
LEGACY_SECTIONS = ("sandbox_workspace_write",)

HEADER_RE = re.compile(r"^\s*\[([^\]]+)\]\s*(?:#.*)?$")
KEY_RE = re.compile(r"^\s*([A-Za-z0-9_-]+)\s*=")


def default_source() -> Path:
    return Path(__file__).resolve().parent / "config.toml"


def default_target() -> Path:
    codex_home = Path(os.environ.get("CODEX_HOME", Path.home() / ".codex"))
    return codex_home / "config.toml"


def load_lines(path: Path) -> list[str]:
    if not path.exists():
        return []
    return path.read_text(encoding="utf-8").splitlines(keepends=True)


def header_name(line: str) -> str | None:
    match = HEADER_RE.match(line)
    return match.group(1).strip() if match else None


def section_is_synced(name: str) -> bool:
    return (
        name in EXACT_SECTIONS
        or name in LEGACY_SECTIONS
        or any(name.startswith(prefix) for prefix in SECTION_PREFIXES)
    )


def remove_managed_preamble(lines: list[str]) -> None:
    while lines and (lines[-1].strip() == "" or lines[-1].lstrip().startswith("#")):
        lines.pop()


def source_top_level_lines(lines: list[str]) -> list[str]:
    found: dict[str, str] = {}
    in_top_level = True
    for line in lines:
        if header_name(line) is not None:
            in_top_level = False
        if not in_top_level:
            continue
        match = KEY_RE.match(line)
        if match and match.group(1) in TOP_LEVEL_KEYS:
            found[match.group(1)] = line
    return [found[key] for key in TOP_LEVEL_KEYS if key in found]


def source_sections(lines: list[str]) -> dict[str, list[str]]:
    sections: dict[str, list[str]] = {}
    index = 0
    while index < len(lines):
        name = header_name(lines[index])
        if name is None:
            index += 1
            continue

        should_sync = name in EXACT_SECTIONS or any(
            name.startswith(prefix) for prefix in SECTION_PREFIXES
        )
        end = index + 1
        while end < len(lines) and header_name(lines[end]) is None:
            end += 1

        if should_sync:
            start = index
            while start > 0:
                previous = lines[start - 1].strip()
                if previous == "" or previous.startswith("#"):
                    start -= 1
                    continue
                break
            sections[name] = lines[start:end]

        index = end
    return sections


def strip_synced_content(lines: list[str]) -> list[str]:
    output: list[str] = []
    in_top_level = True
    index = 0
    while index < len(lines):
        name = header_name(lines[index])
        if name is not None:
            in_top_level = False
            end = index + 1
            while end < len(lines) and header_name(lines[end]) is None:
                end += 1
            if section_is_synced(name):
                remove_managed_preamble(output)
                index = end
                continue
            output.extend(lines[index:end])
            index = end
            continue

        if in_top_level:
            match = KEY_RE.match(lines[index])
            if match and match.group(1) in (*TOP_LEVEL_KEYS, *LEGACY_TOP_LEVEL_KEYS):
                index += 1
                continue

        output.append(lines[index])
        index += 1
    return output


def trim_blank_edges(lines: list[str]) -> list[str]:
    start = 0
    end = len(lines)
    while start < end and lines[start].strip() == "":
        start += 1
    while end > start and lines[end - 1].strip() == "":
        end -= 1
    return lines[start:end]


def build_synced_config(source: Path, target: Path) -> str:
    source_lines = load_lines(source)
    if not source_lines:
        raise SystemExit(f"source config does not exist or is empty: {source}")

    source_text = "".join(source_lines)
    tomllib.loads(source_text)

    top_lines = source_top_level_lines(source_lines)
    sections = source_sections(source_lines)
    target_lines = load_lines(target)
    kept_lines = trim_blank_edges(strip_synced_content(target_lines))

    result: list[str] = []
    result.extend(top_lines)
    if kept_lines:
        result.append("\n")
        result.extend(kept_lines)
    if sections:
        result.append("\n")
        for block in sections.values():
            result.extend(trim_blank_edges(block))
            result.append("\n\n")

    text = "".join(result).rstrip() + "\n"
    tomllib.loads(text)
    return text


def write_with_backup(target: Path, text: str, backup: bool) -> None:
    target.parent.mkdir(parents=True, exist_ok=True)
    if backup and target.exists():
        stamp = dt.datetime.now().strftime("%Y%m%d-%H%M%S")
        backup_path = target.with_name(f"{target.name}.{stamp}.bak")
        shutil.copy2(target, backup_path)
        print(f"backup: {backup_path}")
    target.write_text(text, encoding="utf-8")


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Sync stable Codex config template sections into ~/.codex/config.toml."
    )
    parser.add_argument("--source", type=Path, default=default_source())
    parser.add_argument("--target", type=Path, default=default_target())
    parser.add_argument("--apply", action="store_true", help="write the synced config")
    parser.add_argument("--check", action="store_true", help="exit 1 if changes are needed")
    parser.add_argument("--no-backup", action="store_true", help="do not create a .bak file")
    args = parser.parse_args()

    desired = build_synced_config(args.source.expanduser(), args.target.expanduser())
    current = ""
    if args.target.expanduser().exists():
        current = args.target.expanduser().read_text(encoding="utf-8")

    if current == desired:
        print("Codex config is already in sync.")
        return 0

    diff = difflib.unified_diff(
        current.splitlines(keepends=True),
        desired.splitlines(keepends=True),
        fromfile=str(args.target),
        tofile=f"{args.target} (synced)",
    )
    sys.stdout.writelines(diff)

    if args.check:
        return 1
    if not args.apply:
        print("\ndry-run only; rerun with --apply to write.")
        return 0

    write_with_backup(args.target.expanduser(), desired, backup=not args.no_backup)
    print(f"synced: {args.target.expanduser()}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
