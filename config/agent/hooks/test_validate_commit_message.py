#!/usr/bin/env python3
"""Unit tests for the commit-message validator hook."""

from __future__ import annotations

import contextlib
import importlib.util
import io
import json
import os
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch


HOOK_DIR = Path(__file__).resolve().parent
DOTFILES_ROOT = Path(__file__).resolve().parents[3]
VALIDATOR = HOOK_DIR / "validate-commit-message.py"
CLAUDE_CONFIG = DOTFILES_ROOT / "config/agent/claude/settings.json"
CODEX_HOOKS = DOTFILES_ROOT / "config/agent/codex/hooks.json"

_SPEC = importlib.util.spec_from_file_location("validate_commit_message", VALIDATOR)
assert _SPEC and _SPEC.loader
validator = importlib.util.module_from_spec(_SPEC)
_SPEC.loader.exec_module(validator)


def hook_payload(command: str, *, tool: str = "Bash") -> dict[str, object]:
    return {
        "tool_name": tool,
        "tool_input": {"command": command},
    }


def invoke_main(payload: dict[str, object]) -> int:
    with (
        patch.dict(os.environ, {"AGENT_COMMIT_COMMAND": ""}, clear=False),
        patch.object(sys, "stdin", io.StringIO(json.dumps(payload))),
    ):
        return validator.main()


def check(command: str) -> int:
    with contextlib.redirect_stderr(io.StringIO()):
        return validator.validate_command(command)


def check_error(command: str) -> str:
    stderr = io.StringIO()
    with contextlib.redirect_stderr(stderr):
        validator.validate_command(command)
    return stderr.getvalue()


class HookFastPathTests(unittest.TestCase):
    def test_non_command_tool_skips_repo_lookup(self) -> None:
        with patch.object(validator, "current_repo_root") as repo_root:
            result = invoke_main(hook_payload("", tool="Read"))

        self.assertEqual(result, 0)
        repo_root.assert_not_called()

    def test_unrelated_command_skips_repo_lookup(self) -> None:
        payloads = (
            hook_payload("pwd"),
            {
                "tool": "run_command",
                "input": {"command": "rg -n 'jj describe' docs"},
            },
        )
        for payload in payloads:
            with self.subTest(payload=payload):
                with patch.object(validator, "current_repo_root") as repo_root:
                    result = invoke_main(payload)

                self.assertEqual(result, 0)
                repo_root.assert_not_called()

    def test_environment_command_fast_path_skips_repo_lookup(self) -> None:
        with (
            patch.dict(
                os.environ,
                {"AGENT_COMMIT_COMMAND": "pwd"},
                clear=False,
            ),
            patch.object(validator, "current_repo_root") as repo_root,
        ):
            result = validator.main()

        self.assertEqual(result, 0)
        repo_root.assert_not_called()

    def test_environment_command_defers_to_project_validator(self) -> None:
        with tempfile.TemporaryDirectory() as temporary_directory:
            root = Path(temporary_directory)
            marker = root / "config/agent/hooks/validate-commit-message.py"
            marker.parent.mkdir(parents=True)
            marker.write_text("# project validator\n", encoding="utf-8")

            with (
                patch.dict(
                    os.environ,
                    {
                        "AGENT_COMMIT_COMMAND": (
                            "jj commit -m 'fix: duplicate validation'"
                        )
                    },
                    clear=False,
                ),
                patch.object(validator, "current_repo_root", return_value=root),
                patch.object(validator, "validate_command") as validate_command,
            ):
                result = validator.main()

        self.assertEqual(result, 0)
        validate_command.assert_not_called()

    def test_project_validator_makes_global_copy_defer(self) -> None:
        with tempfile.TemporaryDirectory() as temporary_directory:
            root = Path(temporary_directory)
            marker = root / "config/agent/hooks/validate-commit-message.py"
            marker.parent.mkdir(parents=True)
            marker.write_text("# project validator\n", encoding="utf-8")

            with (
                patch.object(validator, "current_repo_root", return_value=root),
                patch.object(validator, "validate_command") as validate_command,
            ):
                result = invoke_main(
                    hook_payload("jj commit -m 'fix: duplicate validation'")
                )

        self.assertEqual(result, 0)
        validate_command.assert_not_called()


class MessageValidationTests(unittest.TestCase):
    def test_valid_inline_jj_messages_pass(self) -> None:
        for command in (
            "jj commit -m 'agent: validate commit message'",
            "jj describe -m 'agent: validate commit message'",
            "jj split . -m 'agent: validate commit message'",
            "jj new -m 'agent: validate commit message'",
            "jj squash -m 'agent: validate commit message'",
        ):
            with self.subTest(command=command):
                self.assertEqual(check(command), 0)

    def test_non_inline_message_sources_pass(self) -> None:
        for command in (
            "jj squash -u",
            "jj squash --use-destination-message",
            "jj describe --stdin",
            "jj describe --stdin < $TMPDIR/commit-message",
            "git commit -C HEAD",
            "git commit -CHEAD",
            "git commit --reuse-message=HEAD",
            "git commit --file=msg.txt",
            "git commit -F msg.txt",
            "git commit -F-",
            "git commit --no-edit --amend",
            "git commit --fixup=abc123",
        ):
            with self.subTest(command=command):
                self.assertEqual(check(command), 0)

    def test_format_violations_report_the_reason(self) -> None:
        cases = (
            ("jj commit -m 'missing component'", "first line must be"),
            (
                "jj commit -m 'server: "
                "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'",
                "first line is 73 chars",
            ),
            (
                "jj commit -m 'feat: conventional commit type'",
                "use a real component",
            ),
            (
                "jj commit -m 'agent: trailing period.'",
                "should not end with a period",
            ),
            (
                "jj commit -m 'agent: valid title\n\nGenerated with Claude'",
                "remove AI attribution trailers",
            ),
            (
                "jj commit -m 'agent: valid title\n\nCo-Authored-By: Bot <bot@example.com>'",
                "remove Co-Authored-By trailers",
            ),
        )
        for command, reason in cases:
            with self.subTest(command=command):
                self.assertIn(reason, check_error(command))

    def test_title_at_72_characters_passes(self) -> None:
        command = (
            "jj commit -m 'server: "
            "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'"
        )

        self.assertEqual(check(command), 0)

    def test_bare_squash_explains_the_safe_exception(self) -> None:
        error = check_error("jj squash")

        self.assertIn("jj squash: use -m '<component>: <title>'", error)
        self.assertIn(
            "-u only when discarding the source description is intended",
            error,
        )

    def test_unrelated_help_and_bare_new_commands_pass(self) -> None:
        for command in (
            "jj status",
            "git status",
            "jj new",
            "jj describe --help",
            "jj commit -h",
        ):
            with self.subTest(command=command):
                self.assertEqual(check(command), 0)


class AdapterTests(unittest.TestCase):
    def test_global_adapters_invoke_the_renamed_validator(self) -> None:
        expected_path = "$HOME/.dotfiles/config/agent/hooks/validate-commit-message.py"
        claude = json.loads(CLAUDE_CONFIG.read_text(encoding="utf-8"))
        codex = json.loads(CODEX_HOOKS.read_text(encoding="utf-8"))

        claude_command = claude["hooks"]["PreToolUse"][0]["hooks"][0]["command"]
        codex_command = codex["hooks"]["PreToolUse"][0]["hooks"][0]["command"]

        for command in (claude_command, codex_command):
            self.assertIn(expected_path, command)


if __name__ == "__main__":
    unittest.main()
