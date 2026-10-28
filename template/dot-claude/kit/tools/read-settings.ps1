# Shared by check-credits.ps1 and check-docs.ps1, which dot-source it. Finds the
# project root and reads the project's settings from .claude/kit-settings.psd1.

# Every setting either check reads, so a typo in the settings file is caught
# whichever check runs. Each list setting also has an "Extra" twin, such as
# ExtraAssetExtensions, that adds to the default instead of replacing it.
$KitScalarSettings = @('Owner', 'SubStepPattern', 'StepWord', 'StepPattern', 'GateWord',
    'GatePattern', 'GateOfStepPattern')
$KitListSettings = @('AssetExtensions', 'JsonPackageFiles', 'BuiltInPackages', 'VendorFolders', 'RequiredDocs',
    'PlaceholderKinds', 'PlaceholderSkip', 'DesignMarkerSkip', 'TextExtensions')

# The project root is the first folder above the scripts that holds .claude/kit/.
# Paths use / so they work on every system.
function Find-ProjectRoot([string]$start) {
    $dir = $start
    while ($dir) {
        if (Test-Path -LiteralPath (Join-Path $dir '.claude/kit') -PathType Container) { return $dir }
        $parent = Split-Path -Parent $dir
        if ($parent -eq $dir) { break }
        $dir = $parent
    }
    return $null
}

# The name on CLAUDE.md's "- **Owner:** <name>." line, or "the owner" if there's
# none yet, such as before install fills it in.
function Get-OwnerName([string]$root) {
    $path = Join-Path $root 'CLAUDE.md'
    if (Test-Path -LiteralPath $path) {
        foreach ($line in Get-Content -LiteralPath $path -Encoding UTF8) {
            if ($line -match '^\s*-\s*\*\*Owner:\*\*\s*([^.{}]+?)\s*(\.|$)') { return $Matches[1] }
        }
    }
    return 'the owner'
}

# Each default, replaced or extended by the settings file. A missing file means
# every default. Prints why and returns $null if the file can't be used, so a
# typo never passes quietly.
function Read-KitSettings([string]$root, [hashtable]$defaults, [string]$checkName) {
    $path = Join-Path $root '.claude/kit-settings.psd1'
    $file = @{}
    if (Test-Path -LiteralPath $path) {
        try { $file = Import-PowerShellDataFile -LiteralPath $path -ErrorAction Stop }
        catch {
            Write-Host "$checkName could not run: .claude/kit-settings.psd1 could not be read."
            Write-Host "  $($_.Exception.Message)"
            return $null
        }
    }

    $known = $KitScalarSettings + $KitListSettings + @($KitListSettings | ForEach-Object { "Extra$_" })
    $unknown = @($file.Keys | Where-Object { $known -notcontains $_ })
    if ($unknown.Count) {
        Write-Host "$checkName could not run: .claude/kit-settings.psd1 has setting(s) the checks don't know: $($unknown -join ', ')."
        Write-Host 'Check the spelling against the list in that file.'
        return $null
    }

    $out = @{}
    foreach ($name in $defaults.Keys) {
        if ($file.ContainsKey($name)) { $value = $file[$name] } else { $value = $defaults[$name] }
        if ($KitListSettings -contains $name) {
            $value = @(@($value) + @($file["Extra$name"]) | Where-Object { $null -ne $_ })
        }
        $out[$name] = $value
    }
    return $out
}
