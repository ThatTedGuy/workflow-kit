---
name: qa-docreview
description: Quality track, session 1 of 3. Tests the build, checks code and docs for drift from DESIGN.md, and writes a findings report to docs/qa/. Changes no code. Run at every phase gate and whenever bugs or doc drift pile up.
argument-hint: "[focus, e.g. 'Phase 1 gate' or 'login'; blank = everything built so far]"
disable-model-invocation: true
---

# /qa-docreview — find bugs and doc drift

This is the QA/DocReview session of the Quality track (see RULES.md). It finds problems and reports them. Do not change code or docs; the only file it writes is the report.

Input: $ARGUMENTS

## 1. Check the docs against each other

Run the Doc check from the "Checks" table in CLAUDE.md. If it says `none`, check by hand:

- Every doc in the doc map in RULES.md and under "Project docs" in CLAUDE.md exists.
- `ROADMAP_STATUS.md` lists the same steps, sub-steps, and phase gates as the roadmap in `DESIGN.md`, in the same order.
- Every step in `DESIGN.md` has a "Done when" line.
- No step or gate is ticked while work under it is open, and "Next sub-step" points at the first open one.
- Every idea in `AFTER_V1.md` is also in the parking lot in `DESIGN.md`. List the missing ones for the owner.
- The count of each placeholder kind, such as `TODO-CONTENT`, by file (the doc check reports them).

Every problem and note goes in the report.

## 2. Doc-drift check: code against DESIGN.md

For everything built so far, or for the focus area, compare the code with `docs/DESIGN.md`. List every mismatch:

- **Core systems design:** check that each built system behaves as its spec says.
- **Technical principles:** search for code that breaks any principle or code convention in CLAUDE.md, and for borrowed code with no credit.
- **v1 scope:** any built feature that is in "Not in v1", or nowhere in `DESIGN.md`.
- **`ROADMAP_STATUS.md`:** every ticked sub-step exists and works.
- **Other docs:**
  - Tool docs match the tools.
  - `docs/DECISIONS.md` matches what the code does.
  - The doc map in `RULES.md` and the "Project docs" table in `CLAUDE.md` are accurate.
- **Credits:** run the License check over the whole project, or compare every package and third-party file with `CREDITS.md` by hand.

For each mismatch, quote the `DESIGN.md` line and give the file and line in the code. Then say which side looks wrong:

- **The code:** Claude fixes it.
- **The design doc:** only the owner can change it.

## 3. QA

- Run the Tests and Build checks from the "Checks" table in CLAUDE.md.
- Run the project and try what it does, as far as you can.
- Anything listed for `/qa-docreview` under "Project additions to the commands" in CLAUDE.md.
- Record every bug with steps to reproduce it.

## 4. Phase gate (when the focus is a gate)

Mark each condition in the gate line PASS, FAIL, or "the owner verifies", with the evidence. Do the same for the "Done when" line of every step in the phase.

**Workflow review.** Look back at how the phase's work went, not the work itself. Search the phase's plans and QA reports (their "Coding notes", "Fixes made", and "Review notes"), the decision log, and `git log` for:

- Sessions that ran long: build parts that hit the checkpoint, or sub-steps that needed extra `/code` sessions.
- Plans that changed a lot while being built, and why.
- Problems `/review-fix-commit` or this QA kept finding, especially the same kind more than once.
- Steps the owner found confusing or slow, from the owner's notes or answers. Ask the owner for the usage numbers if they're useful.

Suggest at most three changes to the workflow (the session commands, `RULES.md`, `CLAUDE.md`, or the templates), each with the evidence behind it. These are for the owner to approve, so they go under "For the owner", never straight into the files.

## 5. Write the report

Save it to `docs/qa/<YYYY-MM-DD>-<focus-slug>.md`, following [report-template.md](report-template.md). Give each finding:

- An ID: Q1, Q2, and so on.
- A type.
- A severity.
- An owner: Claude or the owner.

## 6. Hand off

Tell the owner, in plain language:

- The top findings.
- Anything blocking.
- The items only the owner can do: design doc changes, creative content, hands-on testing, and approvals.

Next, `/code <report name>` fixes Claude's items, then `/review-fix-commit` commits them.
