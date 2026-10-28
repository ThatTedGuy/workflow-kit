# Windows add-on

For a project on Windows that runs the kit's scripts in Windows PowerShell 5.1, which comes with Windows, instead of PowerShell 7 (`pwsh`). With PowerShell 7 installed, this add-on isn't needed.

**Needs** Git for Windows, which brings Git Bash: Claude Code runs the kit's hooks (`/talk`'s guard, and the Git pre-commit hook) in it.

Pick it when installing (`/setup`, or `-AddOns windows`). `/setup` makes the changes below. By hand, or for a project installed without it, ask Claude in the project: "Apply the Windows add-on, following `addons/windows/README.md` in the kit."

It changes only `CLAUDE.md`, which the project owns. The kit's hooks already fall back to Windows PowerShell when `pwsh` isn't there.

## Change `CLAUDE.md`

In "Kit settings", the "Add-ons" line lists `windows`.

**In the "Checks" table,** in the License check and Doc check commands, replace `pwsh -NoProfile -File` with `powershell -NoProfile -ExecutionPolicy Bypass -File`. Replace the line under the table with:

> The kit's scripts run in Windows PowerShell 5.1 (`powershell`). `-ExecutionPolicy Bypass` lets them run without changing the machine's policy. With PowerShell 7 installed, `pwsh -NoProfile -File` works too.

**Under "Environment",** add:

> - Windows, Git for Windows (Git Bash runs Claude Code hooks), and Windows PowerShell 5.1 (`powershell`). Run kit scripts as `powershell -NoProfile -ExecutionPolicy Bypass -File <script>`.
