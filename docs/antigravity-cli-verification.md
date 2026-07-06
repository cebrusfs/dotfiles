# Antigravity CLI runtime verification

**Status: partially verified, 2026-10-08.** The installed CLI's help and model
catalog have been checked. Verified flags, version, and evidence live in the
[CLI reference](../config/agent/skills/agent-delegate/references/cli.md#antigravity-agy).

An Antigravity session still needs to verify these behaviors with a harmless
temporary workspace:

1. Run a non-interactive worker and confirm its filesystem boundary, including
   whether there is an enforced read-only mode and how unattended approvals work.
2. Capture and inspect structured final output, including schema validation.
3. Record a conversation ID and resume it; confirm the correct conversation
   continues without losing its context or changing its permissions.
4. Verify failure recovery and cleanup after interrupting a worker.

Do not infer these behaviors from flag names. Update the owning CLI reference
with observed results and remove this pending task only when all four are
verified. Dispatch authorization and repository maintenance rules still apply.
