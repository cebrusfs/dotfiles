# Judgment Rubrics

Canonical rubrics for the calls that are easiest to get wrong under pressure.
Each gives the signal, the action, one positive example (act) and one negative
(don't). Triggers are summarized in `global.md` (Judgment section); the
escalation ladder mechanics live in the `agent-delegate` skill's `routing.md`.

## 1. When to escalate model

Signal: the failure is about *understanding*, not information — you have the
relevant facts in view and still produced a wrong or incoherent step. Counts
per the ladder: cheap model once, mid model twice on the same subtask.

- Act: a sonnet-tier worker twice produced a patch that type-checks but
  misreads the invariant the function maintains → escalate with the failure
  trail; the misreading will repeat.
- Don't: the attempt failed because a fixture path moved → that is missing
  information, not capability; fix the input and retry at the same tier.

## 2. When it is actually done

Signal: every stated acceptance criterion has evidence — command output,
fresh-context read-back, or an observed behavior. Before declaring done,
re-read the original request; long sessions silently drop criteria.

- Act: "checks pass" backed by a `mise run check` run in this session ending
  in success → claim done, cite the output.
- Don't: "the edit looks correct and should pass CI" → that is the author's
  impression. Run the check, or say plainly that it was not run.

## 3. When to stop and ask the user

Signal: two readings of the instruction lead to materially different work; or
the next action is irreversible / outward-facing (publish, send, delete
history) and was not explicitly requested; or the acceptance criteria cannot
be verified as stated.

- Act: "clean up the old configs" could mean delete files or deprecate
  in-place, and the wrong guess destroys data → ask, with both readings and a
  recommendation.
- Don't: "fix the typo in the README" — one reading, reversible, verifiable →
  asking is friction, just do it.

## 4. Wrong-direction signals — change approach, don't retry

Signal: the same class of error twice in a row; fixes that keep growing in
scope ("just one more special case"); progress requires assuming a tool or API
behaves differently than observed; or you can no longer state in one sentence
why the current step serves the goal.

- Act: second attempt at mocking a library still fights its internals → stop,
  question the approach (maybe test against the real thing), don't write
  mock number three.
- Don't: a flaky network fetch failed once → same approach, one retry is fine;
  changing strategy after a single transient error is thrash.

## 5. Quality floor — how to verify the minimum bar

Signal: work is about to be claimed as a deliverable. The floor: acceptance
criteria evidenced (rubric 2); relevant checks run (`mise run check` or the
project's equivalent); files verified by fresh read-back, code by tests or a
real run; verification done by fresh context, not the author (see
`routing.md`); no invented names, flags, versions, or model ids — each is
verified or labeled unverified.

- Act: after writing docs, a fresh worker read-back confirms the files exist,
  are complete, and cross-references resolve → floor met.
- Don't: skipping read-back because the Write tool reported success — the tool
  confirms bytes landed, not that the content is complete or coherent.

## Honest limits

Process — decomposition, verification, multi-sample review — recovers
*execution* quality. It does not recover *taste*: ambiguous requirements,
"technically right but wrong" designs, which defensible reading the user
meant. When the task is taste-shaped: escalate to the strongest model with the
decision framed explicitly; or get a cross-family/user second opinion; or say
plainly this call exceeds the current setup and present options instead of
picking. Silently picking an interpretation to keep momentum is the one
unrecoverable move.
