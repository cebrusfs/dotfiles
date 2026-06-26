#!/usr/bin/env python3
"""Unit tests for the commit-message style validator hook."""

from __future__ import annotations

import contextlib
import importlib.util
import io
import unittest
from pathlib import Path

_spec = importlib.util.spec_from_file_location(
    "commit_message_check",
    Path(__file__).with_name("commit-message-check.py"),
)
assert _spec and _spec.loader
hook = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(hook)


def check(command: str) -> int:
    # The validator prints failures to stderr; swallow it so expected-block cases
    # stay quiet.
    with contextlib.redirect_stderr(io.StringIO()):
        return hook.validate_command(command)


class NonInteractiveFlags(unittest.TestCase):
    def test_message_source_flags_pass(self) -> None:
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

    def test_flags_are_not_shared_across_subcommands(self) -> None:
        # --stdin belongs to jj describe, not jj squash; -u belongs to jj squash,
        # not git commit. Using them on the wrong subcommand must still block.
        for command in (
            "jj squash --stdin",
            "git commit -u",
            "jj describe -u",
        ):
            with self.subTest(command=command):
                self.assertEqual(check(command), 2)


class InteractiveStillBlocked(unittest.TestCase):
    def test_bare_message_commands_block(self) -> None:
        for command in ("jj squash", "jj commit", "jj describe", "git commit"):
            with self.subTest(command=command):
                self.assertEqual(check(command), 2)


class MessageValidation(unittest.TestCase):
    def test_valid_message_passes(self) -> None:
        self.assertEqual(check('jj commit -m "vim: tidy config"'), 0)

    def test_format_violations_block(self) -> None:
        for command in (
            'jj commit -m "no component here"',
            'jj commit -m "vim: trailing period."',
            'jj commit -m "feat: conventional type"',
            'jj commit -m ""',
        ):
            with self.subTest(command=command):
                self.assertEqual(check(command), 2)

    def test_title_limit_counts_full_first_line(self) -> None:
        self.assertEqual(
            check(
                'jj commit -m "server: '
                'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"'
            ),
            0,
        )
        self.assertEqual(
            check(
                'jj commit -m "server: '
                'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"'
            ),
            2,
        )


class NonMessageCommandsIgnored(unittest.TestCase):
    def test_unrelated_commands_pass(self) -> None:
        for command in ("jj status", "git status", "jj new", "ls -la"):
            with self.subTest(command=command):
                self.assertEqual(check(command), 0)

    def test_help_requests_pass(self) -> None:
        for command in (
            "jj describe --help",
            "jj describe -h",
            "jj commit --help",
            "jj squash --help",
            "git commit --help",
        ):
            with self.subTest(command=command):
                self.assertEqual(check(command), 0)


if __name__ == "__main__":
    unittest.main()
