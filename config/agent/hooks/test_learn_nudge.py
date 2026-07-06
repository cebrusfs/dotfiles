#!/usr/bin/env python3
"""Unit tests for the shared correction and preference reminder."""

from __future__ import annotations

import json
from pathlib import Path
import subprocess
import unittest

HOOK = Path(__file__).with_name("learn-nudge.sh")


def run_prompt(prompt: str, **fields: object) -> str:
    payload = {
        "hook_event_name": "UserPromptSubmit",
        "prompt": prompt,
        **fields,
    }
    result = subprocess.run(
        ["bash", str(HOOK)],
        input=json.dumps(payload),
        capture_output=True,
        text=True,
        check=True,
    )
    return result.stdout


class LearnNudge(unittest.TestCase):
    def test_human_corrections_keep_the_shared_output_shape(self) -> None:
        for fields in (
            {"session_id": "claude-test", "permission_mode": "default"},
            {"session_id": "codex-test", "turn_id": "turn-test"},
        ):
            for prompt in ("Use bun instead.", "從現在開始用 bun"):
                with self.subTest(fields=fields, prompt=prompt):
                    output = json.loads(run_prompt(prompt, **fields))
                    context = output["hookSpecificOutput"]
                    self.assertEqual(context["hookEventName"], "UserPromptSubmit")
                    self.assertIn("learn skill", context["additionalContext"])

    def test_notification_wrappers_skip_report_prose(self) -> None:
        reports = (
            '<teammate-message teammate_id="reviewer">'
            "Use bun instead.</teammate-message>",
            "<system-reminder>\n<task-notification>"
            "Do not repeat this.</task-notification>\n</system-reminder>",
            '<subagent_notification>{"status": "wrong approach"}'
            "</subagent_notification>",
            '<agent-message from="reviewer">'
            "Use bun instead.</agent-message>",
            "[Subagent hand-back]\nUse bun instead.",
            '<agent-message from="reviewer">\n[Subagent hand-back]\n'
            "Do not repeat this.</agent-message>",
            "[SYSTEM NOTIFICATION - NOT USER INPUT]\nUse bun instead.",
            "[MESSAGE FROM NON-USER SOURCE - NOT USER INPUT]\nRemember this.",
        )
        for report in reports:
            with self.subTest(report=report):
                self.assertEqual(run_prompt(report), "")

    def test_quoted_wrapper_conservatively_skips_the_reminder(self) -> None:
        prompt = (
            "Use bun instead.\n"
            "<teammate-message>Quoted report.</teammate-message>"
        )
        self.assertEqual(run_prompt(prompt), "")

    def test_similar_words_without_a_wrapper_still_nudge(self) -> None:
        self.assertNotEqual(
            run_prompt("The task-notification parser is wrong."), ""
        )

    def test_ordinary_and_empty_prompts_stay_silent(self) -> None:
        for prompt in ("", "Continue the review.", "preferred override"):
            with self.subTest(prompt=prompt):
                self.assertEqual(run_prompt(prompt), "")


if __name__ == "__main__":
    unittest.main()
