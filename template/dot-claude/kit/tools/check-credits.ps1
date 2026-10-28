<#
.SYNOPSIS
    License check. Blocks assets, vendored code, and packages that have no
    entry in CREDITS.md.

.DESCRIPTION
    By default it checks only what changed since the last commit: staged,
    unstaged, and new (untracked) files. Use -All to check the whole repo.
    Before the first commit, it always checks every file. -Staged checks
    only what's staged, against the staged CREDITS.md: the Git pre-commit
    hook uses it.

    A file needs an entry if it is an asset type (models, images, audio,
    video, fonts, map data, prebuilt libraries) or sits inside a vendor
    folder such as addons/ or vendor/. A package needs an entry when it is
    added to a package file: .NET (.csproj, .props, packages.config), npm
    (package.json), Python (requirements*.txt), or a JSON package file named in
    the JsonPackageFiles setting.

    An entry covers a file when its "- Files:" line lists the file's path,
    or a folder path ending in "/" that contains it. An entry covers a
    package when its "- Package:" line lists the package name. Example
    entries inside ``` code fences are ignored.

    The project's own settings, such as extra asset types, go in
    .claude/kit-settings.psd1. Any setting it lacks uses the default below.

    Exit code 0: everything is credited. Exit code 1: something is missing,
    or the check could not run.

.EXAMPLE
    pwsh -NoProfile -File .claude/kit/tools/check-credits.ps1

.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File .claude/kit/tools/check-credits.ps1
    Windows PowerShell 5.1, on Windows without PowerShell 7.

.EXAMPLE
    pwsh -NoProfile -File .claude/kit/tools/check-credits.ps1 -All
#>
param(
    [switch]$All,
    [switch]$Staged
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# --- Settings ------------------------------------------------------------------
# Built-in defaults. A project changes them in .claude/kit-settings.psd1, never
# here: kit updates replace this file. The project's own binary types, such as a
# tool's resource files, and every Git LFS type in .gitattributes, go in
# ExtraAssetExtensions there.

. (Join-Path $PSScriptRoot 'read-settings.ps1')

$root = Find-ProjectRoot $PSScriptRoot
if (-not $root) {
    Write-Host 'License check could not run: no folder above it holds .claude/kit/.'
    exit 1
}

$defaults = @{}
$defaults.Owner = Get-OwnerName $root

$defaults.AssetExtensions = @(
    # 3D models and scenes made in outside tools
    '.blend', '.fbx', '.obj', '.mtl', '.gltf', '.glb', '.dae', '.3ds', '.stl',
    '.usd', '.usda', '.usdc', '.usdz', '.abc',
    # Images and textures
    '.png', '.jpg', '.jpeg', '.tga', '.tif', '.tiff', '.bmp', '.gif', '.psd',
    '.exr', '.hdr', '.dds', '.ktx', '.ktx2', '.webp', '.svg', '.ico',
    # Audio
    '.wav', '.ogg', '.mp3', '.flac', '.aif', '.aiff', '.opus',
    # Video
    '.mp4', '.webm', '.mov', '.ogv',
    # Fonts (.fnt is a bitmap font)
    '.ttf', '.otf', '.woff', '.woff2', '.fnt',
    # Map and geographic data
    '.shp', '.shx', '.dbf', '.prj', '.geojson', '.kml',
    # Prebuilt libraries
    '.dll', '.so', '.dylib', '.lib', '.a', '.jar', '.nupkg', '.whl'
)

# Other JSON package files that list packages under "dependencies", like
# package.json, by path from the project root. An add-on can name its tool's.
$defaults.JsonPackageFiles = @()

# Packages whose names start with one of these come with the platform or tool,
# so they need no entry.
$defaults.BuiltInPackages = @()

# Any file inside a folder with one of these names counts as third-party.
$defaults.VendorFolders = @('addons', 'vendor', 'third_party', 'thirdparty', 'external', 'plugins')

$settings = Read-KitSettings $root $defaults 'License check'
if ($null -eq $settings) { exit 1 }
$Owner = $settings.Owner
$AssetExtensions = $settings.AssetExtensions
$JsonPackageFiles = @($settings.JsonPackageFiles | ForEach-Object { $_.Trim().Replace('\', '/') })
$BuiltInPackages = $settings.BuiltInPackages
$VendorFolders = $settings.VendorFolders

# --- Helpers -----------------------------------------------------------------

function ConvertTo-RepoPath([string]$p) {
    $p = $p.Trim().Replace('\', '/')
    if ($p.StartsWith('./')) { $p = $p.Substring(2) }
    return $p
}

function Get-ManifestKind([string]$path) {
    $leaf = [IO.Path]::GetFileName($path).ToLowerInvariant()
    $ext = [IO.Path]::GetExtension($path).ToLowerInvariant()
    if (@('.csproj', '.fsproj', '.vbproj', '.props', '.targets') -contains $ext) { return 'dotnet' }
    if ($leaf -eq 'packages.config') { return 'nuget-config' }
    if ($leaf -eq 'package.json') { return 'npm' }
    if ($leaf -like 'requirements*.txt') { return 'pip' }
    if ($JsonPackageFiles -contains $path.Replace('\', '/')) { return 'json' }
    return $null
}

# Package names named in these lines of a package file.
function Get-PackageNames([string]$kind, [string[]]$lines, [string]$fullPath) {
    $names = @()
    switch ($kind) {
        'dotnet' {
            foreach ($line in $lines) {
                foreach ($m in [regex]::Matches($line, '<Package(?:Reference|Version)\s+Include\s*=\s*"([^"]+)"')) {
                    $names += $m.Groups[1].Value
                }
            }
        }
        'nuget-config' {
            foreach ($line in $lines) {
                foreach ($m in [regex]::Matches($line, '<package\s+id\s*=\s*"([^"]+)"')) { $names += $m.Groups[1].Value }
            }
        }
        'npm' {
            # Read the dependency lists from the whole file, then keep the names
            # that appear in the lines being checked.
            try { $json = Get-Content -LiteralPath $fullPath -Raw -Encoding UTF8 | ConvertFrom-Json } catch { return @() }
            $all = @()
            foreach ($section in @('dependencies', 'devDependencies', 'optionalDependencies', 'peerDependencies')) {
                if ($json.$section) { $all += @($json.$section.PSObject.Properties | ForEach-Object { $_.Name }) }
            }
            $text = $lines -join "`n"
            $names = @($all | Where-Object { $text.Contains('"' + $_ + '"') })
        }
        'json' {
            # A package file named in JsonPackageFiles: the same as npm's, with one list.
            try { $json = Get-Content -LiteralPath $fullPath -Raw -Encoding UTF8 | ConvertFrom-Json } catch { return @() }
            $all = @()
            if ($json.dependencies) { $all = @($json.dependencies.PSObject.Properties | ForEach-Object { $_.Name }) }
            $text = $lines -join "`n"
            $names = @($all | Where-Object { $text.Contains('"' + $_ + '"') })
        }
        'pip' {
            foreach ($line in $lines) {
                $l = $line.Trim()
                if (-not $l -or $l.StartsWith('#') -or $l.StartsWith('-')) { continue }
                if ($l -match '^([A-Za-z0-9][A-Za-z0-9._-]*)') { $names += $Matches[1] }
            }
        }
    }
    # Built-in packages need no entry, whatever file names them.
    return @($names | Where-Object { $n = $_; -not @($BuiltInPackages | Where-Object { $_ -and $n.StartsWith($_) }).Count })
}

function Test-Covered([string]$file) {
    foreach ($c in $script:coveredPaths) {
        if ($c.EndsWith('/')) {
            if ($file.StartsWith($c, [StringComparison]::OrdinalIgnoreCase)) { return $true }
        } elseif ($file.Equals($c, [StringComparison]::OrdinalIgnoreCase)) {
            return $true
        }
    }
    return $false
}

# --- Check for Git -------------------------------------------------------------

# Git runs from the project root, and --relative keeps its paths relative to it,
# even when the project sits inside a bigger repo.
git -C $root rev-parse --show-toplevel > $null 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host 'License check could not run: the project is not inside a Git repository.'
    exit 1
}

git -C $root rev-parse --verify --quiet HEAD > $null
$hasHead = ($LASTEXITCODE -eq 0)

# --- Read CREDITS.md -------------------------------------------------------------

$script:coveredPaths = @()
$coveredPackages = New-Object 'System.Collections.Generic.HashSet[string]' ([StringComparer]::OrdinalIgnoreCase)
$creditsPath = Join-Path $root 'CREDITS.md'
$creditsFound = Test-Path -LiteralPath $creditsPath
$creditLines = @()
if ($Staged) {
    # What gets committed is the staged CREDITS.md, not the one on disk.
    git -C $root cat-file -e ':./CREDITS.md' 2>$null
    $creditsFound = ($LASTEXITCODE -eq 0)
    if ($creditsFound) { $creditLines = @(git -C $root show ':./CREDITS.md') }
} elseif ($creditsFound) {
    $creditLines = @(Get-Content -LiteralPath $creditsPath -Encoding UTF8)
}

if ($creditsFound) {
    $inFence = $false
    foreach ($line in $creditLines) {
        if ($line.TrimStart().StartsWith('```')) { $inFence = -not $inFence; continue }
        if ($inFence) { continue }
        if ($line -match '^\s*-\s*Files:\s*(.*)$') {
            foreach ($m in [regex]::Matches($Matches[1], '`([^`]+)`')) {
                $script:coveredPaths += (ConvertTo-RepoPath $m.Groups[1].Value)
            }
        } elseif ($line -match '^\s*-\s*Package:\s*(.*)$') {
            foreach ($m in [regex]::Matches($Matches[1], '`([^`]+)`')) {
                [void]$coveredPackages.Add($m.Groups[1].Value.Trim())
            }
        }
    }
}

# --- Collect the files to check -----------------------------------------------------

if ($All -and $Staged) {
    Write-Host 'License check could not run: use -All or -Staged, not both.'
    exit 1
}
if ($Staged) {
    $mode = 'files staged for commit'
    $files = @(git -C $root -c core.quotepath=off diff --cached --name-only --relative --diff-filter=ACMR)
} elseif ($All -or -not $hasHead) {
    $mode = if ($All) { 'every file in the repo' } else { 'every file (no commits yet)' }
    $files = @(git -C $root -c core.quotepath=off ls-files --cached --others --exclude-standard)
} else {
    $mode = 'files changed since the last commit'
    $files = @(git -C $root -c core.quotepath=off diff --name-only --relative --diff-filter=ACMR HEAD) +
             @(git -C $root -c core.quotepath=off ls-files --others --exclude-standard)
}
$files = @($files | Where-Object { $_ } | ForEach-Object { ConvertTo-RepoPath $_ } | Sort-Object -Unique)

# --- Check each file ------------------------------------------------------------------

$missingFiles = @()
$missingPackages = @()

foreach ($f in $files) {
    $ext = [IO.Path]::GetExtension($f).ToLowerInvariant()
    $folders = @($f.Split('/') | Select-Object -SkipLast 1)
    $isAsset = $AssetExtensions -contains $ext
    $isVendored = $false
    foreach ($d in $folders) { if ($VendorFolders -contains $d) { $isVendored = $true } }

    if (($isAsset -or $isVendored) -and -not (Test-Covered $f)) {
        $kind = if ($isVendored) { 'inside a vendor folder' } else { 'asset file' }
        $missingFiles += [pscustomobject]@{ Path = $f; Kind = $kind }
    }

    $manifest = Get-ManifestKind $f
    if ($manifest) {
        $full = Join-Path $root $f
        if (-not (Test-Path -LiteralPath $full)) { continue }
        $lines = $null
        if (-not $All -and $hasHead) {
            # For a package file that already existed, only check the lines added since the last commit.
            git -C $root cat-file -e "HEAD:./$f" 2>$null
            if ($LASTEXITCODE -eq 0) {
                $diffArgs = if ($Staged) { @('--cached') } else { @() }
                $lines = @(git -C $root -c core.quotepath=off diff @diffArgs --relative HEAD -- $f |
                    Where-Object { $_.StartsWith('+') -and -not $_.StartsWith('+++') } |
                    ForEach-Object { $_.Substring(1) })
            }
        }
        if ($null -eq $lines) { $lines = @(Get-Content -LiteralPath $full -Encoding UTF8) }
        foreach ($name in (Get-PackageNames $manifest $lines $full)) {
            if (-not $coveredPackages.Contains($name)) {
                $missingPackages += [pscustomobject]@{ Name = $name; File = $f }
            }
        }
    }
}

$missingPackages = @($missingPackages | Sort-Object Name, File -Unique)

# --- Report ------------------------------------------------------------------------------

Write-Host 'License check (.claude/kit/tools/check-credits.ps1)'
Write-Host "Checked $($files.Count) files: $mode."
if (-not $creditsFound) {
    $where = if ($Staged) { 'staged or committed' } else { 'found at the project root' }
    Write-Host "CREDITS.md was not $where, so nothing counts as credited."
}
Write-Host ''

$total = $missingFiles.Count + $missingPackages.Count
if ($total -eq 0) {
    Write-Host 'PASSED: every asset, vendored file, and package checked has a CREDITS.md entry.'
    exit 0
}

Write-Host "BLOCKED: $total item(s) have no CREDITS.md entry."
if ($missingFiles.Count) {
    Write-Host ''
    Write-Host 'Files with no entry:'
    foreach ($m in $missingFiles) { Write-Host "  $($m.Path)   ($($m.Kind))" }
}
if ($missingPackages.Count) {
    Write-Host ''
    Write-Host 'Packages with no entry:'
    foreach ($m in $missingPackages) { Write-Host "  $($m.Name)   (added in $($m.File))" }
}
Write-Host ''
Write-Host 'How to fix: add an entry to CREDITS.md with the source, author, and license.'
Write-Host 'List each file (or its folder, ending in /) on a "- Files:" line, and each'
Write-Host 'package on a "- Package:" line, in backticks. Original work needs an entry too.'
Write-Host 'If the license is not CC0, public domain, CC-BY, MIT, BSD, Apache-2.0, or zlib,'
Write-Host "ask $Owner before using it. Otherwise, remove the item."
if ($Staged) {
    Write-Host ''
    Write-Host 'Then stage CREDITS.md too (git add CREDITS.md) and commit again.'
}
exit 1
