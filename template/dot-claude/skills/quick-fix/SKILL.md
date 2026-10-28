---
name: quick-fix
description: Quick-fix lane. One session from request to commit for a typo, wording, a config or tuning value, or a small bug whose cause is known. At most 3 files changed and no new files. Redirects anything bigger to /plan-it or the Quality track.
argument-hint: "[what to fix, e.g. 'typo in the README intro' or 'jump height should be 4']"
disable-model-invocation: true
---

# /quick-fix — small fix, one session

The quick-fix lane (see RULES.md). It skips the plan and the roadmap for changes too small to need them, but still runs the checks, reviews the diff, and commits.

Input: $ARGUMENTS

## 1. Check the limits

A quick fix is one of:

- A typo or wording fix.
- A config or tuning value.
- A small bug whose cause is already known, or found in a few minutes of reading.

And all of these hold:

- **At most 3 files changed**, counting tests and docs.
- **No new files.**
- No new feature or behavior, no design change, no new dependency or asset, and no decision only the owner can make.
- When rule 7 is on, creative content stays the owner's: fixing a typo in their text is fine; writing new text isn't.

If the input is blank, ask what to fix. If the request fails a limit, say which one and stop without changing anything. Suggest the right path: `/plan-it` for a feature or anything on the roadmap, `/qa-docreview` when the cause of a bug is unknown, `/pre-pro` or `/talk` for a design question.

## 2. Fix

- Read only the code or text the fix needs (RULES.md, "Token use").
- Make the change. Add or update a test when the fix is to logic and the project has tests.
- **If the fix grows past the limits while you work** (a fourth file, a new file, a design question), stop. Undo your changes with `git restore` and `git clean` on only the files you touched, tell the owner what you found, and suggest `/plan-it` or the Quality track.

## 3. Check

- Run the Tests and Build checks from the "Checks" table in CLAUDE.md. They must pass.
- Run the License check. It must pass (a quick fix adds no assets or packages, so a failure means the fix is out of bounds).
- Run the Doc check if any doc changed.
- Review your own diff (`git diff`): it does only what was asked, respects the technical principles and code conventions in CLAUDE.md, and changes at most 3 files.
- Anything listed for `/quick-fix` under "Project additions to the commands" in CLAUDE.md.

## 4. Commit

- If the fix involved a choice, such as which of two values, log it in `docs/DECISIONS.md` (rule 4) in the same commit.
- Don't touch `docs/ROADMAP_STATUS.md`: quick fixes aren't roadmap work.
- Commit message subject: `Quick fix: <what changed>`, then a line or two on why.
- Never push unless the owner asks.

## 5. Tell the owner

In plain language: what changed and why, the check results, and exactly how to test it. If it uses a terminal, start with the `cd` into the repo folder (rule 8).
