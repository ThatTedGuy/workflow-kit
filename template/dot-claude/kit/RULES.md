# Kit rules

The workflow kit's rules, the same in every project. `CLAUDE.md` imports this file and names the project, its owner, and its repo path. "The owner" below means the owner named there.

**This file is kit-owned:** a kit update replaces it, along with everything else in `.claude/kit/` and the kit's own skills in `.claude/skills/`. Don't edit kit-owned files in a project. Project changes go in `CLAUDE.md`, and where its "Project rules" change a rule here, `CLAUDE.md` wins.

**`docs/DESIGN.md` is the single source of truth for v1.** Build only what it lists, in roadmap order, one sub-step per session. Before making any design call, read its Vision and Design pillars.

## Rules for every session

1. **Work one sub-step at a time, in order.** A step is finished only when its "Done when" line is true. If asked to work on a sub-step that is not next, say which one is next and ask before going on.
2. **Check scope before planning.** If a task is not in "v1 scope", or is listed in "Not in v1", stop and flag it instead of building it.
3. **New ideas go in the parking lot** (`docs/AFTER_V1.md`), never into the code. Only the owner moves items between v1 and After v1.
4. **Log every decision** in `docs/DECISIONS.md`: date, decision, reason, options rejected, and who decided.
5. **Mark finished sub-steps** in `docs/ROADMAP_STATUS.md` in the same commit as the work, and update its "Next sub-step" line.
6. **Licenses:** use only CC0, public domain, CC-BY, MIT, BSD, Apache-2.0, or zlib. Log every third-party asset, library, dataset, or borrowed code in `CREDITS.md` *before* using it. Ask the owner before using anything with another license, such as GPL, CC-BY-SA, NonCommercial, or an unclear one.
7. **Creative content, when the project turns it on.** Off unless `CLAUDE.md` has a "Placeholder kinds" section, as the creative-content add-on adds. When it's on, the owner owns the content that section names, such as names, user-facing text, and story: use its placeholders, such as `TODO-CONTENT: product name`, and never invent that content.
8. **Explain choices in plain language**, and tell the owner exactly how to test each result, at the "Explanation level" in Kit settings. When test steps use a terminal, the first command moves into the repo folder: `cd` to the repo path in `CLAUDE.md`. This goes in plans, QA reports, and chat.
9. **Ask the owner questions as multiple-choice prompts** (the `AskUserQuestion` tool), not only in chat text, unless "Multiple-choice questions" is off in Kit settings. Give 2 to 4 options, put the recommended one first with "(Recommended)" after its label, and give each option's trade-off in one line. A question with no sensible options, such as asking for a link, can be plain text. Plans and QA reports still write the questions and answers down, so there's a record.

Also:

- **Never edit `docs/DESIGN.md` unless the owner asks.** If it looks wrong or out of date, list that as a note for the owner.
- Every feature must serve at least one design pillar. A feature that serves none goes to the parking lot.
- Never push to a remote unless the owner asks.

## Kit settings

`CLAUDE.md` sets these under "Kit settings", and every command follows them. A missing or unknown value means the default.

| Setting | Values | What it changes |
| --- | --- | --- |
| Explanation level | `beginner` (default), `experienced` | Rule 8. **Beginner:** explain each choice and any technical term in plain words, and give test steps one action at a time, with every command written out. **Experienced:** brief, and technical terms are fine; test steps can be a short list. Either way, always say how to test. |
| Token use | `strict` (default), `normal` | "Token use" below. **Strict:** every point there applies. **Normal:** reading a whole file is fine when searching would take longer, but still don't re-read unchanged files, and still keep sessions short. |
| Multiple-choice questions | `on` (default), `off` | Rule 9, and every command that says "multiple-choice prompt". **On:** ask with the `AskUserQuestion` tool. **Off:** ask in chat as a short numbered list, recommended option first with its trade-offs, and wait for the answer. |

## Stages

The project moves through three stages, in order. The "Stage:" line in `docs/ROADMAP_STATUS.md` says which one it's in, and only the owner moves it on. Each stage changes what work is allowed.

| Stage | What happens | Sessions | Rules that change |
| --- | --- | --- | --- |
| **Pre-production** | Ideas, research, the stack or engine choice, and throwaway prototypes, until `docs/DESIGN.md` and its roadmap are written and approved | `/pre-pro` | `DESIGN.md` is a draft, so rules 1, 2, and 5 wait. Prototype code lives only in `prototypes/`, needs no tests, and never moves into the real code: production rebuilds it properly. Licenses (rule 6) and creative content (rule 7) apply in full |
| **Production** | The v1 roadmap, one sub-step at a time, through polish and release | Build and Quality tracks | All rules apply |
| **Post-production** | After v1 ships: bug-fix patches, and updates (v1.1, v2, and so on) built from ideas in the parking lot, one update at a time | `/pre-pro` plans each update; then the Build and Quality tracks | Each update gets its own scope and phases under "Updates after v1" in `DESIGN.md`, approved by the owner before building. While an update is being built, rules 1 to 3 read "v1 scope" as that update's scope. Bug fixes can go in any time through the Quality track |

Only the owner moves the project on. Pre-production ends when its checklist in `docs/ROADMAP_STATUS.md` is all ticked. Production ends when v1 is released, at the gate of the roadmap's last phase. Post-production has no end: it runs for as long as the owner keeps updating the project.

## Token use

The owner's usage limit sets the project's pace, so sessions spend tokens carefully. Each turn re-sends the whole conversation, so what's read stays in the cost until the session ends. Never trade away quality or tests to save tokens. How strictly these apply is the "Token use" value in Kit settings.

- **Read only what's needed.** Search for a heading or name first, then read that range. Don't read whole long docs (`docs/DESIGN.md`, `docs/DECISIONS.md`, and the "Long docs" listed in `CLAUDE.md`) or print several whole files in one command. Don't re-read a file that's already in the conversation and unchanged.
- **Keep sessions short.** `/plan-it` splits big sub-steps into build parts, and `/code` builds one part per session. Start a new chat for an unrelated topic.
- **Keep long docs easy to search.** Give a long reference doc a contents table at the top. When `docs/DECISIONS.md` grows long, move a finished phase's entries, unchanged, to `docs/DECISIONS_PHASE_<n>.md`, and add it to "Project docs" in `CLAUDE.md`.

## Session types and commands

- **Pre-production:** `/pre-pro`, one checklist item per session, until the design doc is approved. In Post-production, `/pre-pro` also plans each update.
- **Build track** (one sub-step): `/plan-it` → `/code` → `/review-fix-commit`, each in its own session.
- **Quality track:** `/qa-docreview` → `/code` → `/review-fix-commit`. Run it at every phase gate, and whenever bugs or doc drift pile up.
- **Discussion:** `/talk`, any time, at any stage, for ideas, questions and concerns. Read-only, in its own session.
- **Quick-fix lane:** `/quick-fix`, one session from request to commit, for a typo, wording, a config or tuning value, or a small bug whose cause is known. Limits: at most 3 files changed, no new files, and no feature, design change, new dependency, or owner decision. Anything bigger goes to the Build or Quality track. Quick fixes don't touch the roadmap.

| Command | What it does | What it writes |
| --- | --- | --- |
| `/pre-pro [item, question, or version]` | Works one pre-production item: drafts a design doc section from the owner's notes, researches a question, or builds a throwaway prototype. For a project that had code before the kit, `/pre-pro retrofit` drafts the design doc and roadmap from that code. In Post-production, plans the next update | A `DESIGN.md` draft section, `docs/preprod/`, or `prototypes/<slug>/` |
| `/plan-it [sub-step]` | Plans the next sub-step and runs the v1 scope check. No code. | `docs/plans/<id>-<slug>.md` |
| `/code [plan or report]` | Builds an approved plan, or a QA report's fixes. No commit. | Code and tests; updates the plan |
| `/review-fix-commit [plan or report]` | Reviews, fixes, runs the license check, updates the docs, then commits. | A commit |
| `/qa-docreview [focus]` | Runs QA and the doc-drift check. Changes no code. | `docs/qa/<date>-<focus>.md` |
| `/quick-fix [what to fix]` | Checks the request against the quick-fix limits, fixes it, runs the checks, reviews its own diff, then commits. Redirects anything bigger | A commit |
| `/talk [topic]` | Talks an idea, question or concern through. Read-only: a hook blocks shell commands and every edit except the parking lot and decision log, for the rest of the session. Ends with a wrap-up of ideas, decisions, open questions and design doc notes | Rows in `docs/AFTER_V1.md` and `docs/DECISIONS.md`, only with the owner's OK |

The plan command is `/plan-it` so that Claude Code's built-in `/plan` (plan mode) still works.

Each command also follows its list under "Project additions to the commands" in `CLAUDE.md`.

**Technical principles and code conventions** are in `CLAUDE.md`. Every change has to respect them, and `/review-fix-commit` and `/qa-docreview` check them.

## Doc map

The kit's standard docs and files. The project's own docs are under "Project docs" in `CLAUDE.md`.

| File | What it is | Who edits it |
| --- | --- | --- |
| `docs/DESIGN.md` | Design doc and v1 roadmap; the single source of truth | The owner (Claude only when asked) |
| `docs/ROADMAP_STATUS.md` | Progress tracker | Claude ticks finished sub-steps |
| `docs/DECISIONS.md` | Decision log, add-only | Claude and the owner |
| `docs/AFTER_V1.md` | Parking lot for new ideas | Claude adds rows; the owner moves ideas into versions |
| `docs/preprod/NOTES.md` | The owner's raw ideas and notes, in any order | The owner (Claude adds only when asked) |
| `docs/preprod/QUESTIONS.md` | What pre-production must answer, and the answers found by research and prototypes | `/pre-pro`; the owner approves answers |
| `prototypes/` | Throwaway prototypes, one folder each; deleted or left out of the build once production starts | `/pre-pro` |
| `docs/plans/` | One plan per sub-step | `/plan-it`, `/code`, `/review-fix-commit` |
| `docs/qa/` | QA reports | `/qa-docreview`, `/code`, `/review-fix-commit` |
| `CREDITS.md` | Every third-party asset, library, dataset, and borrowed piece of code | Claude, before use |
| `CLAUDE.md` | The project's name, owner, project rules, principles, conventions, checks, and environment | Claude and the owner |
| `.claude/kit/` | These rules, the kit's `VERSION`, the check scripts (`tools/check-credits.ps1`, `tools/check-docs.ps1`, and the `tools/read-settings.ps1` they share), `/talk`'s guard (`tools/talk-guard.ps1`), and `tools/run-ps.sh`, which runs a kit script with `pwsh` or Windows PowerShell | Kit-owned: replaced by kit updates |
| `.githooks/pre-commit` | The Git hook that runs the License check before each commit (see "Checks") | The owner, to add project checks below the kit's |
| `.claude/kit-settings.psd1` | The project's settings for the checks, such as extra asset types, required docs, placeholder kinds, and roadmap IDs. Any setting it lacks uses the script's default | Claude and the owner. Never edit the check scripts for this |
| `.claude/skills/` | The kit's session commands, listed above | Kit-owned: replaced by kit updates. Skills the project adds itself are project-owned |

## Checks

The session commands run the checks in the "Checks" table in `CLAUDE.md`. A check that says `none` doesn't exist yet, so Claude does that check by hand instead.

A Git pre-commit hook, `.githooks/pre-commit`, also runs the License check on what's staged, and blocks a commit with an uncredited asset or package. It's on when `git config core.hooksPath` says `.githooks`. `/review-fix-commit` still runs the check itself. **Claude never skips the hook** (`--no-verify`): only the owner may, by hand.
