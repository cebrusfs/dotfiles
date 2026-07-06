# Failure and Escalation

Read after a dispatch fails, or when the same understanding error appears again.

One distinction decides everything else: a **missing or moved input** is not a
capability failure — fix the input and retry the same tier. A worker that had
the relevant facts in view and still reasoned wrong will reason wrong again at
that tier, so re-prompting it is the expensive mistake.

- Cheap worker, one understanding failure → move up a tier now.
- Mid worker, twice on the same subtask → strong worker, handed the trail:
  attempts, exact errors, and ruled-out hypotheses.
- Strongest available worker, twice → the approach is wrong, not the model.
  Change the decomposition or ask the user; a third identical attempt is thrash.
- The same reasoning binds the lead. Stuck twice means recruit a stronger worker
  or ask — not try variation three.
- Once a strong worker has solved the hard instance, the rest of the batch is
  known-pattern work: hand it to the cheapest tier with the solved example.

The counts are where the evidence points, not a quota to spend. Escalate
earlier when the failure already shows the tier cannot hold the problem.
