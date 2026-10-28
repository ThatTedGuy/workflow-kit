---
name: setup
description: Guided setup. Installs the workflow kit into a new or existing project - asks a few questions, writes the answers file, runs install, applies the chosen add-ons, turns on the license hook, and ends with a passing doc check. Run it in the kit folder.
argument-hint: "[project folder; blank = ask]"
disable-model-invocation: true
---

# /setup — install the kit into a project

Runs in the kit folder, and works on the project folder the owner names. Follow the README's "Install" section; this command does it with the owner, start to finish. Change nothing in the kit folder except a new answers file in `personal/`.

Input: $ARGUMENTS

Ask questions as multiple choice with `AskUserQuestion`, 2 to 4 options, recommended first with "(Recommended)" and a one-line trade-off each, and batch them (up to 4 per prompt). Names, the description and paths are plain-text questions. **Never invent the owner's answers:** the project name and description are the owner's words.

## 1. Profile

If `personal/profile.psd1` exists, read it. Its owner, Kit settings and add-ons are used for this project unless the owner changes them here. Say which values came from it, and skip those questions.

## 2. Questions

1. **New or existing project?** New: an empty or missing folder. Existing: a folder that already has code or docs.
2. **The project folder:** its full path (the input, if given). For a new project, it must not exist yet or be empty. For an existing one, it must exist.
3. **Owner, project name, and one-line description** (plain text). The owner is the person who approves plans; skip it if the profile has it. For an existing project, you may quote its README's first line back as a starting point, but the owner decides the words.
4. **Kit settings,** unless the profile sets them, in one prompt:
   - Explanation level: `beginner` (Recommended: explains every choice and term, and gives step-by-step test instructions) or `experienced` (brief and technical).
   - Token use: `strict` (Recommended: reads only what's needed, to stretch a usage limit) or `normal` (reads whole files when that's simpler).
   - Multiple-choice questions: `on` (Recommended: clickable options) or `off` (questions in chat as a numbered list).
5. **Add-ons** (multi-select; list the folders in `addons/`, with each README's first paragraph as the description):
   - `creative-content`: the owner writes the names, user-facing text and story, and Claude uses placeholders.
   - `game`: lore, the AI-content rule, a performance budget, Git LFS. Needs `creative-content`.
   - `unity`: Unity's file and package types for the license check.
   - `windows`: run the kit's scripts in Windows PowerShell 5.1. Recommend it on Windows when `pwsh` isn't installed (`Get-Command pwsh`).

   Pre-select the profile's add-ons. If `game` is picked without `creative-content`, add it and say so.

## 3. Existing project: make room

Install refuses to overwrite a file. For an existing project, list which of the template's files already exist there (`CLAUDE.md`, `CREDITS.md`, `.gitattributes`, `.githooks/pre-commit`, and anything under `docs/` or `prototypes/` with the same name). For each, ask the owner:

- **Move it to `docs/preprod/existing/` (Recommended):** the retrofit step reads it and carries over what matters. An old `CLAUDE.md` is the most important one.
- **Stop setup,** so the owner can sort it out first.

If the project has uncommitted changes (`git status`), say so and recommend committing them first, so the setup is easy to review.

## 4. Install

- Write the answers to `personal/answers-<project-folder-name>.psd1`, in the format of `tests/sample-answers.psd1`, with `REPO_PATH` as the project's full path and `AddOns = @(...)` for the add-ons. Show the owner the file.
- Run install with the shell available: `pwsh -NoProfile -File tools/install.ps1 -Project <folder> -Answers <answers file>`, or on Windows without `pwsh`, `powershell -NoProfile -ExecutionPolicy Bypass -File tools/install.ps1 ...`. It reads the profile itself.
- If install stops, show its message, fix the cause with the owner, and run it again.

## 5. Apply the add-ons

For each add-on, in the order its "Needs" requires (`creative-content` before `game`), read its `README.md` and make every change it lists in the project: `CLAUDE.md`, `.claude/kit-settings.psd1`, `docs/ROADMAP_STATUS.md`, and any other project-owned file it names. Install already copied its files. Don't edit the project's kit-owned files (`.claude/kit/`, the kit's skills).

## 6. Existing project: the retrofit item

Add this as the first item of the pre-production checklist in the project's `docs/ROADMAP_STATUS.md`:

`- [ ] Existing project surveyed: DESIGN.md and the roadmap drafted from the code (/pre-pro retrofit)`

## 7. Git and the license hook

- **Not a Git repo yet:** ask whether to run `git init` there now (Recommended), or leave it to the owner.
- **A Git repo:** make sure `git config core.hooksPath` says `.githooks` in the project (install sets it when `.git` was already there). Outside Windows, `.githooks/pre-commit` must be executable.
- Ask whether to commit the kit's files now (Recommended): stage only the files setup added or moved, never the owner's other changes, and commit as "Add the workflow kit". Never push.

## 8. Check

Run the project's Doc check, using the command in its `CLAUDE.md` "Checks" table, from the project folder. It must report 0 problems. Fix any problem in a file setup wrote, and run it again. `TODO-DESIGN` markers are expected: pre-production fills them.

## 9. Tell the owner

In plain language:

- What was installed, with which add-ons and settings, and where the answers file is.
- What was moved aside, if anything.
- **Next:** open the project folder in Claude Code, in a new session. A new project starts with `/pre-pro`; an existing one with `/pre-pro retrofit`.
- How to test it: in that session, type `/` and see the kit's commands listed.
