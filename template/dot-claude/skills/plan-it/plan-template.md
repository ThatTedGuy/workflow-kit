# <sub-step id> — <title>

**Status:** Draft
**Step "Done when":** <quote from DESIGN.md>
**Pillars served:** <the design pillars this serves>

## Goal

One or two plain sentences on what exists once this is done.

## Scope check

| Work item | Verdict | Covered by (quote DESIGN.md) |
| --- | --- | --- |

Flagged and left out: <the items, or "none">

## Approach

The steps in plain language. Explain each choice, its main tradeoffs (what it gains, and what it costs or risks), and the options passed over and why.

## Build parts

One `/code` session builds each part (`/plan-it` section 4). For each part: its letter, what it builds, its files, and how to check it's done (the build passes, plus what the tests or the owner can see). Write "One part" for a small sub-step.

## Files

| File | New or changed | What |
| --- | --- | --- |

## Credits needed

| Item | Source | License | CREDITS.md entry |
| --- | --- | --- | --- |

Write "None" if nothing is third-party.

## Tests

The automated tests to add or run, what each one checks, and the command that runs them (the Tests check in CLAUDE.md). If the project has no test runner yet, say so here, name one that fits the stack, and ask about it under "Open questions for the owner" (`/plan-it` section 4).

## How the owner tests it

A short numbered checklist the owner can follow alone (RULES.md rule 8). Exact steps: what to open, what to click or type, and what should happen. If any step uses a terminal, step 1 is the `cd` into the repo path from CLAUDE.md. If the work has nothing to see yet, such as internal logic, the checklist runs the tests and says what passing looks like.

## Decisions to log

Each decision this plan makes, to go in `docs/DECISIONS.md`.

## Open questions for the owner

Each question with its options, recommended one first. `/plan-it` also asks them as a multiple-choice prompt (RULES.md rule 9), then records the answers under "The owner's answers (YYYY-MM-DD)".

---

## Coding notes

Filled in by `/code`: what was built, what changed from the plan and why, and the test results.

## Review notes

Filled in by `/review-fix-commit`: what the review found and fixed, the check results, and the commit.
