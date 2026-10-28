# Workflow Starter Kit — Kit Development Design

The design doc for changes to the kit itself. The product that other projects fill in lives in `template/`, so the kit's own plans live here in `docs/` and stay out of copies of the kit.

Source: "Workflow Kit Change Brief" (Ted, 2026-10-27).

## Update 1 — Seven kit changes

**Status:** Approved (Ted, 2026-10-27).

### Scope

Built smallest first, so the generic version (Phase 2) includes the small changes. Sizes are rough estimates.

1. **Discussion session** (`/talk`). A sixth command for ideas, questions and concerns. Read-only: never edits code, runs builds, or commits. Enforce this with `allowed-tools` if the skill format supports it. Offers to add new ideas to `docs/AFTER_V1.md` and adds only with the owner's OK. Ends with a wrap-up: ideas to park, decisions made (for `docs/DECISIONS.md`), open questions, and notes on anything in `docs/DESIGN.md` that looks wrong. Follows the Token use rules. `disable-model-invocation: true`. Small.
2. **License check as a Git pre-commit hook.** Hook kept in the repo (for example `.githooks/`), turned on with `core.hooksPath`, and calls the existing `check-credits.ps1`. Setup gets an install step. `/review-fix-commit` still runs the check itself. Small. **Blocked until the kit is a Git repo.**
3. **Checks run under PowerShell 7 (`pwsh`).** Remove Windows-only assumptions from `check-credits.ps1` and `check-docs.ps1`. The Checks table uses `pwsh`, with Windows PowerShell as the fallback. The README's execution-policy note says it applies only on Windows. The hook from change 2 picks the right shell. Small to medium.
4. **Quick-fix lane.** A one-session command for typos, wording, a config or tuning value, or a small bug whose cause is known. Not new features, design changes, new dependencies, or anything needing a design decision. Claude checks the request against the limits, fixes, runs the checks, reviews its own diff, logs any decision, and commits without touching the roadmap. If the fix grows past the limits, it stops and suggests `/plan-it` or the Quality track. Medium.
5. **Generic core, add-ons, settings, `/setup`, retrofit path.** The core names no person, path, language, operating system, engine or project type. Specific parts become add-ons, following the `game-addon/` pattern: games, Unity, Windows and PowerShell setup, and the creative-content rule (rule 7). Ted's habits become settings in one marked place: explanation level (beginner or experienced), Token use strictness, and multiple-choice questions on or off. A `/setup` command asks a few questions and fills the `{{...}}` blanks. The README gives separate paths for a new project and an existing one; the retrofit step reads an existing codebase and drafts `DESIGN.md` and the roadmap for the owner to approve. Ted keeps a personal copy with his settings and add-ons that takes core updates. Large.
6. **License, `FUNDING.yml`, tip line.** A `LICENSE` file, `.github/FUNDING.yml` with Ted's tip accounts, one tip line at the end of the README, and `CREDITS.md` covering anything the kit borrowed. Small.
7. **Publish on GitHub with a worked example.** A public repo with history, a small non-game example project built from `/pre-pro` to a released v1 with the kit, and a README case study with one example from a game project that Ted supplies, once that game is public. Optional: one sub-step through the full loop on a retrofitted game. Medium to large. **Needs Git.**

### Not in this update

- A rewrite of the checks in another language (change 3 only makes the PowerShell scripts portable).
- Testing on Mac or Linux. The README says they're expected to work but untested, until someone tests them.
- Changes to a game project itself, beyond checking that Ted's personal copy still works on it.

### How kit work runs

Kit work happens in the kit folder. The product is in `template/`, under names Claude Code doesn't load, so it's never live there. The kit's own design doc, roadmap, and decision log are in `docs/`. The kit has no session commands of its own: each step is a plain session that follows the loop in `CLAUDE.md` ("How a step goes"). The one-off restructure on 2026-10-27 set this layout up, in place of Step 1.1.

### Phases

#### Phase 1 — Small changes

##### Step 1.1 — Kit-dev wiring

**Superseded by the restructure (Ted, 2026-10-27).**

- 1.1.1 Point sessions working on the kit at `kit-dev/` (for example a `CLAUDE.local.md` or a note the commands check), without changing what a fresh copy of the kit sees.

Done when: a `/plan-it` session in the kit folder reads its sub-step from `kit-dev/ROADMAP_STATUS.md`, and a fresh copy of the kit doesn't mention `kit-dev/`.

##### Step 1.2 — Discussion session (change 1)

- 1.2.1 Add the skill, and describe it in `CLAUDE.md` (session types, command table, doc map) and the README.

Done when: `template/dot-claude/skills/<name>/` exists with a name that doesn't clash with a Claude Code built-in; a test session can't change a code file; its wrap-up lists ideas, decisions, questions and design notes; `CLAUDE.md` and the README describe it.

##### Step 1.3 — Portable checks (change 3)

- 1.3.1 Make `check-credits.ps1` and `check-docs.ps1` run under `pwsh` and Windows PowerShell.
- 1.3.2 Update the Checks table and the README's execution-policy note.

Done when: both scripts give the same results under `pwsh` and Windows PowerShell on Ted's machine (Ted verifies), and the README says Mac and Linux are expected to work but untested.

##### Step 1.4 — Quick-fix lane (change 4)

- 1.4.1 Add the command, with the limits Ted sets, and list it in `CLAUDE.md` and the README.

Done when: a typo fix goes from request to commit in one session with checks passing (or to a finished, checked diff while there's no Git); a request that's really a feature is redirected, not built; `CLAUDE.md` and the README list the lane and its limits.

##### Step 1.5 — Pre-commit hook (change 2, needs Git)

- 1.5.1 Add the hook, the install step, and the README section.

Done when: a manual `git commit` adding an asset with no `CREDITS.md` entry is blocked with a message saying how to fix it; a commit with the entry goes through; the hook works under either shell; the README covers installing it and says `--no-verify` skips it, for the owner's use only; `/review-fix-commit` still runs the check itself.

**Phase 1 gate:** Steps 1.2 to 1.4 done. Step 1.5 is done, or Ted has moved it to wait for Git. A QA pass on the kit.

#### Phase 2 — Generic kit (change 5)

##### Step 2.1 — Settings

- 2.1.1 One marked settings block for explanation level, Token use strictness, and multiple-choice questions, with the commands reading it.

Done when: changing each setting changes how a session behaves, and the defaults match how the kit works today.

##### Step 2.2 — Core and add-ons

- 2.2.1 Move Windows and PowerShell setup into an add-on.
- 2.2.2 Move the creative-content rule into an add-on.
- 2.2.3 Strip games, Unity, names and paths from the core; tidy `game-addon/`.

Done when: a search of the core files finds no mention of Ted, Windows paths, games or Unity.

##### Step 2.3 — Guided setup

- 2.3.1 Add `/setup`, which asks a few questions, fills the blanks, picks add-ons, and installs the hook if Git is there.

Done when: `/setup` takes a fresh copy to a passing doc check without hand-editing placeholders.

##### Step 2.4 — Retrofit path

- 2.4.1 Write down what worked on Ted's two retrofitted games, then add the retrofit step and the README's two entry points.

Done when: the retrofit path, run on a small existing project, produces a draft design doc and roadmap the owner can approve.

##### Step 2.5 — Ted's personal copy

- 2.5.1 Set up the personal copy with Ted's settings and add-ons, and a way to take core updates.

Done when: Ted's personal copy still works on a game project (Ted verifies).

**Phase 2 gate:** every Phase 2 "Done when" line is true, and a QA pass on the kit.

#### Phase 3 — License and funding (change 6)

##### Step 3.1 — License, funding, tip line

- 3.1.1 Add `LICENSE`, `.github/FUNDING.yml`, the tip line, and any missing `CREDITS.md` entries.

Done when: `LICENSE` and `.github/FUNDING.yml` exist with Ted's real account names; the README has the tip line once, at the end; the license check passes with `-All`.

**Phase 3 gate:** Step 3.1 done.

#### Phase 4 — Publish (change 7, needs Git)

##### Step 4.1 — Public repo

- 4.1.1 Push the generic kit to a public GitHub repo (only on Ted's say-so).

##### Step 4.2 — Example project

- 4.2.1 Build the example project from `/pre-pro` to a released v1 with the kit. This is its own project, with its own roadmap; this sub-step tracks only that it's finished.

##### Step 4.3 — Case study

- 4.3.1 Add the README case study and the link to the example. The case study waits until the game it draws on is public; until then, the README links only the example.

Done when: the repo is public with the license, Sponsor button and README in place; the example went from `/pre-pro` to a released v1 through the kit's commands, and its history shows it; the README links the example, and includes the case study from a game project once that game is public.

**Phase 4 gate:** Update 1 released: the public repo matches the generic kit, and Ted has checked the page (Ted verifies).

### Open questions

Each is answered before its step is planned. None blocks Step 1.2.

- ~~Step 1.2: command name~~ Answered 2026-10-27: `/talk`.
- Step 1.4: exact limits for the quick-fix lane, such as a maximum number of files changed?
- ~~Step 1.5 and Phase 4: when does the kit become a Git repo?~~ Answered 2026-10-27: now, as a local repo. Pushing still needs Ted's say-so.
- Step 2.2: keep the game add-on in the public kit, or personal only?
- Step 2.5: personal copy as a second repo, or a branch of the generic one?
- Step 3.1: MIT or another license, and which tip accounts?
- Step 4.2: which small non-game project for the example?
- Step 4.3: which moment from a game project best shows the workflow catching a problem? (Waits until the game is public.)
