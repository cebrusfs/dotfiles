#!/usr/bin/env python3
"""Unit tests for fail-closed removal of Claude jj workspaces."""

from __future__ import annotations

import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

HOOK = Path(__file__).with_name("jj-workspace-remove.sh")


class WorkspaceRemove(unittest.TestCase):
    def setUp(self) -> None:
        self._tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self._tmp.cleanup)
        self.tmp = Path(self._tmp.name)
        self.workspace = self.tmp / ".claude" / "worktrees" / "worker"
        self.workspace.mkdir(parents=True)
        self.bin = self.tmp / "bin"
        self.bin.mkdir()
        self.calls = self.tmp / "jj-calls"
        fake_jj = self.bin / "jj"
        fake_jj.write_text(
            '#!/bin/sh\nprintf "%s\\n" "$@" > "$JJ_CALL_LOG"\n'
            'exit "$JJ_FORGET_STATUS"\n',
            encoding="utf-8",
        )
        fake_jj.chmod(0o755)

    def run_hook(
        self, path: Path | None = None, *, forget_status: int = 0
    ) -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            ["bash", str(HOOK)],
            input=json.dumps({"worktree_path": str(path or self.workspace)}),
            capture_output=True,
            text=True,
            env={
                **os.environ,
                "PATH": str(self.bin) + os.pathsep + os.environ["PATH"],
                "JJ_CALL_LOG": str(self.calls),
                "JJ_FORGET_STATUS": str(forget_status),
            },
        )

    def test_forget_success_removes_directory(self) -> None:
        (self.workspace / ".jj").mkdir()
        result = self.run_hook()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(self.workspace.exists())
        self.assertEqual(
            self.calls.read_text(encoding="utf-8").splitlines(),
            ["-R", str(self.workspace), "workspace", "forget"],
        )

    def test_forget_failure_keeps_directory(self) -> None:
        (self.workspace / ".jj").mkdir()
        result = self.run_hook(forget_status=1)
        self.assertEqual(result.returncode, 1)
        self.assertTrue((self.workspace / ".jj").is_dir())
        self.assertIn(
            f"jj workspace forget failed; keeping {self.workspace}",
            result.stderr,
        )
        self.assertTrue(self.calls.exists())

    def test_directory_without_jj_is_removed_without_calling_jj(self) -> None:
        result = self.run_hook(forget_status=1)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse(self.workspace.exists())
        self.assertFalse(self.calls.exists())

    def test_path_outside_claude_worktrees_is_refused(self) -> None:
        outside = self.tmp / "outside"
        (outside / ".jj").mkdir(parents=True)
        result = self.run_hook(outside)
        self.assertEqual(result.returncode, 1)
        self.assertTrue(outside.is_dir())
        self.assertIn("refusing to remove non-Claude jj workspace path", result.stderr)
        self.assertFalse(self.calls.exists())


if __name__ == "__main__":
    unittest.main()
