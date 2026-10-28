---
name: code
description: Build track and quality track, session 2 of 3. Builds an approved plan from docs/plans/, or the fixes in a report from docs/qa/. Does not commit.
argument-hint: "[sub-step id or QA report name; blank = newest approved plan]"
disable-model-invocation: true
---

# /code — build what was approved

This is the Code session (see RULES.md). It builds exactly what was approved and leaves the work uncommitted for `/review-fix-commit`.

Input: $ARGUMENTS

## 1. Load the work

- **Sub-step ID, or no input:** open the matching plan in `docs/plans/`, or the newest plan if there was no input. Its status must say `Approved`. If it says `Draft`, ask the owner to approve it first.
- **QA report name:** open the report in `docs/qa/`. Work through the findings owned by Claude, most severe first. Skip the "For the owner" items.
- **Plan and `docs/DESIGN.md` disagree:** stop and ask the owner.

**One part per session.** If the plan has "Build parts", build only the first part not yet marked done in "Coding notes", and name it when you start ("Part B of 3"). A QA report with many findings works the same way: fix a batch of about 40 tool calls' worth, most severe first. When a session picks up a build an earlier one left unfinished, say what's already done.

**Read only what the work needs** (RULES.md, "Token use"). Read the plan, then the code the part touches. Don't read whole design docs; search them for the section you need.

## 2. Build only what was approved

- Build the work items marked IN, and nothing else.
- **Something the plan missed:**
  - If it is small and clearly part of the same sub-step, build it and record it under "Coding notes".
  - If it is bigger, or belongs outside the sub-step, stop and ask the owner.
  - If it is a new idea, it becomes a row in `docs/AFTER_V1.md`, not code.
- **Credits first:** before adding any third-party asset, library, dataset, or borrowed code, add its `CREDITS.md` entry (rule 6).
- **Conventions:** follow the technical principles and code conventions in CLAUDE.md. When rule 7 is on, use placeholders of the kinds under "Placeholder kinds" in CLAUDE.md, such as `TODO-CONTENT`, for the content it names.
- **Docs you must not touch here:**
  - Do not edit `docs/DESIGN.md`.
  - Do not tick anything in `docs/ROADMAP_STATUS.md`; the review session does that.

## 3. Check the work

- Run the Tests and Build checks from the "Checks" table in CLAUDE.md.
- Run the License check from the same table and fix whatever it reports. If the table says `none`, compare the diff's new packages and files with `CREDITS.md` by hand.
- Try the result yourself as far as you can, for example by running it.

## 4. Record and hand off

- In the plan, fill in "Coding notes". For a QA report, fill in "Fixes made" instead. Cover:
  - What was built.
  - What changed from the plan, and why.
  - The test results.
  - Anything left undone.
- With build parts, mark the part done in "Coding notes", for example "Part A: done".
- **Stop at a checkpoint when the session runs long.** If a part takes far more than planned, past about 60 tool calls, stop at the next point where the build passes. Record what's done and what's left in "Coding notes", then hand off. A fresh session picks up from there for less than this one would spend carrying on.
- Make sure "How the owner tests it" matches what was actually built.
- Do not commit.

Tell the owner, in plain language:

- What changed.
- Exactly how to test it. If it uses a terminal, start with the `cd` into the repo folder (RULES.md rule 8).
- Anything unfinished.

The next session is a fresh `/code <same input>` if parts or fixes are left, otherwise `/review-fix-commit <same input>`. Say which.
