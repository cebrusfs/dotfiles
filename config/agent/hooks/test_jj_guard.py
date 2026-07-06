#!/usr/bin/env python3
"""Unit tests for the jj safety-flag guard hook."""

from __future__ import annotations

import contextlib
import importlib.util
import io
import unittest
from pathlib import Path

_spec = importlib.util.spec_from_file_location(
    "jj_guard",
    Path(__file__).with_name("jj-guard.py"),
)
assert _spec and _spec.loader
hook = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(hook)


def check(command: str) -> int:
    with contextlib.redirect_stderr(io.StringIO()):
        return hook.validate_command(command)


class BlocksIgnoreImmutable(unittest.TestCase):
    def test_flag_positions(self) -> None:
        for command in (
            "jj rebase -r abc -d main --ignore-immutable",
            "jj --ignore-immutable describe -m 'x: y' abc",
            "jj squash --ignore-immutable=true",
            "jj st && jj rebase --ignore-immutable -d main",
        ):
            with self.subTest(command=command):
                self.assertEqual(check(command), 2)

    def test_wrapper_prefixes(self) -> None:
        for command in (
            "env FOO=1 jj rebase --ignore-immutable -d main",
            "FOO=1 jj rebase --ignore-immutable -d main",
            "command jj rebase --ignore-immutable -d main",
            "timeout 5 jj rebase --ignore-immutable -d main",
            "xargs jj rebase --ignore-immutable",
        ):
            with self.subTest(command=command):
                self.assertEqual(check(command), 2)

    def test_glued_operators_and_subshells(self) -> None:
        for command in (
            "true&&jj rebase --ignore-immutable -d main",
            "echo ok;jj rebase --ignore-immutable -d main",
            "(jj rebase --ignore-immutable -d main)",
        ):
            with self.subTest(command=command):
                self.assertEqual(check(command), 2)

    def test_nested_shell(self) -> None:
        self.assertEqual(check("bash -c 'jj rebase --ignore-immutable -d main'"), 2)

    def test_help_is_not_an_exemption(self) -> None:
        for command in (
            "jj rebase --ignore-immutable --help",
            "jj describe -m '-h' --ignore-immutable",
            "jj describe -m x --ignore-immutable -h",
        ):
            with self.subTest(command=command):
                self.assertEqual(check(command), 2)


class AllowsSafeCommands(unittest.TestCase):
    def test_plain_jj_commands(self) -> None:
        for command in (
            "jj st",
            "jj rebase -r abc -d main",
            "jj describe -m 'core: title'",
            "jj rebase --help",
        ):
            with self.subTest(command=command):
                self.assertEqual(check(command), 0)

    def test_flag_as_message_value(self) -> None:
        for command in (
            "jj describe -m '--ignore-immutable'",
            "jj describe --message --ignore-immutable",
            "jj describe -m 'docs: note that --ignore-immutable is banned'",
        ):
            with self.subTest(command=command):
                self.assertEqual(check(command), 0)

    def test_flag_after_end_of_options(self) -> None:
        self.assertEqual(check("jj file show -- --ignore-immutable"), 0)

    def test_flag_in_non_jj_command(self) -> None:
        for command in (
            "rg -- --ignore-immutable config",
            "grep -r ignore-immutable docs/",
        ):
            with self.subTest(command=command):
                self.assertEqual(check(command), 0)

    def test_unparseable_command_without_flag(self) -> None:
        self.assertEqual(check("jj describe -m 'unclosed"), 0)

    def test_unparseable_command_with_flag_still_blocks(self) -> None:
        self.assertEqual(check("jj rebase --ignore-immutable -m 'unclosed"), 2)


if __name__ == "__main__":
    unittest.main()
