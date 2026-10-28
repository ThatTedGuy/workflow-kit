# Installs the kit's template into a project, or updates a project's
# kit-owned files to this kit's version. See README.md, "Install",
# "Update", and "Migrating from the old layout".
#
# Install: pwsh -NoProfile -File tools/install.ps1 -Project <folder> -Answers <file.psd1> [-AddOns a,b] [-ProfilePath <file.psd1> | -SkipProfile]
# Update:  pwsh -NoProfile -File tools/install.ps1 -Project <folder> -Update
# Migrate: pwsh -NoProfile -File tools/install.ps1 -Project <folder> -Migrate
# Windows PowerShell 5.1: use powershell -NoProfile -ExecutionPolicy Bypass -File in place of pwsh -NoProfile -File.
#
# The answers file is a PowerShell data file with one value per install key,
# like tests/sample-answers.psd1, and may list AddOns. A profile, like
# personal/example.psd1, holds an owner's answers for every project; install
# reads personal/profile.psd1 when it exists, unless -ProfilePath or -SkipProfile
# says otherwise. The answers file wins where both set a key.

param(
    [Parameter(Mandatory = $true)][string]$Project,
    [string]$Answers,
    [string[]]$AddOns,
    [string]$ProfilePath,
    [switch]$SkipProfile,
    [switch]$Update,
    [switch]$Migrate
)

$ErrorActionPreference = 'Stop'
$KitRoot = Split-Path -Parent $PSScriptRoot
$Template = Join-Path $KitRoot 'template'
$Version = (Get-Content -LiteralPath (Join-Path $KitRoot 'VERSION') -Raw).Trim()

# Kit-owned: what an update replaces. Keep in step with RULES.md and CLAUDE.md.
$KitSkills = @('code', 'plan-it', 'pre-pro', 'qa-docreview', 'quick-fix', 'review-fix-commit', 'talk')
$KitOwnedTemplatePaths = @('dot-claude/kit') + ($KitSkills | ForEach-Object { "dot-claude/skills/$_" })

$Utf8 = New-Object System.Text.UTF8Encoding($false)
$KeyPattern = '\{\{([A-Z][A-Z0-9_]*)\}\}'

function Stop-Install([string]$Message) {
    Write-Output "STOPPED: $Message"
    Write-Output 'Nothing was changed.'
    exit 1
}

# template path -> installed path: dot-X becomes .X, X.template.md becomes X.md.
function Get-InstalledPath([string]$Relative) {
    $parts = @($Relative -split '/' | ForEach-Object {
        if ($_ -like 'dot-*') { '.' + $_.Substring(4) } else { $_ }
    })
    $parts[-1] = $parts[-1] -replace '\.template\.md$', '.md'
    return ($parts -join '/')
}

function Get-TemplateFiles([string[]]$Under) { Get-SourceFiles $Template $Under }

# Files under a source folder (the template, or an add-on's files/), with their installed paths.
function Get-SourceFiles([string]$Base, [string[]]$Under) {
    $baseFull = (Resolve-Path -LiteralPath $Base).Path.TrimEnd('\', '/')
    foreach ($item in Get-ChildItem -LiteralPath $Base -Recurse -Force -File) {
        $relative = $item.FullName.Substring($baseFull.Length + 1) -replace '\\', '/'
        if ($Under) {
            $match = $false
            foreach ($u in $Under) { if ($relative -eq $u -or $relative.StartsWith("$u/")) { $match = $true } }
            if (-not $match) { continue }
        }
        [pscustomobject]@{ Source = $item.FullName; Relative = $relative; Installed = (Get-InstalledPath $relative) }
    }
}

# Copies a file, filling install keys. Files without keys are copied byte for byte.
function Copy-TemplateFile($File, [hashtable]$Values) {
    $dest = Join-Path $Project $File.Installed
    $folder = Split-Path -Parent $dest
    if (-not (Test-Path -LiteralPath $folder)) { New-Item -ItemType Directory -Path $folder -Force | Out-Null }
    $bytes = [System.IO.File]::ReadAllBytes($File.Source)
    $text = $Utf8.GetString($bytes)
    if ($Values -and $text -match $KeyPattern) {
        foreach ($key in $Values.Keys) { $text = $text.Replace('{{' + $key + '}}', [string]$Values[$key]) }
        [System.IO.File]::WriteAllText($dest, $text, $Utf8)
    }
    else {
        [System.IO.File]::WriteAllBytes($dest, $bytes)
    }
}

# Prints each CHANGELOG entry newer than $From, so the owner sees the manual steps.
function Show-Changelog([string]$From) {
    # Read as UTF-8: Windows PowerShell 5.1 would assume ANSI and garble dashes.
    $text = [System.IO.File]::ReadAllText((Join-Path $KitRoot 'CHANGELOG.md'), $Utf8)
    $entries = [regex]::Split($text, '(?m)^(?=## \d+\.\d+\.\d+)') | Where-Object { $_ -match '^## (\d+\.\d+\.\d+)' }
    $shown = 0
    foreach ($entry in $entries) {
        $null = $entry -match '^## (\d+\.\d+\.\d+)'
        if ([version]$Matches[1] -gt [version]$From) { Write-Output ''; Write-Output $entry.TrimEnd(); $shown++ }
    }
    if ($shown -eq 0) { Write-Output '(No changelog entries between those versions.)' }
    Write-Output ''
    Write-Output 'Do any "Manual steps" listed above by hand. This script never makes them.'
}

if ($Update -and $Migrate) { Stop-Install 'use -Update or -Migrate, not both.' }
$Project = [System.IO.Path]::GetFullPath($Project)
$versionFile = Join-Path $Project '.claude/kit/VERSION'

# ---- Update and migrate: replace kit-owned files only ----
if ($Update -or $Migrate) {
    if (-not (Test-Path -LiteralPath $Project -PathType Container)) { Stop-Install "$Project doesn't exist." }
    if ($Update) {
        if (-not (Test-Path -LiteralPath $versionFile)) {
            Stop-Install "$Project has no .claude/kit/VERSION. For a project on the old layout, use -Migrate (README, 'Migrating from the old layout')."
        }
        $from = (Get-Content -LiteralPath $versionFile -Raw).Trim()
    }
    else {
        if (Test-Path -LiteralPath $versionFile) { Stop-Install "$Project already uses the new layout. Use -Update." }
        $from = '0.0.0'
    }

    $files = @(Get-TemplateFiles $KitOwnedTemplatePaths)
    foreach ($f in $files) {
        if ($Utf8.GetString([System.IO.File]::ReadAllBytes($f.Source)) -match $KeyPattern) {
            Stop-Install "kit-owned file template/$($f.Relative) has an install key. Kit-owned files must have none."
        }
    }

    # Remove the old kit-owned folders first, so files a new version dropped go away.
    foreach ($p in $KitOwnedTemplatePaths) {
        $target = Join-Path $Project (Get-InstalledPath $p)
        if (Test-Path -LiteralPath $target) { Remove-Item -LiteralPath $target -Recurse -Force }
    }
    foreach ($f in $files) { Copy-TemplateFile $f $null }

    # A migrated project needs the settings file for the values once set inside the old scripts.
    if ($Migrate) {
        $settings = Join-Path $Project '.claude/kit-settings.psd1'
        if (-not (Test-Path -LiteralPath $settings)) { Copy-TemplateFile (Get-TemplateFiles @('dot-claude/kit-settings.psd1')) $null }
    }
    [System.IO.File]::WriteAllText($versionFile, "$Version`n", $Utf8)

    Write-Output "OK: kit-owned files in $Project are now version $Version (were $from)."
    Write-Output "Replaced: .claude/kit/ and .claude/skills/ $($KitSkills -join ', '). Review them with 'git status' and 'git diff'."
    if ($Migrate) { Write-Output 'Next: finish the migration by hand: README.md, "Migrating from the old layout", steps 3 to 6.' }
    Show-Changelog $from
    exit 0
}

# ---- Fresh install ----
if (-not $Answers) { Stop-Install 'a fresh install needs -Answers <file.psd1>. See tests/sample-answers.psd1.' }
if (-not (Test-Path -LiteralPath $Answers)) { Stop-Install "answers file $Answers doesn't exist." }
foreach ($name in @('CLAUDE.md', '.claude/kit')) {
    if (Test-Path -LiteralPath (Join-Path $Project $name)) {
        Stop-Install "$Project already has $name. Use -Update for a kit project, or -Migrate for one on the old layout."
    }
}

$values = Import-PowerShellDataFile -LiteralPath $Answers

# The profile fills any key the answers file leaves out (README, "Personal profile").
if (-not $ProfilePath -and -not $SkipProfile) {
    $default = Join-Path $KitRoot 'personal/profile.psd1'
    if (Test-Path -LiteralPath $default) { $ProfilePath = $default }
}
$profileValues = @{}
if ($ProfilePath -and -not $SkipProfile) {
    if (-not (Test-Path -LiteralPath $ProfilePath)) { Stop-Install "profile $ProfilePath doesn't exist." }
    $profileValues = Import-PowerShellDataFile -LiteralPath $ProfilePath
    Write-Output "Using profile: $ProfilePath"
}
foreach ($key in $profileValues.Keys) {
    if ($key -ne 'AddOns' -and [string]::IsNullOrWhiteSpace([string]$values[$key])) { $values[$key] = $profileValues[$key] }
}

# Add-ons: from -AddOns, the answers file, and the profile. "a,b" counts as two,
# since a -File command line passes it as one string.
$picked = @(@($AddOns) + @($values['AddOns']) + @($profileValues['AddOns']) |
    ForEach-Object { "$_" -split ',' } | ForEach-Object { $_.Trim().ToLowerInvariant() } | Where-Object { $_ } | Select-Object -Unique)
$available = @(Get-ChildItem -LiteralPath (Join-Path $KitRoot 'addons') -Directory | ForEach-Object { $_.Name })
$addonFiles = @()
foreach ($name in $picked) {
    if ($available -notcontains $name) { Stop-Install "there's no add-on called '$name'. Add-ons: $($available -join ', ')." }
    $dir = Join-Path $KitRoot "addons/$name"
    $meta = Join-Path $dir 'addon.psd1'
    if (Test-Path -LiteralPath $meta) {
        foreach ($need in @((Import-PowerShellDataFile -LiteralPath $meta)['Needs'])) {
            if ($need -and $picked -notcontains $need) { Stop-Install "the $name add-on needs the $need add-on too." }
        }
    }
    if (Test-Path -LiteralPath (Join-Path $dir 'files')) { $addonFiles += @(Get-SourceFiles (Join-Path $dir 'files') $null) }
}
$values['ADDONS'] = if ($picked.Count) { ($picked | ForEach-Object { "``$_``" }) -join ', ' } else { 'none' }

# Kit settings are optional answers: a missing one gets the first choice, the
# default. A value outside the choices stops install, so a typo never lands.
$SettingChoices = [ordered]@{
    EXPLANATION_LEVEL = @('beginner', 'experienced')
    TOKEN_USE         = @('strict', 'normal')
    MULTIPLE_CHOICE   = @('on', 'off')
}
foreach ($key in $SettingChoices.Keys) {
    $given = ([string]$values[$key]).Trim().ToLowerInvariant()
    if (-not $given) { $values[$key] = $SettingChoices[$key][0] }
    elseif ($SettingChoices[$key] -notcontains $given) { Stop-Install "$key is '$given'; it must be one of: $($SettingChoices[$key] -join ', ')." }
    else { $values[$key] = $given }
}

$files = @(Get-TemplateFiles $null)

# An add-on's file replaces the template's at the same path. Two add-ons can't both supply one.
$dupes = @($addonFiles | Group-Object Installed | Where-Object { $_.Count -gt 1 } | ForEach-Object { $_.Name })
if ($dupes.Count) { Stop-Install "more than one add-on supplies: $($dupes -join ', ')." }
$fromAddons = @($addonFiles | ForEach-Object { $_.Installed })
$files = @($files | Where-Object { $fromAddons -notcontains $_.Installed }) + $addonFiles

# Every key in the template needs a non-empty answer, checked before anything is written.
$needed = @{}
foreach ($f in $files) {
    foreach ($m in [regex]::Matches($Utf8.GetString([System.IO.File]::ReadAllBytes($f.Source)), $KeyPattern)) {
        $needed[$m.Groups[1].Value] = $true
    }
}
$missing = @($needed.Keys | Where-Object { -not $values.ContainsKey($_) -or [string]::IsNullOrWhiteSpace([string]$values[$_]) } | Sort-Object)
if ($missing.Count -gt 0) { Stop-Install "the answers file has no value for: $($missing -join ', ')." }

$clashes = @($files | Where-Object { Test-Path -LiteralPath (Join-Path $Project $_.Installed) } | ForEach-Object { $_.Installed })
if ($clashes.Count -gt 0) { Stop-Install "these files already exist in ${Project}: $($clashes -join ', ')." }

foreach ($f in $files) { Copy-TemplateFile $f $values }
[System.IO.File]::WriteAllText($versionFile, "$Version`n", $Utf8)

# An answer could itself contain a key; catch anything left in the files
# install wrote (an existing project's own files may use braces).
$left = @($files | ForEach-Object { Join-Path $Project $_.Installed } |
    Select-String -Pattern $KeyPattern -List | ForEach-Object { $_.Path })
if ($left.Count -gt 0) {
    Write-Output "WARNING: install keys left in: $($left -join ', ')"
    exit 1
}

# Git runs hooks only if they're executable, outside Windows.
if ($env:OS -ne 'Windows_NT') { chmod +x (Join-Path $Project '.githooks/pre-commit') }

# Turn the license hook on when the project is already a Git repo.
$hookOn = $false
if (Test-Path -LiteralPath (Join-Path $Project '.git')) {
    git -C $Project config core.hooksPath .githooks
    $hookOn = ($LASTEXITCODE -eq 0)
}

Write-Output "OK: kit $Version installed into $Project ($($files.Count) files)."
if ($picked.Count) {
    Write-Output "Add-ons: $($picked -join ', '). Install copied their files; their changes to CLAUDE.md and"
    Write-Output 'the settings are made by /setup, or by following each add-on''s README in the kit''s addons/ folder.'
}
if ($hookOn) {
    Write-Output 'The license check now runs before every commit (core.hooksPath = .githooks).'
    Write-Output 'Next: run the Doc check from the Checks table in CLAUDE.md.'
}
else {
    Write-Output 'Next: git init, then turn on the license hook with: git config core.hooksPath .githooks'
    Write-Output 'Then run the Doc check from the Checks table in CLAUDE.md.'
}
exit 0
