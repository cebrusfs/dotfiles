#!/usr/bin/env python3
"""Unit tests for the Antigravity (Jetski) hook adapter."""

from __future__ import annotations

import contextlib
import importlib.util
import io
import json
import tempfile
import textwrap
import unittest
from unittest import mock
from pathlib import Path

_spec = importlib.util.spec_from_file_location(
    "antigravity_hook",
    Path(__file__).with_name("antigravity-hook.py"),
)
assert _spec and _spec.loader
adapter = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(adapter)


def run_main(argv: list[str], stdin: str) -> tuple[int, str]:
    out = io.StringIO()
    with contextlib.redirect_stdout(out), contextlib.redirect_stderr(io.StringIO()):
        with mock.patch("sys.stdin", io.StringIO(stdin)):
            code = adapter.main(argv)
    return code, out.getvalue()


def tool_call(command: str, workspace: str, **args: str) -> dict:
    return {
        "toolCall": {"name": "run_command", "args": {"CommandLine": command, **args}},
        "workspacePaths": [workspace],
    }


class AdapterTestCase(unittest.TestCase):
    def setUp(self) -> None:
        self._tmp = tempfile.TemporaryDirectory()
        self.tmp = Path(self._tmp.name)
        self.workspace = self.tmp / "workspace"
        self.workspace.mkdir()

    def tearDown(self) -> None:
        self._tmp.cleanup()

    def fake_hook(self, body: str) -> str:
        """Write a Python hook that reads the payload into `data`, then runs body."""
        path = self.tmp / f"hook_{len(list(self.tmp.iterdir()))}.py"
        path.write_text(
            "import json, os, sys\ndata = json.load(sys.stdin)\n" + textwrap.dedent(body),
            encoding="utf-8",
        )
        return str(path)


class PreToolUse(AdapterTestCase):
    def test_real_jj_guard_denies_ignore_immutable(self) -> None:
        verdict = adapter.pre_tool_use(
            tool_call("jj rebase -d main --ignore-immutable", str(self.workspace)),
            "jj-guard.py",
        )
        self.assertEqual(verdict["decision"], "deny")
        self.assertIn("--ignore-immutable", verdict["reason"])

    def test_real_jj_guard_allows_routine_command(self) -> None:
        self.assertIsNone(
            adapter.pre_tool_use(tool_call("jj st", str(self.workspace)), "jj-guard.py")
        )

    def test_translates_payload_and_runs_in_workspace(self) -> None:
        hook = self.fake_hook(
            """
            assert data["tool_name"] == "Bash"
            print(data["tool_input"]["command"] + "@" + os.getcwd(), file=sys.stderr)
            sys.exit(2)
            """
        )
        verdict = adapter.pre_tool_use(tool_call("ls -la", str(self.workspace)), hook)
        self.assertEqual(
            verdict, {"decision": "deny", "reason": f"ls -la@{self.workspace.resolve()}"}
        )

    def test_prefers_the_tool_call_cwd(self) -> None:
        other = self.tmp / "other"
        other.mkdir()
        hook = self.fake_hook("print(os.getcwd(), file=sys.stderr); sys.exit(2)")
        verdict = adapter.pre_tool_use(
            tool_call("ls", str(self.workspace), Cwd=str(other)), hook
        )
        self.assertEqual(verdict["reason"], str(other.resolve()))

    def test_accepts_arguments_key(self) -> None:
        hook = self.fake_hook("sys.exit(2)")
        data = {
            "toolCall": {"name": "run_command", "arguments": {"CommandLine": "ls"}},
            "workspacePaths": [str(self.workspace)],
        }
        self.assertEqual(adapter.pre_tool_use(data, hook)["decision"], "deny")

    def test_other_exit_codes_are_no_opinion(self) -> None:
        for code in (0, 1):
            with self.subTest(code=code):
                hook = self.fake_hook(f"sys.exit({code})")
                self.assertIsNone(
                    adapter.pre_tool_use(tool_call("ls", str(self.workspace)), hook)
                )

    def test_skips_other_tools_and_empty_commands(self) -> None:
        marker = self.tmp / "ran"
        hook = self.fake_hook(f"open({str(marker)!r}, 'w').close(); sys.exit(2)")
        view = {"toolCall": {"name": "view_file", "args": {"AbsolutePath": "/x"}}}
        self.assertIsNone(adapter.pre_tool_use(view, hook))
        self.assertIsNone(adapter.pre_tool_use(tool_call("  ", str(self.workspace)), hook))
        self.assertFalse(marker.exists())


class Stop(AdapterTestCase):
    def stop_payload(self, **fields: object) -> dict:
        return {"workspacePaths": [str(self.workspace)], **fields}

    def test_block_becomes_continue(self) -> None:
        hook = self.fake_hook(
            """
            assert data["stop_hook_active"] is False
            print(json.dumps({"decision": "block", "reason": "commit " + os.getcwd()}))
            """
        )
        verdict = adapter.stop(self.stop_payload(terminationReason="NO_TOOL_CALL"), hook)
        self.assertEqual(
            verdict, {"decision": "continue", "reason": f"commit {self.workspace.resolve()}"}
        )

    def test_silent_hook_lets_the_turn_end(self) -> None:
        self.assertIsNone(adapter.stop(self.stop_payload(), self.fake_hook("pass")))

    def test_skips_abnormal_termination_and_missing_workspace(self) -> None:
        marker = self.tmp / "ran"
        hook = self.fake_hook(f"open({str(marker)!r}, 'w').close()")
        cancelled = self.stop_payload(terminationReason="USER_CANCELED")
        self.assertIsNone(adapter.stop(cancelled, hook))
        self.assertIsNone(adapter.stop({"workspacePaths": []}, hook))
        self.assertFalse(marker.exists())


class Main(AdapterTestCase):
    def test_prints_the_verdict_as_json(self) -> None:
        hook = self.fake_hook("print('no', file=sys.stderr); sys.exit(2)")
        code, out = run_main(
            ["pre-tool-use", hook], json.dumps(tool_call("ls", str(self.workspace)))
        )
        self.assertEqual(code, 0)
        self.assertEqual(json.loads(out), {"decision": "deny", "reason": "no"})

    def test_fails_open(self) -> None:
        cases = {
            "invalid JSON": (["pre-tool-use", "jj-guard.py"], "not json"),
            "missing hook": (
                ["pre-tool-use", str(self.tmp / "missing.sh")],
                json.dumps(tool_call("ls", str(self.workspace))),
            ),
            "bad usage": (["nope"], "{}"),
        }
        for name, (argv, stdin) in cases.items():
            with self.subTest(name):
                self.assertEqual(run_main(argv, stdin), (0, ""))


if __name__ == "__main__":
    unittest.main()
