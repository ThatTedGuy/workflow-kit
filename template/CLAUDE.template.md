# {{PROJECT_NAME}}

{{PROJECT_ONE_LINE_DESCRIPTION}}

- **Owner:** {{OWNER}}. "The owner" in the kit rules means {{OWNER}}.
- **Repo path:** `{{REPO_PATH}}`

@.claude/kit/RULES.md

The kit rules above apply to every session. Where "Project rules" below change one, this file wins.

## Kit settings

How the kit's rules and commands behave here (see "Kit settings" in `RULES.md`). Change a value to change how sessions work.

- **Explanation level:** {{EXPLANATION_LEVEL}} (`beginner` or `experienced`)
- **Token use:** {{TOKEN_USE}} (`strict` or `normal`)
- **Multiple-choice questions:** {{MULTIPLE_CHOICE}} (`on` or `off`)
- **Add-ons:** {{ADDONS}}. Each one's changes are in this file; its README is in the kit's `addons/` folder.

## Where things stand

- **Stage and next sub-step:** see the top of `docs/ROADMAP_STATUS.md`.
- TODO-DESIGN: a few lines on what exists so far: stack, main folders, tools. Keep this current.

## Project rules

Changes to the kit rules for this project, each naming the rule it changes. For example, a project with a hosted test server could change rule 8 to name the URL to test on. None yet.

## Technical principles

From `DESIGN.md`. Every change has to respect them, and `/review-fix-commit` and `/qa-docreview` check them.

1. TODO-DESIGN: e.g. Settings and tuning values live in config files, not in code.
2. TODO-DESIGN: e.g. Every math or business-logic module has automated tests.
3. TODO-DESIGN: e.g. The core library makes no network calls.

## Code conventions

- TODO-DESIGN: language, style guide, naming, formatting, line endings.
- TODO-DESIGN: folder layout: what lives where.
- **Tests:** TODO-DESIGN: framework, where tests live, how test files are named.
- **Comments:** short and plain, and they explain why, not what.
- **Dependencies:** add the `CREDITS.md` entry before adding any package or asset.

## Project docs

**Long docs** (see "Token use" in `RULES.md`: search them, don't read them whole): none yet beyond `docs/DESIGN.md` and `docs/DECISIONS.md`.

The project's own docs, beyond the kit's doc map in `RULES.md`:

| File | What it is | Who edits it |
| --- | --- | --- |

## Project additions to the commands

Extra steps the session commands follow in this project. Add a bullet under a command; "None" means the command runs as the kit wrote it.

- **`/pre-pro`, design items:** None.
- **`/plan-it`, extra reading:** None. For example, a performance budget, an API spec, or research notes, and when to read each.
- **`/qa-docreview`, extra QA:** None. For example, performance limits or a test checklist.

## Checks

The session commands run these. Write `none` for a check the project doesn't have yet, and Claude does that check by hand instead.

| Check | Command |
| --- | --- |
| Tests | TODO-DESIGN: the test command |
| Build | TODO-DESIGN: the build command, or none. Say if it runs the tests too. |
| License check | `pwsh -NoProfile -File .claude/kit/tools/check-credits.ps1` (add `-All` to check every file) |
| Doc check | `pwsh -NoProfile -File .claude/kit/tools/check-docs.ps1` |

The kit's scripts run in PowerShell 7 (`pwsh`).

## Environment

- TODO-DESIGN: OS, shell, installed tools and versions, and anything else Claude needs to run the checks.
