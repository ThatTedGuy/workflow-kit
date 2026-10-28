---
name: review-fix-commit
description: Build track and quality track, session 3 of 3. Reviews the uncommitted work against its plan or QA report, fixes problems, runs the blocking license check, updates the roadmap and decision log, then commits.
argument-hint: "[sub-step id or QA report name; blank = the work in progress]"
disable-model-invocation: true
---

# /review-fix-commit — review, fix, commit

This is the Review/Fix/Commit session (see RULES.md). It checks the uncommitted work, fixes what is wrong, and commits the work together with its doc updates.

Input: $ARGUMENTS

## 1. Gather the work

- Run `git status` and `git diff`, and include new files.
- Open the plan in `docs/plans/` or the report in `docs/qa/` that the work came from.
- If there is nothing to commit, say so and stop.
- If the plan has build parts and "Coding notes" doesn't mark them all done, say which are left and stop. The next session is `/code` for the next part.
- Read only what the review needs (RULES.md, "Token use"): the diff, the plan, and the code around the changes.

## 2. Review

Check each point, and note what you find:

- **Plan match:** the diff does what the plan or report says, and nothing more. Remove anything that is OUT or UNLISTED for v1 instead of committing it. Parked ideas go to `docs/AFTER_V1.md`.
- **Correctness:** bugs, edge cases, error handling, and crashes.
- **Principles:** every technical principle and code convention in CLAUDE.md holds. When rule 7 is on, the content it names uses placeholders of the kinds under "Placeholder kinds" in CLAUDE.md, such as `TODO-CONTENT`, and none was invented.
- **Tests and build:** run the Tests and Build checks from the "Checks" table in CLAUDE.md. They must pass. New logic has tests.
- **Docs:**
  - Any tool that was added or changed is documented.
  - `docs/DESIGN.md` was not edited, unless the owner asked for it.

## 3. License check (blocking)

Run the License check from the "Checks" table in CLAUDE.md. If it says `none`, compare every new package and file in the diff with `CREDITS.md` by hand.

- **A failed check means do not commit.** Fix it in one of two ways, then check again until it passes:
  - Add the missing `CREDITS.md` entries. Ask the owner for the source or license if you don't know them.
  - Or remove the item.
- **What a script can't see:** read the diff for:
  - Borrowed code, such as a function adapted from an open-source project or a forum answer.
  - Copied text.
  - Datasets.

  Each one needs a `CREDITS.md` entry.
- **Licenses:**
  - Allowed without asking: CC0, public domain, CC-BY, MIT, BSD, Apache-2.0, and zlib.
  - Anything else, including GPL, LGPL, CC-BY-SA, NonCommercial, NoDerivatives, or an unclear license: stop and ask the owner.

## 4. Fix

- Fix what the review found, then run the tests and the license check again.
- If a fix would change the plan's scope, or needs the owner's call, stop and ask instead of committing.

## 5. Update the docs (same commit as the work)

- **`docs/ROADMAP_STATUS.md`:**
  - Tick each finished sub-step `[x]`, and update the "Next sub-step" line.
  - Tick a step's "Done when" line only once it is true. If the owner has to verify it, leave it open, add a dated note, and say so.
- **`docs/DECISIONS.md`:** add an entry for each decision made (date, decision, reason, rejected options, who decided). Read only the last few entries, then add yours at the bottom.
- **The plan or QA report:** fill in "Review notes" and set its status to `Done`.
- **Doc check:** run the Doc check from the "Checks" table in CLAUDE.md and fix any problems it lists. If it says `none`, check by hand that `ROADMAP_STATUS.md` matches the roadmap in `DESIGN.md` and that "Next sub-step" points at the first open one.

## 6. Commit

- Stage the work and its doc updates together.
- Commit message:
  - Subject: `<sub-step id>: <what changed>`. For QA fixes, use `QA <report date>: <what changed>`.
  - Body: a few plain-language lines.
- Never push unless the owner asks.

## 7. Tell the owner

In plain language:

- What was committed.
- What the review fixed.
- The license check result.
- Exactly how to test it. If it uses a terminal, start with the `cd` into the repo folder (RULES.md rule 8).
- Which sub-step is next.
