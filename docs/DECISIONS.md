# Kit Development — Decisions

Add-only. Date, decision, reason, options rejected, who decided.

## 2026-10-27 — Kit's own plans live in `kit-dev/`

- **Decision:** the kit's design doc, roadmap and decision log for its own changes live in `kit-dev/`, not in the template files in `docs/`.
- **Reason:** `docs/DESIGN.md`, `docs/ROADMAP_STATUS.md` and `CLAUDE.md` are blank templates; filling them would ship the kit's change plan inside every copy.
- **Rejected:** filling in the templates (they'd need resetting before reuse); tracking outside the kit (the commands couldn't read it).
- **Decided by:** Ted.

## 2026-10-27 — No Git for now

- **Decision:** the kit stays out of Git for now.
- **Reason:** Ted's call.
- **Effect:** Step 1.5 (pre-commit hook) and Phase 4 (publish) wait; Build-track sessions end at a checked diff, not a commit.
- **Rejected:** starting a repo now.
- **Decided by:** Ted.

## 2026-10-27 — Update 1 approved; discussion command is `/talk`

- **Decision:** Update 1 (seven kit changes, four phases) approved as written, including the added Step 1.1 (kit-dev wiring). Change 1's command is `/talk`.
- **Reason:** matches the change brief; `/talk` is plain and doesn't clash with a built-in.
- **Rejected:** `/think` (reads like a request for deeper reasoning).
- **Decided by:** Ted.

## 2026-10-27 — The kit becomes its own project, with the product in `template/`

- **Decision:** the kit is developed in a new project in the kit folder. Its root `CLAUDE.md` holds the real rules for kit work, `docs/` holds the kit's own design doc, roadmap and decision log (copied from `kit-dev/`), and `template/` holds the product. Template files that Claude Code would load are renamed (`CLAUDE.template.md`, `dot-claude/`, `dot-gitattributes`), and install renames them back. The old kit stays as a read-only source.
- **Reason:** in the old kit the product and the instructions were the same files, so Claude Code loaded a blank template as its own rules, and the kit's real plan sat apart in `kit-dev/`. Claude Code loads `CLAUDE.md`, `AGENTS.md`, `.claude/skills/` and `.claude/rules/` from any subfolder once a file there is touched, so the template can't use those names.
- **Rejected:** restructuring the old kit in place; the name `workflow-starter-kit-v2` (easy to mix up with the old folder); keeping the real names in `template/` and hiding them with the `claudeMdExcludes` setting (it doesn't cover skills, and losing the setting makes them live without warning).
- **Decided by:** Ted.

## 2026-10-27 — Step 1.1 superseded by Phase 0

- **Decision:** Step 1.1 (kit-dev wiring) is superseded. A new Phase 0 (restructure) comes first in Update 1, numbered 0 so every existing step ID stays the same.
- **Reason:** with the kit's plans in this project's `docs/` and the product in `template/`, there's nothing left to wire.
- **Rejected:** building Step 1.1 as written (a `CLAUDE.local.md` or a note the commands check); renumbering the existing phases.
- **Decided by:** Ted.

## 2026-10-27 — Git is on

- **Decision:** the kit project is a local Git repo, with one commit per approved step. Nothing is pushed unless Ted asks. This replaces "No Git for now" above.
- **Reason:** each step is easy to review and undo, the update test can compare files with Git, and Step 1.5 no longer waits.
- **Rejected:** staying out of Git for now.
- **Decided by:** Ted.

## 2026-10-27 — Check-script settings move to a project-owned file

- **Decision:** the check scripts become kit-owned, in `.claude/kit/tools/`. Each project's settings for them (asset types, required docs, placeholder kinds, roadmap ID patterns) live in a project-owned `.claude/kit-settings.psd1`, and the scripts fall back to built-in defaults for any setting it lacks.
- **Reason:** an update replaces kit-owned files whole, so settings kept inside the scripts would be wiped. A PowerShell data file allows comments and works in both shells.
- **Rejected:** a settings block inside `CLAUDE.md` that the scripts parse (Markdown parsing breaks more easily); keeping the scripts project-owned (every script fix would need merging by hand in each project).
- **Decided by:** Ted.

## 2026-10-27 — Kit work runs in plain sessions

- **Decision:** the kit project has no session commands of its own. Each step is a plain session following the loop in `CLAUDE.md` ("How a step goes"): plan, Ted's approval, build, checks, self-review, docs, commit.
- **Reason:** Ted's call. It keeps one set of instructions in the kit project.
- **Rejected:** installing the template into the kit project itself, so kit work uses `/plan-it`, `/code` and `/review-fix-commit` (Claude's recommendation).
- **Decided by:** Ted.

## 2026-10-27 — Phase 0 plan approved

- **Decision:** the Phase 0 plan in `docs/plans/0-restructure.md` is approved as written. This includes:
  - the ownership rule: `.claude/kit/` and the kit's own skills are kit-owned, everything else is project-owned, and an update replaces kit-owned files only
  - versions starting at 1.0.0, where a major version means a required manual step
  - CHANGELOG entries with a "Manual steps" part that update prints and never carries out
  - install and update as PowerShell scripts run from the kit project
  - `TODO-DESIGN:` markers for design doc prompts, so double-brace blanks mean only "install fills this"
  - seven steps, one per session
- **Reason:** keeps kit updates apart from project customizations, which the old mixed layout couldn't do.
- **Rejected (in Claude's planning):** install and update done by Claude alone from a written guide (copying by hand is error-prone and hard to test).
- **Decided by:** Ted, approving Claude's plan.

## 2026-10-27 — The old kit README stays out of the new repo

- **Decision:** the old kit's `README.md` isn't copied in Step 0.2. It stays in the old kit as the source, and Steps 0.5 to 0.7 fold what's still true into the root `README.md`.
- **Reason:** it explains the kit and its setup, so it isn't a file a project keeps, and a second copy here would go stale.
- **Rejected:** a reference copy at `docs/old-README.md` (a second README that drifts); copying it into `template/` (every project would get a README about the kit).
- **Decided by:** Ted, choosing Claude's recommendation.

## 2026-10-27 — The game add-on's Git file is renamed too

- **Decision:** `game-addon/.gitattributes` is copied as `addons/game/dot-gitattributes`, the same rename rule as the template. Step 0.4 fixes the add-on README's wording.
- **Reason:** under its real name, its Git LFS rules would act on files inside `addons/game/` in the kit repo.
- **Rejected:** keeping `.gitattributes` (matches the add-on README today, but changes how Git treats the kit's own files).
- **Decided by:** Ted, choosing Claude's recommendation.

## 2026-10-27 — What the template check looks for

- **Decision:** `tools/check-template.ps1` fails on files named `CLAUDE.md`, `CLAUDE.local.md`, `AGENTS.md`, or `.gitattributes`, and on folders named `.claude`, anywhere in `template/` or `addons/`, in any letter case. It also fails if `template/` is missing. `.gitkeep` files keep their names.
- **Reason:** these are the names Claude Code loads from a subfolder (rules and skills sit inside `.claude`), plus the Git file that would act on the kit repo. Letter case is ignored because Windows ignores it. `.gitkeep` is loaded by nothing and changes nothing.
- **Rejected:** failing on every dot-file (would force renaming `.gitkeep` for no gain).
- **Decided by:** Claude, in the plan Ted approved.

## 2026-10-27 — Pre-production prompts in CLAUDE.md are TODO-DESIGN markers

- **Decision:** the template `CLAUDE.md`'s prompts that pre-production fills (where things stand, technical principles, code conventions, the Tests and Build commands, the environment) are `TODO-DESIGN:` markers. Install fills only four keys: `OWNER`, `PROJECT_NAME`, `PROJECT_ONE_LINE_DESCRIPTION`, and `REPO_PATH`.
- **Reason:** most of these can't be known before the stack is chosen, and the pre-production checklist already has an item for filling them.
- **Rejected:** making them install keys (install would ask for a test command and conventions before there's a stack).
- **Decided by:** Ted, choosing Claude's recommendation.

## 2026-10-27 — Rules split details

- **Decision:** in the rules split, the whole Checks table stays in `CLAUDE.md`, with the License and Doc check rows filled in with `.claude/kit/tools/` paths; `RULES.md` says only how the checks are used. The kit's doc map goes in `RULES.md`, and the project's own docs and long docs go under "Project docs" in `CLAUDE.md`. The template tracker starts at Pre-production with "none yet" as its Next sub-step.
- **Reason:** the skills keep pointing at one Checks table, the kit-owned doc map needs no project edits, and the doc check already accepts "none yet" in pre-production, so the tracker needs no setup note.
- **Rejected:** splitting the Checks table between the two files (the skills would need two places to look); keeping the "Write Production instead" prompt in the tracker (a prompt that isn't an install key or a design item).
- **Decided by:** Claude, in the plan Ted approved.

## 2026-10-27 — How the check settings combine with the defaults

- **Decision:** a setting in `.claude/kit-settings.psd1` replaces its built-in default, and each list setting also has an `Extra...` twin, such as `ExtraAssetExtensions`, that adds to the default. The template's settings file shows every setting as a comment, and the defaults live only in the scripts.
- **Reason:** add-ons and projects add a line instead of copying a long list, and kit updates to a default still reach every project that didn't replace it.
- **Rejected:** replace only (adding six engine types means copying a 60-item list); writing every default into the file (later kit changes to a default would never reach a project).
- **Decided by:** Ted, choosing Claude's recommendation.

## 2026-10-27 — How the doc check reports TODO-DESIGN markers

- **Decision:** the doc check counts `TODO-DESIGN` markers by file at every stage. Once the stage is past Pre-production, any left also become a note for the owner.
- **Reason:** the markers are expected during pre-production, and leftovers after it are worth seeing, but most sit in `DESIGN.md`, which only the owner edits, so they're a note rather than a problem.
- **Rejected:** only a count (leftovers are easy to miss); a problem that fails the check (Claude can't fix most of them).
- **Decided by:** Ted, choosing Claude's recommendation.

## 2026-10-27 — Check settings details

- **Decision:** the two checks share one kit-owned loader, `.claude/kit/tools/read-settings.ps1`, which knows every setting name. A name it doesn't know, or a settings file that won't parse, stops the check with a message. The owner's name comes from `CLAUDE.md`'s "Owner:" line, so the settings file holds no install blank. The license check runs Git from the project root with `--relative`.
- **Reason:** one list of setting names can't drift between the scripts, and a typo never passes quietly. Keeping the owner in `CLAUDE.md` keeps one place for it and keeps `template/dot-claude/` free of blanks. `--relative` keeps paths right when the project sits inside a bigger repo.
- **Rejected:** a copy of the loader in each script (two lists to keep in step); an `Owner` install blank in the settings file (a second place for the name, and a blank in `dot-claude/`).
- **Decided by:** Claude, in the plan Ted approved. The shared loader file is a build detail the plan didn't name.

## 2026-10-27 — The restructure is a one-off job, not Phase 0

- **Decision:** Phase 0 and its seven steps are dropped. The rest of the restructure (install, update, version, changelog, migration notes, and an install test) is finished in one session, without a roadmap, step plans, or "Done when" lines. Phase 0's plan files are deleted; `docs/` is back to the `kit-dev/` text, plus the fixes for the new layout. Install and update are one script, `tools/install.ps1`, with `-Update` replacing kit-owned files. Migration notes are a README section instead of `MIGRATING.md`, and there's no `MANIFEST` or edit detection for now: Git shows any local edit an update overwrites.
- **Reason:** Ted's call: the restructure is a one-off job, not a project.
- **Rejected:** finishing Steps 0.5 to 0.7 as planned.
- **Decided by:** Ted.

## 2026-10-28 — Update 1 changes 1 to 6 built as one batch

- **Decision:** changes 1 to 6 are built in one session as a one-off batch, like the restructure: no step plans and no "Done when" sign-offs, one commit per change, in roadmap order (Steps 1.2 to 1.5, then Phase 2, then Phase 3). `docs/ROADMAP_STATUS.md` is still ticked as each change lands; lines Ted must verify stay open with a dated note. If the session runs out, it stops after a finished change.
- **Reason:** Ted's call.
- **Rejected:** a short plan per change for Ted's OK (many more stops); the normal one-step-per-session loop.
- **Decided by:** Ted, choosing Claude's recommendation.

## 2026-10-28 — Open questions for Steps 1.4, 2.2, 2.5 and 3.1 answered

- **Decision:**
  - Step 1.4: the quick-fix lane changes at most 3 files and adds no new files.
  - Step 2.2: the game add-on stays in the public kit.
  - Step 2.5: Ted's personal copy is a profile file that install reads, kept out of the public repo (`personal/` is ignored by Git). A sample, `personal/example.psd1`, is committed so others can see the format.
  - Step 3.1: MIT license. Tip accounts are placeholders in `FUNDING.yml` and the tip line until Ted fills them.
- **Reason:** small, checkable limits keep the quick-fix lane from turning into feature work; the game add-on already edits only project-owned files; a profile file gets core updates with nothing to merge; MIT is short and widely used.
- **Rejected:** up to 5 files, or no file count (quick-fix); game add-on personal only; personal copy as a branch or a second repo; Apache-2.0.
- **Decided by:** Ted. Claude's recommendations, except the personal copy, where Ted added keeping it out of the public repo.

## 2026-10-28 — How the core became generic (Step 2.2)

- **Decision:**
  - **Add-ons** are folders in `addons/`: a `README.md` with the changes to project-owned files, an optional `files/` folder that install copies (safe names, replacing a template file at the same path), and an optional `addon.psd1` naming add-ons it needs. Install takes `-AddOns` and records the add-ons on an "Add-ons" line in `CLAUDE.md`. The edits to `CLAUDE.md` and the settings are made by `/setup`, or by hand from the README, not by install. Four add-ons: `creative-content`, `game` (needs `creative-content`), `unity`, `windows`.
  - **Rule 7 keeps its number** but is off unless `CLAUDE.md` has a "Placeholder kinds" section, which the creative-content add-on adds with the rule's wording. The skills say "when rule 7 is on".
  - **Unity support became two general settings,** `JsonPackageFiles` and `BuiltInPackages`, which the Unity add-on fills. Godot's text types moved to the game add-on's settings.
  - **Windows** stays named only where scripts support Windows PowerShell as a fallback (`run-ps.sh`, usage notes, a code comment). Windows setup steps moved to the Windows add-on.
  - The game add-on's docs use `TODO-DESIGN:` markers instead of prose blanks, so double braces mean only "install fills this".
- **Reason:** keeping rule numbers stable means no skill or project rule that says "rule 7", "rule 8" or "rule 9" breaks. Text edits to `CLAUDE.md` vary by project, which Claude handles better than a script. General settings keep the Unity feature without naming Unity in the core.
- **Rejected:** removing rule 7 and renumbering; install editing `CLAUDE.md` sections itself; dropping Unity package support.
- **Decided by:** Claude, within the batch Ted approved.

## 2026-10-28 — Publish prep: generic names and a fresh history

- **Decision:** before the repo goes public, home paths become "the kit folder" or `<kit folder>`; the private game's name becomes "a game project", and the Step 4.3 case study waits until that game is public; the copyright holder is ThatTedGuy; the tip account is Ko-fi (`thattedguy`); commits use the name ThatTedGuy and GitHub's noreply email; `main` starts over as one commit, "Workflow kit 1.0", with the old history kept in a backup folder outside the repo. The path in the 2026-10-27 "new project" entry above was edited too, an exception to add-only, so no home path is published.
- **Reason:** the public repo shouldn't show Ted's email, home folder layout, or private project names, and the old commits had all three.
- **Rejected:** rewriting the old commits with `git filter-repo` (keeps the history, but needs an extra tool and a check of every commit); keeping the game's name.
- **Decided by:** Ted.

## 2026-10-28 — Version 1.0.1, and the shipped "Unreleased" changes folded into 1.0.0

- **Decision:** `/code`, `/review-fix-commit`, `/talk` and `/quick-fix` each name their list under "Project additions to the commands", like `/plan-it` and `/qa-docreview`. The "Unreleased" changelog entries, which shipped in the 1.0.0 template, move into the 1.0.0 entry. The new 1.0.1 entry lists only the command fix, and `VERSION` is 1.0.1. "Unreleased" stays as an empty heading for the next changes.
- **Reason:** an explicit line in each command is harder to miss than the general line in `RULES.md`. Update prints only numbered entries newer than the project's version, so listing the shipped changes under 1.0.1 would have shown 1.0.0 projects changes they already have, with "Required" manual steps. A patch with no manual steps also fits the changelog's version rules.
- **Rejected:** putting all the Unreleased changes under 1.0.1.
- **Decided by:** Ted.
