# Obsidian add-on

For a project whose docs you also want to read and edit in Obsidian, a free note-taking app that opens a folder of Markdown files as a "vault". It helps most where there's a lot of linked writing: lore, story, research, or a long decision log. It sets Obsidian up so it doesn't clash with the kit: links stay standard Markdown, so they work on GitHub and Claude can follow them, and code folders stay out of the way.

The kit doesn't need Obsidian, and the project works the same without it. The add-on ships no part of Obsidian.

Pick it when installing (`/setup`, or `-AddOns obsidian`). `/setup` makes the changes below. By hand, or for a project installed without it, ask Claude in the project: "Apply the obsidian add-on, following `addons/obsidian/README.md` in the kit."

It changes `CLAUDE.md`, `.gitignore`, and `.obsidian/app.json`, which the project owns. Create a file that doesn't exist yet. In one that does, add these changes and keep everything else.

To use it, open Obsidian, choose "Open folder as vault", and pick the project folder. Commit `.obsidian/` so everyone gets the same settings; Git ignores only the per-machine window layout.

## Change `CLAUDE.md`

In "Kit settings", the "Add-ons" line lists `obsidian`.

**Under "Project docs",** add this paragraph after the "Long docs" line:

> **Obsidian:** the docs also open in Obsidian. Links between docs are standard Markdown links with paths relative to the file, such as `[decisions](DECISIONS.md)`, never `[[wikilinks]]`: GitHub and Claude don't follow those. Don't add frontmatter (a `---` block at the top) to the kit's docs. Obsidian's settings are in `.obsidian/app.json`.

## Change `.gitignore`

Add:

```gitignore
# Obsidian: per-machine window layout
.obsidian/workspace*.json
```

## Change `.obsidian/app.json`

These are the settings under "Files and links" in Obsidian. If the file exists, set these keys and keep the others. Close Obsidian first: it rewrites this file when its settings change.

```json
{
  "useMarkdownLinks": true,
  "newLinkFormat": "relative",
  "alwaysUpdateLinks": true,
  "userIgnoreFilters": []
}
```

- `useMarkdownLinks`: new links are standard Markdown links, not wikilinks.
- `newLinkFormat`: link paths are relative to the file, which is how GitHub reads them.
- `alwaysUpdateLinks`: renaming or moving a doc in Obsidian fixes the links to it, without asking.
- `userIgnoreFilters` ("Excluded files"): the project's code, build, and dependency folders, so search and the graph show the docs. For example `src/`, `build/`, `node_modules/`, or Unity's `Library/`. List the ones the project has; a new project can leave it empty. Obsidian already skips hidden folders such as `.claude/` and `.git/`.
