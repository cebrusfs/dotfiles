# Antigravity CLI (`agy`) — verification task

**Status: not verified.** As of 2026-07-27 no `agy` binary was on the machine
this was written on, so nothing here could be checked against a live route.
This file exists so the work can be handed to an agent running inside
Antigravity itself, which can check its own CLI rather than guess.

Hand the prompt below to an Antigravity session. Do not run it from Claude or
Codex — the whole point is that the answers come from the live `agy` route.

## Why this is open

Gemini CLI was retired for free, Google AI Pro, and Ultra tiers on 2026-06-18
and replaced by Antigravity CLI (`agy`), a compiled Go binary; only paid Gemini
/ Gemini Enterprise Agent Platform API-key customers keep the legacy CLI.
Source: [the official transition
announcement](https://github.com/google-gemini/gemini-cli/discussions/27274),
read 2026-07-27.

`config/agent/skills/agent-delegate/references/cli.md` previously carried a
`gemini -p` invocation with no verification and no unverified label. It has been
replaced by an explicitly unverified `agy` section pointing here. **Record only
`agy`; the `gemini` form is not coming back.**

`config/agent/gemini/` and `config/agent/antigravity/` both still exist in this
repo. Deciding whether the gemini adapter should be retired is part of this
task, not a foregone conclusion — check whether anything still consumes it.

## Prompt to hand to an Antigravity session

> You are running inside Antigravity CLI. Verify how *you* can be dispatched
> non-interactively as a worker by another agent, using only what you can check
> from this machine and this session. Do not guess a flag, a model id, or a
> default; anything you cannot establish, report as unverified.
>
> Establish and report, each with how you established it (`--help` output, the
> live schema, a command you ran, or official documentation with a URL):
>
> 1. The non-interactive / headless invocation form — the `agy` equivalent of
>    `gemini -p "<prompt>"`. Include the exact subcommand and flags.
> 2. How to select a model, and which model ids this route actually accepts.
> 3. How to run read-only or otherwise sandboxed, and how approvals are
>    suppressed for an unattended worker.
> 4. How to capture the final response for machine parsing — a last-message
>    flag, a JSON/JSONL mode, or a schema flag.
> 5. Whether a session can be resumed, and with what command.
> 6. Any reasoning-effort or thinking-budget selector, and its accepted values.
> 7. The installed version, and the date you checked.
>
> Then apply the results to this repository (`~/.dotfiles`):
>
> - Rewrite the `## Antigravity (agy)` section of
>   `config/agent/skills/agent-delegate/references/cli.md` with the verified
>   facts. Keep the file's existing conventions: record only the
>   non-interactive form, sandbox/read-only mode, model selector, output
>   capture, and verified failure recovery — and keep the note that the CLI
>   dispatch crosses a session boundary and needs the user's opt-in.
> - Label anything still unestablished as unverified rather than dropping it.
> - Check whether `config/agent/gemini/` is still consumed by anything. If it
>   is dead, say so and propose removing it; do not remove it silently.
> - Delete this file once its section is verified, and say in the commit
>   message that you did.
>
> Repo conventions: commit messages are `component: title` — never Conventional
> Commits, never AI attribution trailers. This repo is jj + git colocated: use
> `jj`, never `git add/commit/stash`, and never rewrite a pushed commit.
