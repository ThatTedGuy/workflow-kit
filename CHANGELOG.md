# Changelog

One entry per kit version. `tools/install.ps1 -Update` prints every entry newer than the project's version.

- **Kit-owned changes:** files an update replaces: `.claude/kit/` and the kit's own skills.
- **Manual steps:** changes the owner makes by hand in project-owned files (`CLAUDE.md`, `.claude/kit-settings.psd1`, `docs/`). Update lists them and never makes them.

Versions: **patch** fixes kit-owned files only; **minor** adds features, with any manual steps optional; **major** has at least one required manual step. Projects on the old mixed layout count as 0.x.

## Unreleased

Nothing yet.

## 1.0.1 — 2026-10-28

### Kit-owned changes

- `/code`, `/review-fix-commit`, `/talk`, and `/quick-fix` now each name their list under "Project additions to the commands" in `CLAUDE.md`, the way `/plan-it` and `/qa-docreview` already did, instead of relying on the general line in `RULES.md`.

### Manual steps

- None. To give one of these commands extra steps, add a bullet for it under "Project additions to the commands" in `CLAUDE.md`.

## 1.0.0 — 2026-10-27

### Kit-owned changes

- The kit's rules moved out of `CLAUDE.md` into `.claude/kit/RULES.md`, which `CLAUDE.md` imports. `CLAUDE.md` keeps only what's per project.
- The check scripts moved from `tools/workflow/` to `.claude/kit/tools/`. They read their settings from `.claude/kit-settings.psd1`, with built-in defaults, and report leftover `TODO-DESIGN:` markers.
- The skills and scripts hold no blanks. They say "the owner", named in `CLAUDE.md`.
- Install fills four keys: `OWNER`, `PROJECT_NAME`, `PROJECT_ONE_LINE_DESCRIPTION`, `REPO_PATH`. Prompts filled later in pre-production are `TODO-DESIGN:` markers.
- New `.claude/kit/VERSION`.
- New `/talk` command (`.claude/skills/talk/`): a read-only discussion session. Its hook (`.claude/kit/tools/talk-guard.ps1`) blocks shell commands and every edit except `docs/AFTER_V1.md` and `docs/DECISIONS.md` for the rest of the session. `RULES.md` lists it under session types, the command table, and the doc map.
- New `.claude/kit/tools/run-ps.sh`: runs a kit script with `pwsh` if it's installed, else Windows PowerShell. Hooks start in `sh`, so on Windows they need Git Bash, which comes with Git for Windows.
- New `/quick-fix` command (`.claude/skills/quick-fix/`): one session from request to commit for small fixes, with limits (at most 3 files changed, no new files). `RULES.md` lists it under session types and the command table.
- The check scripts' usage notes show PowerShell 7 (`pwsh`) first, with Windows PowerShell 5.1 as the Windows fallback. The scripts run under both.
- License check as a Git pre-commit hook. New `.githooks/pre-commit` (project-owned) runs `check-credits.ps1 -Staged`, which checks only what's staged, against the staged `CREDITS.md`. Install turns the hook on when the project is already a Git repo. `RULES.md` says Claude never skips it with `--no-verify`.
- Kit settings: `RULES.md` has a new "Kit settings" section, read from `CLAUDE.md`: explanation level (`beginner` or `experienced`), Token use (`strict` or `normal`), and multiple-choice questions (`on` or `off`). Rules 8 and 9 and "Token use" follow them. The defaults match how the kit worked before. Install fills them from optional answers.
- Generic core: games, Unity, Godot, and Windows setup moved out of the core into add-ons (`creative-content`, `game`, `unity`, `windows` in the kit's `addons/`). Install copies an add-on's files with `-AddOns`, and records the add-ons on a new "Add-ons" line in `CLAUDE.md`.
- Rule 7 (creative content) is now off unless `CLAUDE.md` has a "Placeholder kinds" section, which the creative-content add-on adds.
- License check settings: `UnityBuiltInPackages` is replaced by `BuiltInPackages`, and the new `JsonPackageFiles` names JSON package files like Unity's `Packages/manifest.json`. `.bytes` and `.unitypackage` are no longer default asset types. The doc check no longer searches Godot file types by default.
- The check scripts find `.claude/kit/` and the settings file with `/` paths, so they can run outside Windows.
- `/pre-pro retrofit`: for a project that had code before the kit, surveys the code and drafts `DESIGN.md` and a roadmap for the remaining work.
- In the kit itself (not copied into projects): `/setup` installs the kit into a new or existing project, and install reads a personal profile (`personal/profile.psd1`).

### Manual steps

- For projects on the old layout: see the README, "Migrating from the old layout".
- **Required for projects that had a "Placeholder kinds" section in `CLAUDE.md`:** nothing, since rule 7 stays on. **Projects that turned rule 7 off** under "Project rules" can delete the "Placeholder kinds" section instead.
- **Required for Unity projects:** add the Unity add-on's settings to `.claude/kit-settings.psd1` (`addons/unity/README.md`), and rename any `UnityBuiltInPackages` or `ExtraUnityBuiltInPackages` setting to `BuiltInPackages` or `ExtraBuiltInPackages`. Without this, the check stops on the old name, or skips Unity's package list.
- **Required for Godot projects:** add `ExtraTextExtensions = @('.gd', '.tscn', '.tres', '.godot', '.gdshader')` to `.claude/kit-settings.psd1`, or the doc check stops searching those files for placeholders.
- Optional, to change the Kit settings: copy the "Kit settings" section from `template/CLAUDE.template.md` into `CLAUDE.md`, under the import line, and fill in the values. Without it, the defaults apply.
- Optional, to get the license hook: copy `template/dot-githooks/pre-commit` from the kit to `.githooks/pre-commit` in the project, run `git config core.hooksPath .githooks` there, and commit the hook. Outside Windows, also run `chmod +x .githooks/pre-commit`.
- Optional: if PowerShell 7 is installed, change the License check and Doc check commands in the Checks table in `CLAUDE.md` to `pwsh -NoProfile -File .claude/kit/tools/<script>.ps1`. The `powershell -NoProfile -ExecutionPolicy Bypass -File` form keeps working on Windows.
