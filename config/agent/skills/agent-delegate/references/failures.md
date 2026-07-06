# Failure and Escalation

Read only after a dispatch fails or shows the same understanding error again.
Missing/moved input is not a capability strike: fix the input and retry the
same tier once.

- Cheap worker fails once on understanding → escalate to mid immediately.
- Mid worker fails twice on the same subtask → escalate to strong with the full
  trail: attempts, exact errors, and ruled-out hypotheses.
- Strongest available worker fails twice → stop and ask the user. Never make a
  third attempt at the same tier; cheap never gets a second.
- The same counts bind the lead. A lead stuck twice recruits a stronger worker
  or asks instead of trying variation three.
- After a strong worker solves the hard instance, downgrade known-pattern batch
  application to cheap using the solved example.
