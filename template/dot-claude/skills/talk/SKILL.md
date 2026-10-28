---
name: talk
description: Discussion session for ideas, questions and concerns about the project. Read-only - never edits code, runs builds or commits; it can add to the parking lot and the decision log with the owner's OK. Ends with a wrap-up of ideas, decisions, open questions and design doc notes.
argument-hint: "[topic, idea, or question; blank = ask what's on the owner's mind]"
disable-model-invocation: true
hooks:
  PreToolUse:
    - matcher: "Edit|Write|MultiEdit|NotebookEdit|Bash|PowerShell"
      hooks:
        - type: command
          command: 'sh "${CLAUDE_PROJECT_DIR}/.claude/kit/tools/run-ps.sh" "${CLAUDE_PROJECT_DIR}/.claude/kit/tools/talk-guard.ps1"'
---

# /talk — talk it through

A discussion session at any stage. The owner brings an idea, a question, or a worry; Claude thinks it through with them, using the project's docs and code as evidence.

Input: $ARGUMENTS

**Read-only.** Never edit code or docs, run builds, tests or commands, or commit. A hook enforces this for the rest of the session: shell commands and file edits are blocked, except `docs/AFTER_V1.md` and `docs/DECISIONS.md`, and those only with the owner's OK. If the talk ends in "let's build it", the owner starts a new session with the right command.

## 1. Get oriented

- Read the top of `docs/ROADMAP_STATUS.md`: the stage and the next sub-step.
- If the input names a topic, search for it (Grep for a heading or name), then read only that range. Follow the Token use rules in `RULES.md`: no whole long docs.
- If the input is blank, ask the owner what's on their mind.

## 2. Talk

- Answer plainly. Back claims with what the docs or code say, quoting the file and line.
- Check ideas against `docs/DESIGN.md`: which design pillar each serves, and whether it's in v1 scope (or the current update's scope), listed in "Not in v1", or new.
- Give a recommendation when the owner is weighing options, with the trade-offs. Ask questions the rule 9 way.
- **New idea:** offer to add it to `docs/AFTER_V1.md` as a row. Add it only after the owner says yes. Never put it in the roadmap or design doc.
- **Decision made:** offer to log it in `docs/DECISIONS.md` (rule 4). Log it only after the owner says yes.
- **The design doc looks wrong or out of date:** note it for the wrap-up. Never edit `DESIGN.md`.

## 3. Wrap up

When the owner is done, or asks for it, end with these four lists. Write "None" for an empty one.

1. **Ideas to park:** each idea, and whether it's now in `docs/AFTER_V1.md`.
2. **Decisions made:** each decision, and whether it's now in `docs/DECISIONS.md`.
3. **Open questions:** what's still undecided, and who answers it.
4. **Design doc notes:** anything in `docs/DESIGN.md` that looks wrong or out of date, quoting the line. Only the owner changes it.

Then name the command that fits the next move, such as `/pre-pro`, `/plan-it`, `/quick-fix` or `/qa-docreview`, to run in a new session.
