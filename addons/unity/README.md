# Unity add-on

For a Unity project. It teaches the license check Unity's file and package types. For a Unity game, pick the game add-on too.

Pick it when installing (`/setup`, or `-AddOns unity`). `/setup` makes the changes below. By hand, or for a project installed without it, ask Claude in the project: "Apply the Unity add-on, following `addons/unity/README.md` in the kit."

It changes only files the project owns.

## Change `CLAUDE.md`

In "Kit settings", the "Add-ons" line lists `unity`.

## Change the check settings

In `.claude/kit-settings.psd1`, add these lines inside the `@{ }`. If another add-on already set one of them, add to its list instead:

```
ExtraAssetExtensions  = @('.bytes', '.unitypackage')
ExtraJsonPackageFiles = @('Packages/manifest.json')
ExtraBuiltInPackages  = @('com.unity.modules.')
ExtraTextExtensions   = @('.unity', '.prefab', '.asset', '.meta', '.shader')
```

- `.bytes` holds raw binary data and `.unitypackage` is a package file, so both need a `CREDITS.md` entry.
- `Packages/manifest.json` lists Unity packages under "dependencies", like `package.json`; each new one needs a `CREDITS.md` entry.
- Packages starting `com.unity.modules.` come with the engine, so they need none.
- The text types let the doc check find placeholders in scenes, prefabs, and shaders.
