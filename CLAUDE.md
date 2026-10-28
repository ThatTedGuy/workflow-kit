# CLAUDE.md

The workflow kit: Claude Code session commands, rules, and doc templates that take a project from raw ideas to a released v1, one small piece at a time. This folder is where the kit itself is developed.

- **Owner:** Ted. Only Ted approves plans, moves ideas into an update, and changes `docs/DESIGN.md`.
- **Repo path:** the kit folder (`<kit folder>` in commands)
- **Old kit:** `<old kit folder>`, outside this repo. It's read-only: copy from it, never change it.

**`docs/DESIGN.md` is the single source of truth.** Build only what it lists, in roadmap order, one step per session. Before making a design call, read the update's Scope and "Not in this update".

## Where things stand

- **Stage and next sub-step:** see the top of `docs/ROADMAP_STATUS.md`.
- The restructure is done (2026-10-27, a one-off job). `template/` holds the product under safe names. `addons/` holds the add-ons (`creative-content`, `game`, `unity`, `windows`), which edit only project-owned files. The template's rules are split into the kit-owned `template/dot-claude/kit/RULES.md` and the project-owned `template/CLAUDE.template.md`, which imports it. The check scripts read the project-owned `template/dot-claude/kit-settings.psd1`. `tools/install.ps1` installs and updates projects, and `VERSION` holds the kit's version.
- Update 1 changes 1 to 6 were built as one batch on 2026-10-28 (see `docs/DECISIONS.md`).

## Layout

| Path | What it is | Who edits it |
| --- | --- | --- |
| `CLAUDE.md` | This file: the rules for developing the kit | Claude, with Ted's OK |
| `docs/DESIGN.md` | The kit's design doc: Update 1 | Ted (Claude only when asked) |
| `docs/ROADMAP_STATUS.md` | Progress tracker | Claude ticks finished sub-steps |
| `docs/DECISIONS.md` | Decision log, add-only | Claude and Ted |
| `docs/PARKING_LOT.md` | New ideas for the kit | Claude adds rows; Ted moves them into an update |
| `docs/plans/` | One plan per step | Claude |
| `template/` | The product that gets copied into projects. Never live here | Claude |
| `addons/` | Add-ons, one folder each: a `README.md` with the changes to project-owned files, plus optional `files/` (copied by install, with safe names) and `addon.psd1` (the add-ons it needs) | Claude |
| `tools/` | The kit's own scripts: install (and update), and checks | Claude |
| `.claude/skills/setup/` | `/setup`, which users run in the kit folder to install the kit into a project. Live here on purpose | Claude |
| `tests/` | Inputs for the kit's tests | Claude |
| `personal/` | Personal profiles and answers files, ignored by Git. Only `example.psd1` is committed | Each user; Ted's is `profile.psd1` |
| `README.md`, `CHANGELOG.md`, `CREDITS.md`, `VERSION`, `LICENSE`, `.github/FUNDING.yml` | For people who use the kit. The README has the install, update, and migration notes | Claude; Ted sets release versions |

## The template is never live

Claude Code loads `CLAUDE.md`, `CLAUDE.local.md`, `AGENTS.md`, `.claude/CLAUDE.md`, `.claude/skills/`, and `.claude/rules/` from any subfolder once a file there is read or edited. So nothing in `template/` or `addons/` may use those names:

- `CLAUDE.md` is written `CLAUDE.template.md`. Any `X.template.md` installs as `X.md`.
- `.claude/` is written `dot-claude/`, and `.gitattributes` is written `dot-gitattributes`. Any `dot-X` installs as `.X`.
- `tools/check-template.ps1` fails if one slips in.

To mention an import in this file or any kit doc, wrap it in backticks, like `@.claude/kit/RULES.md`. Outside backticks it would be imported.

## Kit-owned and project-owned

In a project that uses the kit, kit-owned means everything in `.claude/kit/` plus the kit's own skill folders in `.claude/skills/` (`code`, `plan-it`, `pre-pro`, `qa-docreview`, `quick-fix`, `review-fix-commit`, `talk`). `tools/install.ps1` holds the same list. Everything else is project-owned, including skills the project adds itself. An update replaces kit-owned files only.

- Kit-owned files hold no per-project blanks. Anything a project fills in lives in its `CLAUDE.md`, `.claude/kit-settings.psd1`, or `docs/`.
- Double-brace blanks in the template mean "install fills this", and nothing else. Design doc prompts that `/pre-pro` fills later are `TODO-DESIGN:` markers.

## Rules for every session

1. **One step per session, in order.** A step is finished only when its "Done when" line is true. If asked to work on a step that isn't next, say which one is next and ask before going on.
2. **Check scope before planning.** If a task isn't in the update's Scope, or is listed under "Not in this update", stop and flag it instead of building it.
3. **New ideas go in `docs/PARKING_LOT.md`,** never into the kit. Only Ted moves an idea into an update.
4. **Log every decision** in `docs/DECISIONS.md`: date, decision, reason, options rejected, and who decided.
5. **Tick finished sub-steps** in `docs/ROADMAP_STATUS.md` in the same commit as the work, and update its "Next sub-step" line. If Ted has to verify a "Done when" line, leave it open, add a dated note, and say so.
6. **Licenses:** use only CC0, public domain, CC-BY, MIT, BSD, Apache-2.0, or zlib. Log every third-party asset, library, dataset, or piece of borrowed code in `CREDITS.md` *before* using it. Ask Ted before using anything with another license, such as GPL, CC-BY-SA, NonCommercial, or an unclear one.
7. **Every template change goes in `CHANGELOG.md`** under "Unreleased": what changed in kit-owned files, and any manual steps for project-owned files. Only Ted sets a release version.
8. **Explain choices in plain language,** and tell Ted exactly how to test each result. When test steps use a terminal, the first command is `cd <kit folder>`. This goes in plans and in chat.
9. **Ask Ted questions as multiple choice** (the `AskUserQuestion` tool), not only in chat text. Give 2 to 4 options, put the recommended one first with "(Recommended)" after its label, and give each option's trade-off in one line. Write the questions and answers into the step's plan too, so there's a record.

Also:

- **Never edit `docs/DESIGN.md` unless Ted asks.** If it looks wrong or out of date, list that as a note for Ted.
- **Never change the old kit or Ted's projects** (a game project and the other games). Try things in scratch folders outside this repo.
- **Git:** one commit per approved step, with the work and its doc updates together. Never push unless Ted asks.

## How a step goes

The kit has no session commands for its own development. (`/setup`, in `.claude/skills/setup/`, is for users: it installs the kit into a project.) Each step is a plain session that follows this loop:

1. Read the top of `docs/ROADMAP_STATUS.md` and the step in `docs/DESIGN.md`. Check scope (rule 2).
2. Write a short plan in `docs/plans/<id>-<slug>.md`: what changes, which files, how Ted tests it, and any open questions. Ask the questions and for approval (rule 9). Change nothing else before approval.
3. Build only what the plan lists.
4. Run the checks, then check the step's "Done when" line item by item.
5. Review your own diff against the plan, and fix what's off.
6. Update `docs/ROADMAP_STATUS.md`, `docs/DECISIONS.md`, and `CHANGELOG.md` as needed, then commit (rules 4, 5, and 7).
7. Tell Ted what was done, how to test it, and what's left for him to verify. Name the next step.

## Token use

Ted's usage limit sets the project's pace, so sessions spend tokens carefully. Each turn re-sends the whole conversation, so what's read stays in the cost until the session ends. Never trade away quality or checks to save tokens.

- **Read only what's needed.** Search for a heading or name first, then read that range. Don't read whole long docs or print several whole files in one command. Don't re-read a file that's already in the conversation and unchanged.
- **Keep sessions short:** one step per session. Start a new chat for an unrelated topic.
- **The template is the product:** read a template file to change it, not for background.

## Checks

| Check | Command |
| --- | --- |
| Template check | `powershell -NoProfile -ExecutionPolicy Bypass -File tools/check-template.ps1` |
| Install and update test | `powershell -NoProfile -ExecutionPolicy Bypass -File tools/test-install.ps1` |

Until a check exists, do it by hand: search `template/` and `addons/` for the names in "The template is never live".

## Environment

- Windows 11, Git 2.55, Git Bash, and Windows PowerShell 5.1 (`powershell`). `pwsh` isn't installed. The scripts support both (Step 1.3), so use `powershell` here, and `pwsh` once it's installed.
- Run scripts as `powershell -NoProfile -ExecutionPolicy Bypass -File <script>`.
- The `claude` command-line tool isn't on the path, so checks that need a fresh Claude Code session are done by Ted in the desktop app.
