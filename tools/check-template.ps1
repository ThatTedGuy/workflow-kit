# Fails if template/ or addons/ holds a name that Claude Code would load,
# or a Git file that would act on the kit repo itself. The template must
# never be live while the kit is developed. See CLAUDE.md, "The template is
# never live".
#
# Run: pwsh -NoProfile -File tools/check-template.ps1
# Windows PowerShell 5.1: powershell -NoProfile -ExecutionPolicy Bypass -File tools/check-template.ps1
# -Root points it at another folder (for testing the check itself).

param(
    [string]$Root = (Split-Path -Parent $PSScriptRoot)
)

# Banned name -> the safe name to use instead. Matched without regard to case.
$BannedFiles = @{
    'CLAUDE.md'       = 'CLAUDE.template.md'
    'CLAUDE.local.md' = 'CLAUDE.local.template.md'
    'AGENTS.md'       = 'AGENTS.template.md'
    '.gitattributes'  = 'dot-gitattributes'
}
$BannedFolders = @{
    '.claude' = 'dot-claude'
}

$CheckedFolders = @('template', 'addons')

$problems = @()
$fileCount = 0

if (-not (Test-Path -LiteralPath (Join-Path $Root 'template') -PathType Container)) {
    $problems += "template/ is missing from $Root"
}

$rootFull = (Resolve-Path -LiteralPath $Root).Path.TrimEnd('\', '/')

foreach ($folder in $CheckedFolders) {
    $path = Join-Path $Root $folder
    if (-not (Test-Path -LiteralPath $path -PathType Container)) { continue }

    # -Force includes hidden files, such as dot-files on Windows.
    foreach ($item in Get-ChildItem -LiteralPath $path -Recurse -Force) {
        $relative = $item.FullName.Substring($rootFull.Length + 1) -replace '\\', '/'
        if ($item.PSIsContainer) {
            foreach ($name in $BannedFolders.Keys) {
                if ($item.Name -ieq $name) {
                    $problems += "$relative/  (rename the folder to $($BannedFolders[$name]))"
                }
            }
        }
        else {
            $fileCount++
            foreach ($name in $BannedFiles.Keys) {
                if ($item.Name -ieq $name) {
                    $problems += "$relative  (rename to $($BannedFiles[$name]))"
                }
            }
        }
    }
}

if ($problems.Count -gt 0) {
    Write-Output "FAIL: template check found $($problems.Count) problem(s):"
    foreach ($p in $problems) { Write-Output "  $p" }
    exit 1
}

Write-Output "OK: no loadable names in template/ or addons/ ($fileCount files checked)."
exit 0
