# Implementation (bounded patch)

```text
Goal: implement <change> in <files/module>, because <motivation>.
Plan: follow this approved high-level plan and boundaries: <steps>.
Facts: <verified facts with their source paths, the relevant symbols, and the
constraints, invariants, and project conventions that apply>. Enough that you
need not reconstruct the project's overview to work on this.
Reading (mine, test it): <any inference of mine, labelled>. Treat it as a
starting point, not a boundary; report if the evidence points elsewhere.
Do not inherit unrelated conversation history.
Write set: only <paths>. Do not touch anything else or commit. Stop and report
before touching anything outside it.
Edit the bounded write set directly, then run these acceptance checks yourself.
Acceptance: <commands>; <observable behavior>.
Report: changed files with one-line rationale, command results, and anything
noticed but deliberately not changed.
Do not spawn a writable worker, and do not wait indefinitely on anything — if
you cannot bound a wait, stop and report instead.
```

Drop the `Reading` line entirely when the lane is blind.
