# Workflow kit

Claude Code session commands, rules, and doc templates that take a project from raw ideas to a released v1, one small piece at a time.

Version: see `VERSION`. Changes: `CHANGELOG.md`.

## Getting started

Clone or download the kit, open its folder in Claude Code, and run **`/setup`**. It asks a few questions, installs the kit into your project folder, applies the add-ons you pick, turns on the license hook, and checks the result.

- **A new project:** give `/setup` an empty or new folder. Then open that folder in Claude Code and start with `/pre-pro`: it turns your ideas into a design doc and a roadmap, one item per session.
- **An existing project:** give `/setup` the project's folder. It moves aside any file the kit would replace, such as an old `CLAUDE.md`, into `docs/preprod/existing/`. Then open the project in Claude Code and start with `/pre-pro retrofit`: it surveys the code and drafts the design doc and a roadmap for the remaining work, for you to correct and approve.

To install without `/setup`, see "Install by hand".

## What's here

| Path | What it is |
| --- | --- |
| `template/` | The product that install copies into a project. Its names are disguised (`CLAUDE.template.md`, `dot-claude/`, `dot-gitattributes`) so Claude Code never loads them here |
| `addons/` | Optional add-ons: `creative-content`, `game`, `unity`, `windows` (see "Add-ons") |
| `.claude/skills/setup/` | The `/setup` command |
| `personal/` | Your personal profile and answers files, which Git ignores. `example.psd1` shows the format |
| `tools/install.ps1` | Install, update, and migrate |
| `tools/test-install.ps1` | Installs into a temp folder and checks the result |
| `tools/check-template.ps1` | Fails if a loadable name slips into `template/` or `addons/` |
| `docs/` | The kit's own design doc, roadmap, and decision log |

**Kit-owned vs project-owned.** In a project, `.claude/kit/` and the kit's skills in `.claude/skills/` (`code`, `plan-it`, `pre-pro`, `qa-docreview`, `quick-fix`, `review-fix-commit`, `talk`) are kit-owned: an update replaces them, so don't edit them there. Everything else, including `CLAUDE.md`, `.claude/kit-settings.psd1`, `.githooks/`, `docs/`, and any skills you add, belongs to the project and is never touched by an update.

## Commands

What a project gets. `.claude/kit/RULES.md` in the project has the full rules.

Stages use the film and game-dev sense: pre-production is planning, production is building v1, and post-production is everything after release. "Production" here doesn't mean a live server.

| Command | When |
| --- | --- |
| `/pre-pro` | Pre-production: turn ideas into the design doc and roadmap, research a question, or build a throwaway prototype. `/pre-pro retrofit` drafts them from an existing project's code. Later, plan each update |
| `/plan-it` → `/code` → `/review-fix-commit` | Build track: one roadmap sub-step, each command in its own session |
| `/qa-docreview` → `/code` → `/review-fix-commit` | Quality track: at every phase gate, and when bugs or doc drift pile up |
| `/quick-fix` | A typo, wording, a config or tuning value, or a small bug whose cause is known, from request to commit in one session. Limits: at most 3 files changed, no new files, no feature, design change, new dependency, or owner decision |
| `/talk` | Talk an idea, question or concern through. Read-only: a hook blocks shell commands and every edit except the parking lot and decision log |

**Kit settings.** Each project's `CLAUDE.md` has three settings that change how sessions behave: explanation level (`beginner` or `experienced`), Token use (`strict` or `normal`), and multiple-choice questions (`on` or `off`). The defaults are beginner, strict, and on. `RULES.md` says what each changes.

## Add-ons

The core kit names no language, operating system, engine, or kind of project. Add-ons add the specific parts. `/setup` asks which you want; each one's `README.md` lists what it changes, all in project-owned files.

| Add-on | For |
| --- | --- |
| `creative-content` | Projects with content the owner writes: names, user-facing text, story. Claude uses placeholders such as `TODO-CONTENT` and never invents it |
| `game` | Games: lore and in-game text placeholders, the AI-content rule, a performance budget, Git LFS. Needs `creative-content` |
| `unity` | Unity projects: Unity's file and package types for the license check |
| `windows` | Running the kit's scripts in Windows PowerShell 5.1 when PowerShell 7 isn't installed |

## Personal profile

If you install the kit into several projects, keep your usual answers in `personal/profile.psd1`: your name, Kit settings, and the add-ons you always use. Copy `personal/example.psd1` to start. Install and `/setup` read it whenever it exists, so each project only needs its own name, description, and path. Git ignores `personal/` (except the example), so your profile stays on your machine, and pulling a new version of the kit never touches it.

## Requirements

- [Claude Code](https://claude.com/claude-code) and Git.
- **PowerShell 7 (`pwsh`)** runs the kit's scripts. On Windows, the built-in Windows PowerShell 5.1 works too (pick the `windows` add-on): write `powershell -NoProfile -ExecutionPolicy Bypass -File` wherever this README says `pwsh -NoProfile -File`. The `-ExecutionPolicy Bypass` part is for Windows only; Mac and Linux have no execution policy.
- On Windows, Claude Code hooks run in Git Bash, which comes with Git for Windows. `/talk` needs it.
- Windows is tested. Mac and Linux are expected to work but untested.

Commands below run from the kit folder.

## Install by hand

1. Write an answers file with the four install keys, plus any Kit settings you want to change from the defaults and any add-ons (`AddOns = @('creative-content')`). Copy `tests/sample-answers.psd1` and change the values. Keys your profile sets can be left out.
2. Run:

   ```
   pwsh -NoProfile -File tools/install.ps1 -Project <folder> -Answers <answers.psd1>
   ```

   Add `-AddOns creative-content,game` to pick add-ons here instead. `-ProfilePath <file>` reads a different profile, and `-SkipProfile` reads none. Install refuses a folder that already has `CLAUDE.md` or `.claude/kit/`, or any file it would overwrite, and stops before writing if an answer is missing.
3. Make each add-on's changes from its `README.md` (install copies only its files), or ask Claude in the project to.
4. In the project: `git init`, turn on the license hook with `git config core.hooksPath .githooks`, then commit. (If the folder was already a Git repo, install turned the hook on.) Open it in Claude Code and start with `/pre-pro`, or `/pre-pro retrofit` for an existing project after adding the retrofit item to the checklist (see `.claude/skills/setup/SKILL.md`, step 6).

## License hook

Every project gets a Git pre-commit hook, `.githooks/pre-commit`, that runs the license check on what's staged. A commit that adds an asset, a vendored file, or a package with no `CREDITS.md` entry is blocked, with a message saying how to fix it: add the entry, stage `CREDITS.md`, and commit again.

- **Turn it on** once per clone, in the project: `git config core.hooksPath .githooks`. Install and `/setup` do this when the folder is a Git repo.
- **Skip it** with `git commit --no-verify`. That's for the owner's use only, such as committing a fix to the hook itself. Claude never skips it.
- `/review-fix-commit` still runs the license check itself, so a project without the hook is still checked.
- The hook is project-owned, so a project can add its own checks below the kit's.

## Update

1. Commit the project first, so you can see and undo what changes.
2. Run:

   ```
   pwsh -NoProfile -File tools/install.ps1 -Project <folder> -Update
   ```

   It replaces the kit-owned files, removes ones the new version dropped, writes the new `.claude/kit/VERSION`, and prints the changelog entries since your version.
3. Do the "Manual steps" it prints. Check `git diff`: if you had edited a kit-owned file, the edit is gone. Move it to `CLAUDE.md` ("Project rules" or "Project additions to the commands") and commit.

## Migrating from the old layout

For a project made from the old kit (`workflow-starter-kit`), where the rules sit in `CLAUDE.md` and the scripts in `tools/workflow/`.

1. Commit the project first.
2. Run:

   ```
   pwsh -NoProfile -File tools/install.ps1 -Project <folder> -Migrate
   ```

   It replaces the kit's skills, adds `.claude/kit/` and `.claude/kit-settings.psd1`, and changes nothing else.
3. **Rewrite `CLAUDE.md`** using `template/CLAUDE.template.md` as the shape: keep the project's name, description, owner, repo path, "Where things stand", technical principles, code conventions, checks, and environment. Add the line `@.claude/kit/RULES.md` under the header, and the "Kit settings" section. Delete the sections `RULES.md` now holds: rules 1 to 9 and "Also", Stages, Token use, Session types and commands, and the doc map rows for kit files. Put any project change to a kit rule under "Project rules". If the project used placeholders for creative content, keep its "Placeholder kinds" section, which keeps rule 7 on.
4. **Move skill customizations.** If the project's old skills had filled-in blanks or extra steps, put them in `CLAUDE.md` under "Project additions to the commands". (`git diff .claude/skills` shows them.)
5. **Move script settings.** Copy any values changed at the top of `tools/workflow/check-credits.ps1` or `check-docs.ps1` into `.claude/kit-settings.psd1`, then delete `tools/workflow/`. Point the Checks table in `CLAUDE.md` at `.claude/kit/tools/`. For a Unity or Godot project, add the settings from the matching add-on's README.
6. Optional: copy `template/dot-githooks/pre-commit` to `.githooks/pre-commit` and turn on the license hook (see "License hook").
7. Run the doc check (`pwsh -NoProfile -File .claude/kit/tools/check-docs.ps1`) in the project, fix what it reports, and commit.

You can also ask Claude in the project to do steps 3 to 7, following this section.

## Testing the kit

```
pwsh -NoProfile -File tools/check-template.ps1
```

```
pwsh -NoProfile -File tools/test-install.ps1
```

The second installs into a temp folder and checks the result: no leftover placeholders, the kit's commands and settings, add-ons and profiles, the doc check, the `/talk` guard, the license hook in a throwaway Git repo, an update, and the refusals. It tests whichever PowerShell runs it, so run it once with `pwsh` and once with Windows PowerShell to compare the two. Add `-WithClaude` to also start a short headless Claude Code session in the test folder and ask which commands it sees (uses a little of your usage). It needs a signed-in `claude` command; without one it skips. To check by hand instead, install into a scratch folder, open it in the desktop app, and type `/`: the kit's commands should be listed, and asking "who is the owner?" should give the name from your answers file.

## License

MIT: see `LICENSE`. Use it, change it, and share it.

If the kit saves you time, you can leave a tip on [Ko-fi](https://ko-fi.com/thattedguy). Thank you!
