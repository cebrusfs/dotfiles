#!/usr/bin/env python3
"""Sync stable Antigravity CLI settings into its local runtime config."""

from __future__ import annotations

import argparse
import difflib
import json
from pathlib import Path
import sys
from typing import Any


def default_source() -> Path:
    return Path(__file__).resolve().parent / "settings.json"


def default_target() -> Path:
    return Path.home() / ".gemini" / "antigravity-cli" / "settings.json"


def load_object(path: Path, *, missing_ok: bool = False) -> dict[str, Any]:
    if missing_ok and not path.exists():
        return {}
    try:
        value = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        raise SystemExit(f"cannot read JSON object from {path}: {error}") from error
    if not isinstance(value, dict):
        raise SystemExit(f"expected a JSON object in {path}")
    return value


def merge_objects(
    local: dict[str, Any], template: dict[str, Any]
) -> dict[str, Any]:
    merged = dict(local)
    for key, template_value in template.items():
        local_value = merged.get(key)
        if isinstance(local_value, dict) and isinstance(template_value, dict):
            merged[key] = merge_objects(local_value, template_value)
        else:
            merged[key] = template_value
    return merged


def build_synced_config(source: Path, target: Path) -> str:
    template = load_object(source)
    local = load_object(target, missing_ok=True)
    return json.dumps(
        merge_objects(local, template), ensure_ascii=False, indent=2, sort_keys=True
    ) + "\n"


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Sync stable Antigravity CLI settings into its runtime config."
    )
    parser.add_argument("--source", type=Path, default=default_source())
    parser.add_argument("--target", type=Path, default=default_target())
    parser.add_argument("--apply", action="store_true", help="write the synced config")
    args = parser.parse_args()

    source = args.source.expanduser()
    target = args.target.expanduser()
    desired = build_synced_config(source, target)
    current = target.read_text(encoding="utf-8") if target.exists() else ""
    replace_symlink = target.is_symlink()

    if current == desired and not replace_symlink:
        print("Antigravity CLI config is already in sync.")
        return 0

    diff = difflib.unified_diff(
        current.splitlines(keepends=True),
        desired.splitlines(keepends=True),
        fromfile=str(target),
        tofile=f"{target} (synced)",
    )
    sys.stdout.writelines(diff)
    if replace_symlink:
        print(f"replace symlink with regular file: {target}")

    if not args.apply:
        print("\ndry-run only; rerun with --apply to write.")
        return 0

    target.parent.mkdir(parents=True, exist_ok=True)
    if replace_symlink:
        target.unlink()
    target.write_text(desired, encoding="utf-8")
    print(f"synced: {target}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
