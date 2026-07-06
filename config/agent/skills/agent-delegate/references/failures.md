# Failure Handling

Diagnose what failed before choosing another attempt.

- Missing or moved input: repair the input and retry when that addresses the
  observed cause.
- Misunderstanding despite sufficient evidence: improve the decomposition or
  use a more capable worker, carrying the failed attempts and ruled-out causes.
- Repeating the same failure without new evidence: change approach rather than
  spending a fixed retry allowance.
- An unresolved requirement or authority boundary: return the concrete decision
  to the root or user.
- Once the hard part is solved, route remaining known-pattern work using
  [models.md](models.md).

Retries should be proportionate to the likely gain and the consequences of
repeating the action. Check partial effects before retrying writable work.
