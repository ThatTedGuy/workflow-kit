# Creative-content add-on

For a project with content the owner writes: names, user-facing text, and story. It turns on the kit's rule 7: Claude never invents that content and uses clearly marked placeholders, such as `TODO-CONTENT: product name`, until the owner fills them in.

Without it, rule 7 is off and Claude may write names and user-facing text like any other part of the work.

Pick it when installing (`/setup`, or `-AddOns creative-content`). `/setup` makes the changes below. By hand, or for a project installed without it, ask Claude in the project: "Apply the creative-content add-on, following `addons/creative-content/README.md` in the kit."

It changes only `CLAUDE.md`, which the project owns.

## Change `CLAUDE.md`

In "Kit settings", the "Add-ons" line lists `creative-content`.

**Under "Project rules",** replace "None yet." with (or add, if there are rules already):

> - **Rule 7 is on: the owner owns the creative content.** Names, user-facing text, and story are the owner's. Use the placeholders under "Placeholder kinds" for them, and never invent them.

**Add this section** right after "Project rules":

> ## Placeholder kinds
>
> The placeholders for creative content (rule 7). Keep in step with `PlaceholderKinds` in `.claude/kit-settings.psd1`.
>
> - `TODO-CONTENT`: names, user-facing text, and story.

The doc check counts `TODO-CONTENT` by default, so `.claude/kit-settings.psd1` needs no change. A project that uses other kinds lists them there as `PlaceholderKinds`.
