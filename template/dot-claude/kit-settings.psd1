# Settings for the kit's two checks, .claude/kit/tools/check-credits.ps1 and
# check-docs.ps1. This file belongs to the project: kit updates never change it.
#
# Every setting is optional, and one that's left out uses its built-in default.
# A setting replaces its default. Each list setting also has an Extra twin, such
# as ExtraAssetExtensions, that adds to the default instead. Uncomment only what
# this project changes. The defaults are at the top of each check script; if a
# default shown here differs, the script's is the one used.
#
# A setting name the checks don't know stops them, so a typo never passes quietly.
@{
    # --- Both checks -------------------------------------------------------------

    # The name the checks give the owner in their messages.
    # Default: the name on CLAUDE.md's "Owner:" line.
    # Owner = 'Sam'

    # --- License check (check-credits.ps1) ----------------------------------------

    # File types that need a CREDITS.md entry. Add the project's own binary types,
    # such as a tool's resource files, and every Git LFS type in .gitattributes.
    # Default: 3D models, images, audio, video, fonts, map data, and prebuilt
    # libraries (the full list is in check-credits.ps1).
    # ExtraAssetExtensions = @('.scn', '.res')

    # Other JSON package files that list packages under "dependencies", like
    # package.json, by path from the project root. Default: @()
    # ExtraJsonPackageFiles = @('Packages/manifest.json')

    # Packages that come with the platform or tool, by name prefix, so they need
    # no CREDITS.md entry. Default: @()
    # ExtraBuiltInPackages = @('com.example.builtin.')

    # Any file inside a folder with one of these names counts as third-party.
    # Default: @('addons', 'vendor', 'third_party', 'thirdparty', 'external', 'plugins')
    # ExtraVendorFolders = @()

    # --- Doc check (check-docs.ps1) -------------------------------------------------

    # Docs that must exist. Default: @('CLAUDE.md', 'CREDITS.md', 'docs/DESIGN.md',
    # 'docs/ROADMAP_STATUS.md', 'docs/DECISIONS.md', 'docs/AFTER_V1.md')
    # ExtraRequiredDocs = @('docs/API_SPEC.md')

    # Placeholder kinds to count. Keep in step with "Placeholder kinds" in CLAUDE.md.
    # Default: @('TODO-CONTENT')
    # PlaceholderKinds = @('TODO-NAME', 'TODO-TEXT')

    # Files that explain the placeholders rather than use them. Wildcards allowed.
    # Default: @('CLAUDE.md', 'README.md', 'docs/DESIGN.md', 'docs/DECISIONS*.md',
    # 'docs/ROADMAP_STATUS.md', 'docs/plans/*', 'docs/qa/*', '.claude/*')
    # ExtraPlaceholderSkip = @()

    # Files that explain TODO-DESIGN markers rather than use them. Wildcards allowed.
    # Default: @('.claude/*', 'docs/plans/*', 'docs/qa/*', 'docs/DECISIONS*.md')
    # ExtraDesignMarkerSkip = @()

    # File types searched for placeholders and blanks. Default: Markdown, plain text,
    # and common code, data, and config types (the full list is in check-docs.ps1).
    # ExtraTextExtensions = @('.rb')

    # Roadmap IDs, as regexes. The defaults read Phase 1, Step 1.2, sub-step 1.2.3.
    # GateOfStepPattern finds the gate a step belongs to: its first group.
    # SubStepPattern    = '\d+\.\d+\.\d+'
    # StepWord          = 'Step'
    # StepPattern       = '\d+\.\d+'
    # GateWord          = 'Phase'
    # GatePattern       = '\d+'
    # GateOfStepPattern = '^(\d+)\.'
}
