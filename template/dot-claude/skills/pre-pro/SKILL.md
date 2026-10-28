---
name: pre-pro
description: Pre-production. Works one item on the pre-production checklist per session: drafts a design doc section from the owner's notes, researches an open question, or builds a throwaway prototype. In Post-production, plans the next update from the parking lot. Never writes production code, and does not commit.
argument-hint: "[checklist item, question id like Q3, topic, 'retrofit', or update version like v1.1; blank = next open item]"
disable-model-invocation: true
---

# /pre-pro — one pre-production item

This is the Pre-production session (RULES.md, "Stages"). It turns the owner's ideas into an approved `docs/DESIGN.md` and roadmap, one item per session. Do not write production code, and do not commit.

Input: $ARGUMENTS

## 1. Check the stage and pick the item

- Read the "Stage:" line in `docs/ROADMAP_STATUS.md`.
  - **Production:** stop and say the next session is `/plan-it`.
  - **Post-production:** this session plans an update ("Update" in section 3). If an approved update still has open sub-steps, say so and ask the owner before planning another.
- **No input:** pick the first unticked item on the "Pre-production checklist" that is ready. The roadmap waits until every other design item is ticked.
- **`retrofit`, or the checklist's first item is the retrofit item:** this session is a retrofit ("Retrofit" in section 3). It comes before every other item.
- **A question ID or topic:** find it in `docs/preprod/QUESTIONS.md` or on the checklist. If it's new, add it to `QUESTIONS.md` first.
- Tell the owner which item this session works on, and which kind of work it is (section 3).

## 2. Read only what the item needs

Follow RULES.md, "Token use".

- `docs/preprod/NOTES.md`: search it for the item's topic, then read those parts. Read it all only when drafting the vision and pillars.
- `docs/preprod/QUESTIONS.md`: the questions that bear on the item.
- `docs/DESIGN.md`: the sections the item touches, plus Vision and Design pillars once they exist.
- The last few entries in `docs/DECISIONS.md`.

## 3. Do the work

One kind per session.

### Design: draft a design doc section

- Build the section from the owner's own notes and answers. Organize and tighten them, and show where the notes leave gaps or contradict each other.
- Where a design choice is missing, don't make it: ask the owner as multiple choice (rule 9), with the options and their trade-offs. Record the answers in the section.
- When rule 7 is on, the content it names, such as names, story, and user-facing text, stays as placeholders of the kinds under "Placeholder kinds" in CLAUDE.md, such as `TODO-CONTENT`, unless the owner wrote it.
- Every system and feature must serve a pillar. An idea that serves none goes to `docs/AFTER_V1.md`.
- Write it into `docs/DESIGN.md` under its heading, marked "(draft)" until the owner approves it.
- **The roadmap item:** split v1 scope into phases, steps, and sub-steps, ending with phases for polish, bug fixing, and the v1 release. Each sub-step should fit one Build-track cycle. Each step gets a "Done when" line someone can check, and each phase a gate. Copy it into `docs/ROADMAP_STATUS.md` as checkboxes.
- **Project design items:** also work any `/pre-pro` design items listed under "Project additions to the commands" in CLAUDE.md, the same way.

### Retrofit: draft the design doc from existing code

For a project that had code before the kit (`/setup` adds the retrofit item). The goal is a draft `DESIGN.md` and roadmap that describe what exists and what's left, for the owner to correct and approve.

- **Survey, don't read everything** (RULES.md, "Token use"): the folder tree two levels deep, the README, package and build files, the test folders, `git log --oneline` (the last 50 commits and the total count), and anything in `docs/preprod/existing/`, such as an old `CLAUDE.md`. Then read only the entry points and the main module of each system.
- **Write down what exists** in `docs/preprod/NOTES.md`, under "Existing project survey": each system with its files, what it does now, what looks unfinished (TODOs, failing or missing tests, dead code), the stack, how to build and test it, and any license questions (third-party code or assets with no credit).
- **Draft `DESIGN.md`, marked "(draft)":**
  - Vision and design pillars: only from the owner's own words (the README, notes, an old `CLAUDE.md`). Where they're missing, ask; never invent them.
  - Core systems: one section per existing system, describing how it works now, with file paths. Mark what's built and what isn't.
  - v1 scope: what's built, plus what the owner says v1 still needs. "Not in v1": anything the owner rules out.
  - Technical principles and code conventions: the ones the code already follows, for the owner to confirm. Copy them to `CLAUDE.md` once approved, with the Checks commands and environment.
- **Draft the roadmap** for the remaining work only. A good first phase makes the existing code safe to change: tests around the core systems, the license check passing with `-All` (credits for existing assets and packages), and fixes for doc drift. Built work isn't re-planned.
- **Tick what the survey settled** on the checklist only with the owner's OK, such as "Stack or engine chosen" when the stack is already fixed. Log each in `docs/DECISIONS.md`.
- Ask the owner, as multiple choice where possible (rule 9): which unfinished parts are in v1, which are dropped, and the pillars if they're missing.

### Research: answer an open question

- For questions such as the stack or engine choice, comparable products, or how something works in the real world.
- Search, read, and compare. Cite every source with a link.
- Write the answer under the question in `docs/preprod/QUESTIONS.md`: what was found, the options, and a recommendation with its reasons. Ask the owner to choose (rule 9), and log the choice in `docs/DECISIONS.md`.

### Prototype: test a risky idea

- Only for a question in `QUESTIONS.md` that reading can't answer, such as "is this fun?", "can this run fast enough?", or "does this tool fit?". Write the question and what result would answer it before building anything.
- Build the smallest thing that answers it, in `prototypes/<slug>/`, with a short `README.md` that says the question, how to run it, and what to look for.
- It's throwaway code: no tests or polish needed. Licenses still apply: add a `CREDITS.md` entry before using any third-party asset or library (rule 6).
- Keep it to about 40 tool calls. If it needs more, stop at a point where it runs, and note what's left.
- Tell the owner exactly how to run it and what to judge (rule 8). Record the result under the question once the owner has tried it.

### Update: plan the next version (Post-production only)

- Start from the parking lot rows in `docs/AFTER_V1.md` that the owner marked with this update's version. If none are marked, show the owner the rows and ask which to pick (rule 9); never pick them yourself.
- Check each idea against the design pillars, and against how the shipped product works now: search the code and `DESIGN.md` for the systems it touches.
- Write the update under "Updates after v1" in `DESIGN.md`, following its template: scope, what's not in it, and phases with "Done when" lines and gates. The last phase releases the update. Phase numbers carry on from the last phase before.
- Risky ideas can get a question in `docs/preprod/QUESTIONS.md` and a prototype first, the same way as in pre-production.
- On the owner's approval, mark the update approved, copy its phases into `docs/ROADMAP_STATUS.md`, and set the Next sub-step line to its first sub-step.

## 4. Hand off

- Update the checklist in `docs/ROADMAP_STATUS.md`: leave the item for the owner to tick after reading, unless the owner already approved it in this session.
- Log any decision in `docs/DECISIONS.md` (rule 4).
- Tell the owner, in plain language: what was done, where it is, what to read or try, and the questions still open.
- Ask the session's questions in one multiple-choice prompt (rule 9), including whether to approve the item.
- Name the next session: `/pre-pro <next item>`. When the whole checklist is ticked, the owner sets the Stage line to Production, and the next session is `/plan-it`. After an approved update, the next session is `/plan-it` too.
