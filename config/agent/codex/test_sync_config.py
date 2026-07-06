#!/usr/bin/env python3
"""Regression tests for migrating Codex defaults without losing local state."""

from __future__ import annotations

import importlib.util
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import tomllib
import unittest


SCRIPT = Path(__file__).with_name("sync-config.py")
SOURCE = Path(__file__).with_name("config.toml")
_spec = importlib.util.spec_from_file_location("sync_config", SCRIPT)
assert _spec and _spec.loader
sync = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(sync)

LOCAL_CONFIG = '''\
approval_policy = "never"
approvals_reviewer = "user"
sandbox_mode = "danger-full-access"
local_setting = "keep"

[features]
network_proxy = false
unrelated_feature = true

[sandbox_workspace_write]
network_access = true

[permissions.retired]
extends = ":read-only"

[projects."~/work"]
trust_level = "trusted"

[hooks.state]
fixture = "approved"

[mcp_servers.fixture]
command = "fixture-mcp"

[desktop]
notifications = false

[apps.fixture]
enabled = true

[plugins."fixture@example"]
enabled = true

[marketplaces.fixture]
source = "local"

[skills]
config = []

[shell_environment_policy.set]
LOCAL_SETTING = "keep"
'''


class ConfigSyncTests(unittest.TestCase):
    def setUp(self) -> None:
        self.temp = tempfile.TemporaryDirectory(prefix="codex-sync-")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.target = self.root / "config.toml"
        self.target.write_text(LOCAL_CONFIG, encoding="utf-8")

    def run_sync(self, *args: str, source: Path = SOURCE) -> subprocess.CompletedProcess:
        return subprocess.run(
            [
                sys.executable,
                str(SCRIPT),
                "--source", str(source),
                "--target", str(self.target),
                *args,
            ],
            env={**os.environ, "PYTHONDONTWRITEBYTECODE": "1"},
            capture_output=True,
            text=True,
            check=False,
        )

    def test_migration_preserves_local_state_and_is_idempotent(self) -> None:
        before = tomllib.loads(LOCAL_CONFIG)
        source = tomllib.loads(SOURCE.read_text(encoding="utf-8"))
        desired = sync.build_synced_config(SOURCE, self.target)
        after = tomllib.loads(desired)

        self.assertNotIn("sandbox_mode", after)
        self.assertNotIn("sandbox_workspace_write", after)
        self.assertEqual(after["default_permissions"], source["default_permissions"])
        self.assertEqual(after["approvals_reviewer"], source["approvals_reviewer"])
        self.assertEqual(after["permissions"], source["permissions"])
        self.assertEqual(after["features"]["network_proxy"], {"enabled": True})
        self.assertTrue(after["features"]["unrelated_feature"])

        for key in (
            "local_setting", "projects", "hooks", "mcp_servers", "desktop",
            "apps", "plugins", "marketplaces", "skills",
        ):
            with self.subTest(key=key):
                self.assertEqual(after[key], before[key])
        self.assertEqual(
            after["shell_environment_policy"]["set"],
            before["shell_environment_policy"]["set"],
        )

        self.target.write_text(desired, encoding="utf-8")
        self.assertEqual(sync.build_synced_config(SOURCE, self.target), desired)

    def test_migration_preserves_arrays_of_tables(self) -> None:
        local_arrays = '''\
[[skills.config]]
path = "~/skills/disabled/SKILL.md"
enabled = false

[[skills.config]]
path = "~/skills/enabled/SKILL.md"
enabled = true

[[hooks.PreToolUse]]
matcher = "Bash"

[[hooks.PreToolUse.hooks]]
type = "command"
command = "fixture-hook"
'''
        for prefix in (
            "",
            "[tui]\nstatus_line = []\n\n",
            "[features]\nnetwork_proxy = false\n\n",
        ):
            with self.subTest(prefix=prefix):
                local = prefix + local_arrays
                self.target.write_text(local, encoding="utf-8")
                before = tomllib.loads(local)
                desired = sync.build_synced_config(SOURCE, self.target)
                after = tomllib.loads(desired)
                for key in ("skills", "hooks"):
                    self.assertEqual(after.get(key), before[key])
                self.target.write_text(desired, encoding="utf-8")
                self.assertEqual(sync.build_synced_config(SOURCE, self.target), desired)

    def test_preview_and_check_do_not_write(self) -> None:
        before = self.target.read_bytes()
        for args, expected_status in (((), 0), (("--check",), 1)):
            with self.subTest(args=args):
                result = self.run_sync(*args)
                self.assertEqual(result.returncode, expected_status, result.stderr)
                self.assertIn("---", result.stdout)
                self.assertEqual(self.target.read_bytes(), before)
                self.assertEqual(list(self.root.iterdir()), [self.target])

    def test_apply_backs_up_once_and_then_checks_clean(self) -> None:
        result = self.run_sync("--apply")
        self.assertEqual(result.returncode, 0, result.stderr)
        backups = list(self.root.glob("config.toml.*.bak"))
        self.assertEqual(len(backups), 1)
        self.assertEqual(backups[0].read_text(encoding="utf-8"), LOCAL_CONFIG)
        applied = self.target.read_bytes()

        for args in (("--check",), ("--apply",)):
            result = self.run_sync(*args)
            self.assertEqual(result.returncode, 0, result.stderr)
            self.assertEqual(self.target.read_bytes(), applied)
            self.assertEqual(list(self.root.glob("config.toml.*.bak")), backups)

    def test_malformed_source_or_target_is_not_overwritten(self) -> None:
        for invalid in ("source", "target"):
            with self.subTest(invalid=invalid):
                source = self.root / "source.toml"
                source.write_text(SOURCE.read_text(encoding="utf-8"), encoding="utf-8")
                self.target.write_text(LOCAL_CONFIG, encoding="utf-8")
                path = source if invalid == "source" else self.target
                path.write_text("sandbox_mode = [\n", encoding="utf-8")
                before = self.target.read_bytes()
                result = self.run_sync("--apply", source=source)
                self.assertNotEqual(result.returncode, 0)
                self.assertEqual(self.target.read_bytes(), before)
                self.assertEqual(list(self.root.glob("*.bak")), [])


if __name__ == "__main__":
    unittest.main()
