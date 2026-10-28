# Game add-on

Optional extras for a game project. The core kit is deliberately generic; this adds what games need:

- **Lore and in-game text** stay the owner's, with `TODO-LORE` and `TODO-TEXT` placeholders and a table of when each piece of lore is needed.
- **The AI-content rule:** AI-made art and sound only as a last resort, and never AI-made text, voices, or lore.
- **A performance budget:** target hardware and frame-time limits, checked at every phase gate.
- **Git LFS** for models, textures, audio, and fonts.

**Needs:** the creative-content add-on (this one changes its rule 7 and placeholder kinds). For a Unity game, add the Unity add-on too.

Pick it when installing (`/setup`, or `-AddOns creative-content,game`), before pre-production starts. Install copies the files in step 1; `/setup` then makes steps 2 to 4. By hand, or for a project installed without it, ask Claude in the project: "Apply the game add-on, following `addons/game/README.md` in the kit."

It changes only files the project owns: `CLAUDE.md`, `.claude/kit-settings.psd1`, `.gitattributes`, and `docs/`. It never edits the kit's own rules, skills, or check scripts, so kit updates keep working.

## 1. Files (install copies these)

| From `addons/game/files/` | To the project |
| --- | --- |
| `docs/LORE_BIBLE.md` | `docs/LORE_BIBLE.md` |
| `docs/PERFORMANCE.md` | `docs/PERFORMANCE.md` |
| `dot-gitattributes` | `.gitattributes`, replacing the kit's |

Git LFS has to be installed (https://git-lfs.com). Run `git lfs install --local` once in the project after `git init`. Fill in the engine section of `.gitattributes` with your engine's binary file types.

## 2. Change `CLAUDE.md`

In "Kit settings", the "Add-ons" line lists `game`.

**Under "Project rules",** replace the creative-content add-on's rule 7 line with the first rule below, and add the second:

> - **Rule 7, for lore:** the owner owns the lore. Use clearly marked placeholders such as `TODO-LORE: name of nation A` for names and story text, and never invent canon. In-game text, such as UI labels, tooltips, item descriptions, and tutorial text, uses `TODO-TEXT: what it is`, or the exact words the owner gives. Debug-only text that never ships is fine.
> - **Rule 10, new: AI-generated content only as a last resort, and only for art and sound.** Claude writes code, shaders, tests, tools, data, tuning numbers, and internal docs. Everything players see or hear is made by people or comes from properly licensed sources (rule 6), with one exception: art and sound (models, textures, UI art, sound effects, ambience, and music) may be AI-generated when no free option can be found. Claude first searches CC0 and creditable sources, then shows the owner what it found and asks before making anything, every time (rule 9). Each AI-generated asset's `CREDITS.md` entry says "Generated with <tool>", and an `AI use:` line says where Claude looked and when the owner approved it. Stores such as Steam need an AI disclosure for these, and `CREDITS.md` is the list for it. Text, voices, and lore are always made by people.

**Under "Placeholder kinds",** replace the `TODO-CONTENT` line with:

> - `TODO-LORE`: names, factions, places, and story.
> - `TODO-TEXT`: in-game text, such as UI labels, tooltips, item descriptions, and tutorial text.

**Under "Technical principles",** add:

> - **A performance budget.** Pre-production sets the target hardware and frame-time budget, and every phase gate checks it. Both are in `docs/PERFORMANCE.md`.

**Under "Project docs":**

- Add `docs/LORE_BIBLE.md` and `docs/PERFORMANCE.md` to the long docs.
- Add these rows to the table:

> | `docs/LORE_BIBLE.md` | Names, factions, places, story, and the "When lore is needed" table | The owner only |
> | `docs/PERFORMANCE.md` | Target hardware, frame-time budget, memory limits, how to measure, and the results log | Claude; the owner approves changes to the specs, totals, or target |

**Under "Project additions to the commands,"** replace each "None." with:

- **`/pre-pro`, design items:**

  > - **Performance item:** fill in `docs/PERFORMANCE.md` with the owner: the target hardware, the target frame rate, and the split by system. Ask the choices as multiple choice (rule 9).

- **`/plan-it`, extra reading:**

  > - For work that costs frame time or memory, such as rendering, physics, or simulation, read `docs/PERFORMANCE.md` for the budget it must fit.
  > - **Lore needed:** read the "When lore is needed" table in `docs/LORE_BIBLE.md`. If it lists this sub-step and the entry is still `TODO-LORE`, add an open question asking the owner for it, with keeping the placeholder for now as one option. Never suggest names or story text as options (rule 7); research-backed facts are fine.

- **`/qa-docreview`, extra QA:**

  > - At a phase gate, measure the phase's worst case against `docs/PERFORMANCE.md` ("How to measure"), and add a row to its results log.

## 3. Change the tracker

In `docs/ROADMAP_STATUS.md`, add to the pre-production checklist:

- `- [ ] Target hardware and frame-time budget set in docs/PERFORMANCE.md`
- `- [ ] "When lore is needed" table filled in, in docs/LORE_BIBLE.md`

## 4. Change the check settings

In `.claude/kit-settings.psd1`, add these lines inside the `@{ }`, or uncomment the matching examples there. If another add-on already set one of them, add to its list instead:

```
ExtraRequiredDocs    = @('docs/LORE_BIBLE.md', 'docs/PERFORMANCE.md')
PlaceholderKinds     = @('TODO-LORE', 'TODO-TEXT')
ExtraPlaceholderSkip = @('docs/LORE_BIBLE.md')
ExtraAssetExtensions = @('.scn', '.res', '.material', '.anim', '.mesh', '.lmbake')
ExtraTextExtensions  = @('.gd', '.tscn', '.tres', '.godot', '.gdshader')
```

- `ExtraPlaceholderSkip` leaves out `docs/LORE_BIBLE.md` because it lists what's still open rather than using placeholders.
- `ExtraAssetExtensions` holds the engine's binary file types, the same ones as `.gitattributes`. `ExtraTextExtensions` holds the engine's text file types, so the doc check finds placeholders in them. The lines above are for Godot; use your engine's.
