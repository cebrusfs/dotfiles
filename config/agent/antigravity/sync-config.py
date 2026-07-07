#!/usr/bin/env python3
"""Sync stable Antigravity settings into the local runtime configs.

The Antigravity CLI gets every template key. Jetski, the internal Antigravity
build, shares the settings schema but keeps its own model and UI preferences,
so it only receives the shared `permissions` tiers, and only where it is
installed.
"""

from __future__ import annotations

import argparse
import difflib
import json
from pathlib import Path
import sys
from typing import Any, NamedTuple


class Target(NamedTuple):
    path: Path
    # Top-level template keys to sync; None syncs every key.
    keys: tuple[str, ...] | None
    # Optional targets are skipped when their settings file does not exist.
    optional: bool


def default_source() -> Path:
    return Path(__file__).resolve().parent / "settings.json"


def default_targets() -> list[Target]:
    gemini = Path.home() / ".gemini"
    return [
        Target(gemini / "antigravity-cli" / "settings.json", None, optional=False),
        Target(gemini / "jetski" / "cli" / "settings.json", ("permissions",), optional=True),
    ]


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


def build_synced_config(
    source: Path, target: Path, keys: tuple[str, ...] | None = None
) -> str:
    template = load_object(source)
    if keys is not None:
        template = {key: value for key, value in template.items() if key in keys}
    local = load_object(target, missing_ok=True)
    # Keep the client's own key order so a sync only shows managed changes.
    return json.dumps(merge_objects(local, template), ensure_ascii=False, indent=2) + "\n"


def sync_target(source: Path, target: Target, *, apply: bool) -> None:
    path = target.path.expanduser()
    if target.optional and not path.exists():
        print(f"skipped (not installed): {path}")
        return

    desired = build_synced_config(source, path, target.keys)
    current = path.read_text(encoding="utf-8") if path.exists() else ""
    replace_symlink = path.is_symlink()

    if current == desired and not replace_symlink:
        print(f"already in sync: {path}")
        return

    diff = difflib.unified_diff(
        current.splitlines(keepends=True),
        desired.splitlines(keepends=True),
        fromfile=str(path),
        tofile=f"{path} (synced)",
    )
    sys.stdout.writelines(diff)
    if replace_symlink:
        print(f"replace symlink with regular file: {path}")

    if not apply:
        print(f"dry-run only; rerun with --apply to write {path}.")
        return

    path.parent.mkdir(parents=True, exist_ok=True)
    if replace_symlink:
        path.unlink()
    path.write_text(desired, encoding="utf-8")
    print(f"synced: {path}")


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Sync stable Antigravity settings into the local runtime configs."
    )
    parser.add_argument("--source", type=Path, default=default_source())
    parser.add_argument(
        "--target",
        type=Path,
        help="sync one settings file instead of the default Antigravity CLI and Jetski targets",
    )
    parser.add_argument(
        "--key",
        action="append",
        help="with --target, sync only this top-level template key (repeatable)",
    )
    parser.add_argument("--apply", action="store_true", help="write the synced config")
    args = parser.parse_args()

    if args.key and not args.target:
        parser.error("--key requires --target")
    source = args.source.expanduser()
    if args.target:
        keys = tuple(args.key) if args.key else None
        targets = [Target(args.target, keys, optional=False)]
    else:
        targets = default_targets()

    for target in targets:
        sync_target(source, target, apply=args.apply)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
