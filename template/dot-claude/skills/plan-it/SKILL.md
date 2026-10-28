---
name: plan-it
description: Build track, session 1 of 3. Plans one roadmap sub-step, runs the v1 scope check, and saves the plan to docs/plans/. Writes no code.
argument-hint: "[sub-step id like 1.1.1, or a task description; blank = next open sub-step]"
disable-model-invocation: true
---

# /plan-it — plan one sub-step

This is the Plan session of the Build track (see RULES.md). It produces one plan file for the owner to approve. Do not write code, and do not commit.

Input: $ARGUMENTS

## 1. Pick the sub-step

- **Stage:** read the "Stage:" line in `docs/ROADMAP_STATUS.md`. In Pre-production there's no approved roadmap yet, so stop and say the next session is `/pre-pro` (RULES.md, "Stages"). The same goes in Post-production when no approved update has open sub-steps.
- **No input:** use the "Next sub-step" line at the top of `docs/ROADMAP_STATUS.md`.
- **A sub-step ID:** check that it is the next open sub-step. If it is not, tell the owner which one is next (rule 1) and stop unless the owner confirms.
- **A task description instead of an ID:** find the sub-step it belongs to. If it belongs to none, take it straight to the scope check in section 3, where it will most likely be flagged.
- **A plan for this sub-step already in `docs/plans/`:** read it and revise it instead of starting over.

## 2. Gather context

Read only what the plan needs (RULES.md, "Token use"): search for a heading, then read that range.

- In `docs/DESIGN.md`, read:
  - The sub-step itself.
  - Its step's "Done when" line and the phase gate.
  - The matching "Core systems design" section.
  - "Technical principles".
- Read the recent entries in `docs/DECISIONS.md`: the last 150 lines or so, plus any entry a search for the sub-step's ID or system finds. Older phases' entries may be in `docs/DECISIONS_PHASE_<n>.md`.
- Read the existing code the work will touch, and any tools the project already has, so the plan reuses them.
- Anything listed for `/plan-it` under "Project additions to the commands" in CLAUDE.md.

## 3. Scope check (required, before anything is written)

List every piece of work the plan would add, and give each one a verdict:

| Verdict | Meaning | Action |
| --- | --- | --- |
| IN | Covered by this sub-step, and by "v1 scope" or "Core systems design". Quote the line. | Keep |
| LATER | In v1, but part of a later sub-step. Name that sub-step. | Leave out; note it |
| OUT | In "Not in v1" or the After v1 parking lot. | Leave out; flag it |
| UNLISTED | Not in `DESIGN.md` at all. | Leave out; flag it; offer to add it to `docs/AFTER_V1.md` |

- Small helpers the sub-step needs to be built and tested, such as a unit test or a debug readout of a new value, count as IN. Say so in the table.
- Every IN item must serve at least one design pillar. Name the pillar.
- **Post-production:** the scope check uses the current update's "Scope" and "Not in this update" lines under "Updates after v1" in `DESIGN.md`, instead of "v1 scope" and "Not in v1". A parking lot idea not picked for this update is OUT (RULES.md, "Stages").
- **If anything is OUT or UNLISTED, or the whole request is: stop.** Show the owner the scope table, say plainly what you would leave out and why, and ask how to go on. Never save a plan that includes flagged work.

## 4. Write the plan

Save it to `docs/plans/<sub-step id>-<short-slug>.md`, following [plan-template.md](plan-template.md). Keep it short and in plain language.

- **Credits:** list every third-party asset, library, dataset, or piece of borrowed code under "Credits needed", with its license. A license that is not CC0, public domain, CC-BY, MIT, BSD, Apache-2.0, or zlib is a question for the owner.
- **Creative content (when rule 7 is on):** every piece of the content named under "Placeholder kinds" in CLAUDE.md, such as names and user-facing text, is a placeholder of a kind listed there, such as `TODO-CONTENT` (RULES.md rule 7).
- **Build parts:** size the build for `/code` sessions that stay short (RULES.md, "Token use"). If the work is more than one session can build comfortably, split it into parts A, B, and so on, under "Build parts". A part is roughly what about 40 tool calls can build and test: as a guide, 2 to 4 new or heavily changed code files with their tests. Each part ends with the build passing, and with something the owner or the tests can check. Small sub-steps are one part.
- **Status:** set it to `Draft`.

## 5. Hand off to the owner

Tell the owner, in plain language:

- What the plan does.
- The scope verdicts.
- Any choices the owner needs to make.
- How the owner will test the result.

Then ask the plan's open questions and for approval in one multiple-choice prompt (RULES.md rule 9): one question per open question, with the plan's recommendation first, and a last question asking for approval of the plan. Record the answers in the plan under "The owner's answers (YYYY-MM-DD)" and apply them. On approval, set its status to `Approved (the owner, YYYY-MM-DD)`. The next session is `/code <sub-step id>`.
