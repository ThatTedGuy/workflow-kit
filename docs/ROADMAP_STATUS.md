# Kit Development — Roadmap Status

Progress against Update 1 in [DESIGN.md](DESIGN.md). Tick a sub-step `[x]` when its work is done. Lines Ted must check personally say "(Ted verifies)".

**Stage:** Post-production: Update 1 approved (Ted, 2026-10-27).

**Next sub-step:** Ted's checks and fill-ins for changes 1 to 6 (see the 2026-10-28 notes below), then 2.4.1's lessons from Ted's retrofitted games. Phase 4 (publish) waits for Ted. (Update 1 changes 1 to 6 were built as one batch: see `DECISIONS.md`, 2026-10-28.)

## Update 1 — Seven kit changes

### Phase 1 — Small changes

- [x] ~~1.1.1 Kit-dev wiring~~ Superseded by the restructure (Ted, 2026-10-27)
- [x] ~~Done when (1.1): `/plan-it` in the kit folder reads `kit-dev/`; a fresh copy doesn't mention it~~ Superseded
- [x] 1.2.1 Discussion session (`/talk`)
- [ ] Done when (1.2): see DESIGN.md (Ted verifies: a test session can't change a code file)
- [x] 1.3.1 Scripts run under `pwsh` and Windows PowerShell
- [x] 1.3.2 Checks table and README note
- [ ] Done when (1.3): same results under both shells (Ted verifies)
- [x] 1.4.1 Quick-fix lane
- [ ] Done when (1.4): see DESIGN.md (Ted verifies in a real session)
- [x] 1.5.1 Pre-commit hook (needs Git)
- [ ] Done when (1.5): see DESIGN.md (Ted verifies under `pwsh`)
- [ ] **Phase 1 gate**

### Phase 2 — Generic kit

- [x] 2.1.1 Settings block
- [x] 2.2.1 Windows and PowerShell add-on
- [x] 2.2.2 Creative-content add-on
- [x] 2.2.3 Strip specifics from the core
- [x] 2.3.1 `/setup`
- [ ] 2.4.1 Retrofit path
- [x] 2.5.1 Ted's personal copy (works on a game project: Ted verifies)
- [ ] **Phase 2 gate**

### Phase 3 — License and funding

- [x] 3.1.1 `LICENSE`, `FUNDING.yml`, tip line, credits
- [ ] **Phase 3 gate**

### Phase 4 — Publish (needs Git)

- [ ] 4.1.1 Public repo
- [ ] 4.2.1 Example project released
- [ ] 4.3.1 Case study (waits until the game is public)
- [ ] **Phase 4 gate** (Ted verifies)

## Notes

- 2026-10-27: the kit isn't a Git repo yet, so Step 1.5 and Phase 4 wait, and Build-track sessions stop at a checked diff instead of a commit.
- 2026-10-27: the kit moved from the old kit's `kit-dev/` into this project's `docs/`, with the product in `template/`, as a one-off restructure (no phase or steps). Git is on, local only, so Step 1.5 no longer waits for it. Phase 4 still needs Ted's say-so to push.
- 2026-10-28: 1.2.1 built. The `/talk` guard passed tests with sample tool calls; Ted checks it in a real session: run `/talk`, ask it to edit a code file, and it should be blocked.
- 2026-10-28: 1.3.1 and 1.3.2 built. The check scripts needed no code changes; the install test and install script now run under either shell. Tested under Windows PowerShell 5.1 only, since `pwsh` isn't installed. Ted verifies Done when (1.3): install PowerShell 7 (`winget install Microsoft.PowerShell`), then run `tools/test-install.ps1` with `pwsh` and with `powershell`, and compare.
- 2026-10-28: 1.4.1 built. Ted verifies Done when (1.4) in an installed test project: `/quick-fix` a typo (it should commit with checks passing), then `/quick-fix` a small feature (it should refuse and suggest `/plan-it`).
- 2026-10-28: 1.5.1 built. The install test now commits in a throwaway repo: an uncredited asset is blocked, a credited one goes through. Tested with Windows PowerShell; Ted verifies the "either shell" part once `pwsh` is installed, by running the install test with it.
- 2026-10-28: 2.1.1 built. Ted verifies Done when (2.1) in an installed test project: set each Kit setting to its other value in `CLAUDE.md` and check a session changes (shorter explanations, whole-file reads allowed, questions as a numbered list in chat).
- 2026-10-28: 2.2.1 to 2.2.3 built. Done when (2.2) checked: a search of `template/` finds no mention of Ted, Windows paths, games, Unity or Godot. "Windows" appears only where scripts support Windows PowerShell as a fallback.
- 2026-10-28: 2.3.1 built: `/setup` lives in the kit's own `.claude/skills/setup/`, since it runs before a project has the kit. The install test checks that a project installed with add-ons passes the doc check. Ted verifies Done when (2.3): run `/setup` in the kit folder for a scratch project and get a passing doc check.
- 2026-10-28: 2.4.1 partly built: `/pre-pro retrofit`, the retrofit item `/setup` adds, and the README's two entry points (new and existing project). Left open: "what worked on Ted's two retrofitted games" isn't written down yet, so the retrofit step comes from general practice. Ted supplies those lessons, then verifies Done when (2.4) on a small existing project.
- 2026-10-28: 2.5.1 built: Ted's personal copy is `personal/profile.psd1` (owner Ted, the default Kit settings, and the `windows` and `creative-content` add-ons), which Git ignores; core updates come from the kit itself, with nothing to merge. Ted verifies Done when (2.5): the game project is still on the old layout, so this means migrating it (README, "Migrating from the old layout"), which is Ted's call.
- 2026-10-28: 3.1.1 built: MIT `LICENSE` (copyright "Ted", from Git's user name), `.github/FUNDING.yml` with every account commented out, the tip line at the end of the README, and a `CREDITS.md` note that the kit borrows nothing. Left for Ted (Done when 3.1): the copyright name if "Ted" isn't the one he wants, his tip accounts in `FUNDING.yml`, and the tip link in the README. The kit has no assets, packages, or vendored code, checked by hand, since the license check runs inside a project, not on the kit.
- 2026-10-28: publish prep (see `DECISIONS.md`): generic paths, "a game project" in place of the game's name, copyright ThatTedGuy, Ko-fi in `FUNDING.yml` and the README tip line, and a fresh one-commit history. This fills in what 3.1.1 left for Ted. Nothing is pushed: Phase 4 still waits for Ted.
