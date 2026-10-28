<#
.SYNOPSIS
    Doc check. Finds drift between DESIGN.md and the other docs.

.DESCRIPTION
    Checks that:
      1. Every required doc exists.
      2. ROADMAP_STATUS.md lists exactly the steps, sub-steps, and phase gates
         in DESIGN.md ("Roadmap" and "Updates after v1"), in the same order.
      3. Every step in DESIGN.md has a "Done when" line.
      4. ROADMAP_STATUS.md is consistent: no step or gate is ticked while work
         under it is open, and "Next sub-step" points at the first open one.
      5. The parking lots in AFTER_V1.md and DESIGN.md hold the same ideas.
    It also reports the stage and the pre-production checklist, counts the
    content placeholders and TODO-DESIGN markers by file, and lists double-brace
    blanks left from install. TODO-DESIGN markers left once pre-production is
    over become a note for the owner.

    The project's own settings, such as extra required docs or its own roadmap
    IDs, go in .claude/kit-settings.psd1. Any setting it lacks uses the default below.

    "Problems" are things Claude should fix. "Notes for the owner" are things
    only the owner can change, such as DESIGN.md itself.

    This script compares docs with docs. /qa-docreview runs it first, then
    compares the code with DESIGN.md.

    Exit code 0: no problems (notes may still be listed). Exit code 1: problems
    found, or the check could not run.

.EXAMPLE
    pwsh -NoProfile -File .claude/kit/tools/check-docs.ps1

.EXAMPLE
    powershell -NoProfile -ExecutionPolicy Bypass -File .claude/kit/tools/check-docs.ps1
    Windows PowerShell 5.1, on Windows without PowerShell 7.
#>

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# --- Settings ------------------------------------------------------------------
# Built-in defaults. A project changes them in .claude/kit-settings.psd1, never
# here: kit updates replace this file.

. (Join-Path $PSScriptRoot 'read-settings.ps1')

$root = Find-ProjectRoot $PSScriptRoot
if (-not $root) {
    Write-Host 'Doc check could not run: no folder above it holds .claude/kit/.'
    exit 1
}

$defaults = @{}
$defaults.Owner = Get-OwnerName $root

# Docs every project has. A project adds its own, such as docs/LORE_BIBLE.md, in ExtraRequiredDocs.
$defaults.RequiredDocs = @('CLAUDE.md', 'CREDITS.md', 'docs/DESIGN.md', 'docs/ROADMAP_STATUS.md',
    'docs/DECISIONS.md', 'docs/AFTER_V1.md')

# Placeholder kinds to count (RULES.md rule 7, and "Placeholder kinds" in CLAUDE.md).
# Add-ons can set others.
$defaults.PlaceholderKinds = @('TODO-CONTENT')

# Files that explain the placeholder rules rather than use them. Wildcards allowed.
$defaults.PlaceholderSkip = @('CLAUDE.md', 'README.md', 'docs/DESIGN.md', 'docs/DECISIONS*.md',
    'docs/ROADMAP_STATUS.md', 'docs/plans/*', 'docs/qa/*', '.claude/*')

# Files that explain TODO-DESIGN markers rather than use them. Wildcards allowed.
$defaults.DesignMarkerSkip = @('.claude/*', 'docs/plans/*', 'docs/qa/*', 'docs/DECISIONS*.md')

$defaults.TextExtensions = @('.md', '.txt', '.cs', '.json', '.yaml', '.yml',
    '.xml', '.csv', '.ini', '.cfg', '.toml', '.glsl', '.cpp', '.h',
    '.hpp', '.c', '.py', '.js', '.ts', '.tsx', '.jsx', '.html', '.css', '.rs', '.go', '.java',
    '.kt', '.swift', '.lua', '.ps1', '.sh')

# Roadmap IDs. The defaults read the kit's numbers: Phase 1, Step 1.2, sub-step 1.2.3. A project
# with its own IDs, such as Day > Phase > Step (D1A4), changes all six. A sub-step ID must be
# followed by a space in the docs. PowerShell names ignore case, so a setting must not share a
# name with a variable below ($stepId, $gateId): hence "Pattern".
$defaults.SubStepPattern = '\d+\.\d+\.\d+'
$defaults.StepWord = 'Step'
$defaults.StepPattern = '\d+\.\d+'
$defaults.GateWord = 'Phase'
$defaults.GatePattern = '\d+'
# The gate a step belongs to: the regex's first group. Step 1.2 belongs to Phase 1.
$defaults.GateOfStepPattern = '^(\d+)\.'

$settings = Read-KitSettings $root $defaults 'Doc check'
if ($null -eq $settings) { exit 1 }
$Owner = $settings.Owner
$RequiredDocs = $settings.RequiredDocs
$PlaceholderKinds = $settings.PlaceholderKinds
$PlaceholderSkip = $settings.PlaceholderSkip
$DesignMarkerSkip = $settings.DesignMarkerSkip
$TextExtensions = $settings.TextExtensions
$SubStepPattern = $settings.SubStepPattern
$StepWord = $settings.StepWord
$StepPattern = $settings.StepPattern
$GateWord = $settings.GateWord
$GatePattern = $settings.GatePattern
$GateOfStepPattern = $settings.GateOfStepPattern

function Get-GateOf([string]$stepId) {
    if ($stepId -match $GateOfStepPattern) { return $Matches[1] }
    return $null
}

# --- Helpers -------------------------------------------------------------------

$problems = New-Object System.Collections.Generic.List[string]
$notes = New-Object System.Collections.Generic.List[string]
$report = New-Object System.Collections.Generic.List[string]

function Read-Doc([string]$rel) {
    $full = Join-Path $root $rel
    if (Test-Path -LiteralPath $full) { return , @(Get-Content -LiteralPath $full -Encoding UTF8) }
    return , @()
}

# Lines after a "## <heading>" line, up to the next "## " heading. The first
# heading in the list that exists wins.
function Get-Section([string[]]$lines, [string[]]$headings) {
    foreach ($heading in $headings) {
        $out = New-Object System.Collections.Generic.List[string]
        $inside = $false
        $found = $false
        foreach ($l in $lines) {
            if ($l -match '^##\s') {
                if ($inside) { break }
                if ($l.Trim() -eq "## $heading") { $inside = $true; $found = $true; continue }
            }
            if ($inside) { $out.Add($l) }
        }
        if ($found) { return , $out.ToArray() }
    }
    return , @()
}

# First column of every data row in the Markdown tables in these lines.
function Get-TableIdeas([string[]]$lines) {
    $ideas = New-Object System.Collections.Generic.List[string]
    foreach ($l in $lines) {
        if ($l -notmatch '^\s*\|') { continue }
        if ($l -match '^\s*\|\s*:?-{3,}') { continue }
        $idea = $l.Trim().Trim('|').Split('|')[0].Trim()
        if (-not $idea -or $idea -eq 'Idea') { continue }
        $ideas.Add($idea)
    }
    return , $ideas.ToArray()
}

function Compare-IdList([string]$label, [string[]]$designIds, [string[]]$statusIds) {
    $missing = @($designIds | Where-Object { $statusIds -notcontains $_ })
    $extra = @($statusIds | Where-Object { $designIds -notcontains $_ })
    $dupes = @($statusIds | Group-Object | Where-Object { $_.Count -gt 1 } | ForEach-Object { $_.Name })
    $ok = $true
    if ($missing.Count) { $problems.Add("$label in DESIGN.md but missing from ROADMAP_STATUS.md: $($missing -join ', ')"); $ok = $false }
    if ($extra.Count) { $problems.Add("$label in ROADMAP_STATUS.md but not in DESIGN.md: $($extra -join ', ')"); $ok = $false }
    if ($dupes.Count) { $problems.Add("$label listed more than once in ROADMAP_STATUS.md: $($dupes -join ', ')"); $ok = $false }
    if ($ok -and (($designIds -join ',') -ne ($statusIds -join ','))) {
        $problems.Add("$label are in a different order in ROADMAP_STATUS.md than in DESIGN.md"); $ok = $false
    }
    return $ok
}

function Test-Skipped([string]$file, [string[]]$patterns) {
    foreach ($p in $patterns) { if ($file -like $p) { return $true } }
    return $false
}

# --- 1. Required docs -----------------------------------------------------------

$missingDocs = @($RequiredDocs | Where-Object { -not (Test-Path -LiteralPath (Join-Path $root $_)) })
if ($missingDocs.Count) {
    foreach ($m in $missingDocs) { $problems.Add("Missing doc: $m") }
    $report.Add("[PROBLEM] Required docs: $($missingDocs.Count) missing")
} else {
    $report.Add("[OK]      Required docs: all $($RequiredDocs.Count) present")
}

$design = Read-Doc 'docs/DESIGN.md'
$status = Read-Doc 'docs/ROADMAP_STATUS.md'

# --- Stage and the pre-production checklist ---------------------------------------

$stage = $null
foreach ($l in $status) {
    if ($l -match '^\*\*Stage:\*\*\s*([A-Za-z-]+)') { $stage = $Matches[1]; break }
}
$preProduction = ($stage -eq 'Pre-production')
if (-not $stage) {
    $problems.Add('ROADMAP_STATUS.md has no "**Stage:**" line (RULES.md, "Stages")')
    $report.Add('[PROBLEM] Stage: no Stage line')
} else {
    $line = "[INFO]    Stage: $stage"
    if ($preProduction) {
        $checklist = Get-Section $status @('Pre-production checklist')
        $items = @($checklist | Where-Object { $_ -match '^\s*-\s+\[[ xX]\]' })
        $ticked = @($items | Where-Object { $_ -match '^\s*-\s+\[[xX]\]' })
        $line += ", checklist $($ticked.Count) of $($items.Count) ticked"
    }
    $report.Add($line)
}

# --- 2 and 3. Roadmap in DESIGN.md ------------------------------------------------

# Get-Section returns its array unrolled once, so assign before joining; @(...) would nest it.
$mainRoadmap = Get-Section $design @('Roadmap')
$updates = Get-Section $design @('Updates after v1')
$roadmap = [string[]]$mainRoadmap + [string[]]$updates
$dSub = New-Object System.Collections.Generic.List[string]
$dSteps = New-Object System.Collections.Generic.List[string]
$dGates = New-Object System.Collections.Generic.List[string]
$noDoneWhen = New-Object System.Collections.Generic.List[string]
$currentStep = $null
$currentHasDone = $false

foreach ($l in $roadmap) {
    if ($l -match "^\s*-\s+($SubStepPattern)\s") { $dSub.Add($Matches[1]); continue }
    if ($l -match '^\s*(\*\*)?Done when') { $currentHasDone = $true; continue }
    $stepId = $null
    $gateId = $null
    if ($l -match "^(?:#{3,6}\s+|\*\*)$StepWord\s+($StepPattern)\b") { $stepId = $Matches[1] }
    elseif ($l -match "^\*\*$GateWord\s+($GatePattern)\s+gate:") { $gateId = $Matches[1] }
    elseif ($l -notmatch '^#{2,6}\s') { continue }
    # Reached a new step, gate, or heading: close the step we were in.
    if ($currentStep -and -not $currentHasDone) { $noDoneWhen.Add($currentStep) }
    $currentStep = $stepId
    $currentHasDone = $false
    if ($stepId) { $dSteps.Add($stepId) }
    if ($gateId) { $dGates.Add($gateId) }
}
if ($currentStep -and -not $currentHasDone) { $noDoneWhen.Add($currentStep) }

# --- Roadmap in ROADMAP_STATUS.md ---------------------------------------------------

$sSub = New-Object System.Collections.Generic.List[string]
$sSteps = New-Object System.Collections.Generic.List[string]
$sGates = New-Object System.Collections.Generic.List[string]
$stepOpen = @{}       # step id -> number of open sub-steps
$stepDone = @{}       # step id -> "Done when" ticked
$gateDone = @{}       # phase number -> gate ticked
$firstOpen = $null
$nextPointer = $null
$curStep = $null

foreach ($l in $status) {
    if ($l -match "^\*\*Next sub-step:\*\*\s*($SubStepPattern)") { $nextPointer = $Matches[1]; continue }
    if ($l -match "^#{3,6}\s+$StepWord\s+($StepPattern)\b") {
        $curStep = $Matches[1]
        $sSteps.Add($curStep)
        $stepOpen[$curStep] = 0
        $stepDone[$curStep] = $false
        continue
    }
    if ($l -match '^##\s') { $curStep = $null; continue }
    if ($l -match "^\s*-\s+\[([ xX])\]\s+($SubStepPattern)\s") {
        $ticked = ($Matches[1] -ne ' ')
        $id = $Matches[2]
        $sSub.Add($id)
        if (-not $ticked) {
            if (-not $firstOpen) { $firstOpen = $id }
            if ($curStep) { $stepOpen[$curStep] = $stepOpen[$curStep] + 1 }
        }
        continue
    }
    if ($l -match '^\s*-\s+\[([ xX])\]\s+Done when:') {
        if ($curStep) { $stepDone[$curStep] = ($Matches[1] -ne ' ') }
        continue
    }
    if ($l -match "^\s*-\s+\[([ xX])\]\s+\*\*$GateWord\s+($GatePattern)\s+gate:") {
        $sGates.Add($Matches[2])
        $gateDone[$Matches[2]] = ($Matches[1] -ne ' ')
        continue
    }
}

$okSub = Compare-IdList 'Sub-steps' $dSub.ToArray() $sSub.ToArray()
$okSteps = Compare-IdList 'Steps' $dSteps.ToArray() $sSteps.ToArray()
$okGates = Compare-IdList "$GateWord gates" $dGates.ToArray() $sGates.ToArray()
if ($okSub -and $okSteps -and $okGates) {
    $report.Add("[OK]      Roadmap sync: $($dSub.Count) sub-steps, $($dSteps.Count) steps, and $($dGates.Count) gates match DESIGN.md")
} else {
    $report.Add('[PROBLEM] Roadmap sync: ROADMAP_STATUS.md does not match DESIGN.md (details below)')
}

if ($noDoneWhen.Count) {
    $notes.Add("Steps with no ""Done when"" line in DESIGN.md: $($noDoneWhen -join ', '). Add one in the design doc, or confirm the phase gate covers it.")
    $report.Add("[NOTE]    Done-when lines: $($noDoneWhen.Count) step(s) in DESIGN.md have none ($($noDoneWhen -join ', '))")
} else {
    $report.Add("[OK]      Done-when lines: every step in DESIGN.md has one")
}

# --- 4. Status consistency ------------------------------------------------------------

$before = $problems.Count
foreach ($step in $sSteps) {
    if ($stepDone[$step] -and $stepOpen[$step] -gt 0) {
        $problems.Add("Step $step has its ""Done when"" ticked but $($stepOpen[$step]) sub-step(s) still open")
    }
}
foreach ($phase in $sGates) {
    if ($gateDone[$phase]) {
        $openSteps = @($sSteps | Where-Object { (Get-GateOf $_) -eq $phase -and -not $stepDone[$_] })
        if ($openSteps.Count) {
            $problems.Add("$GateWord $phase gate is ticked but these steps are not done: $($openSteps -join ', ')")
        }
    }
}
if (-not $nextPointer) {
    # Pre-production has no roadmap to point into yet.
    if (-not $preProduction) { $problems.Add('ROADMAP_STATUS.md has no "**Next sub-step:** <id>" line') }
} elseif ($firstOpen -and $nextPointer -ne $firstOpen -and -not $preProduction) {
    $problems.Add("ROADMAP_STATUS.md says the next sub-step is $nextPointer, but the first open one is $firstOpen")
}
if ($problems.Count -eq $before) {
    $where = if ($preProduction) { 'no sub-step is due until production starts' }
             elseif ($firstOpen) { "next sub-step is $firstOpen" }
             else { 'every sub-step is ticked' }
    $report.Add("[OK]      Status consistency: ticks agree, $where")
} else {
    $report.Add('[PROBLEM] Status consistency: see details below')
}

# --- 5. Parking lot sync ------------------------------------------------------------------

$designIdeas = Get-TableIdeas (Get-Section $design @('Parking lot', 'After v1 parking lot'))
$afterIdeas = Get-TableIdeas (Read-Doc 'docs/AFTER_V1.md')
$onlyAfter = @($afterIdeas | Where-Object { $designIdeas -notcontains $_ })
$onlyDesign = @($designIdeas | Where-Object { $afterIdeas -notcontains $_ })
if ($onlyDesign.Count) {
    $problems.Add("Parking-lot ideas in DESIGN.md but missing from AFTER_V1.md: $($onlyDesign -join '; ')")
}
if ($onlyAfter.Count) {
    $notes.Add("Parking-lot ideas in AFTER_V1.md but not in DESIGN.md: $($onlyAfter -join '; '). Copy them into the design doc's parking lot.")
}
if ($onlyAfter.Count -or $onlyDesign.Count) {
    $report.Add("[CHECK]   Parking lot: $($onlyDesign.Count) idea(s) only in DESIGN.md, $($onlyAfter.Count) only in AFTER_V1.md")
} else {
    $report.Add("[OK]      Parking lot: $($afterIdeas.Count) ideas, same in both docs")
}

# --- Placeholders and setup blanks ---------------------------------------------------------

$inGit = $false
$top = git -C $root rev-parse --show-toplevel 2>$null
if ($LASTEXITCODE -eq 0 -and $top -and ((Resolve-Path $top).Path -eq $root)) { $inGit = $true }
if ($inGit) {
    $allFiles = @(git -C $root -c core.quotepath=off ls-files --cached --others --exclude-standard)
} else {
    $allFiles = @(Get-ChildItem -LiteralPath $root -Recurse -File -Force |
        Where-Object { $_.FullName -notmatch '[\\/]\.git[\\/]' } |
        ForEach-Object { $_.FullName.Substring($root.Length + 1).Replace('\', '/') })
}
$textFiles = @($allFiles | Where-Object {
    $_ -and ($TextExtensions -contains [IO.Path]::GetExtension($_).ToLowerInvariant()) -and
    (Test-Path -LiteralPath (Join-Path $root $_))
})

foreach ($kind in $PlaceholderKinds) {
    $counts = @()
    foreach ($f in $textFiles) {
        if (Test-Skipped $f $PlaceholderSkip) { continue }
        # Not -SimpleMatch: Windows PowerShell 5.1 leaves .Matches empty with it.
        $n = (Select-String -LiteralPath (Join-Path $root $f) -Pattern $kind -CaseSensitive -AllMatches |
            ForEach-Object { $_.Matches.Count } | Measure-Object -Sum).Sum
        if ($n) { $counts += [pscustomobject]@{ File = $f; Count = $n } }
    }
    $total = ($counts | Measure-Object -Property Count -Sum).Sum
    if (-not $total) { $total = 0 }
    $report.Add("[INFO]    $kind placeholders: $total in $($counts.Count) file(s)")
    foreach ($c in $counts) { $report.Add("            $($c.File): $($c.Count)") }
}

# TODO-DESIGN markers: prompts that pre-production fills in. Expected until then, so
# only a count; once the stage is past Pre-production, any left are a note for the owner.
$markers = @()
foreach ($f in $textFiles) {
    if (Test-Skipped $f $DesignMarkerSkip) { continue }
    $n = (Select-String -LiteralPath (Join-Path $root $f) -Pattern 'TODO-DESIGN' -CaseSensitive -AllMatches |
        ForEach-Object { $_.Matches.Count } | Measure-Object -Sum).Sum
    if ($n) { $markers += [pscustomobject]@{ File = $f; Count = $n } }
}
$total = ($markers | Measure-Object -Property Count -Sum).Sum
if (-not $total) { $total = 0 }
if ($total -and $stage -and -not $preProduction) {
    $notes.Add("$total TODO-DESIGN marker(s) are left in $($markers.Count) file(s), though pre-production is over. Fill them in, or remove the ones that don't apply.")
    $report.Add("[CHECK]   TODO-DESIGN markers: $total in $($markers.Count) file(s), past pre-production")
} else {
    $report.Add("[INFO]    TODO-DESIGN markers: $total in $($markers.Count) file(s)")
}
foreach ($m in $markers) { $report.Add("            $($m.File): $($m.Count)") }

# Double-brace blanks left from install, in Markdown only, since code can use braces for
# other things. A blank in backticks is an example, so it doesn't count.
$blanks = @()
foreach ($f in $textFiles) {
    if ([IO.Path]::GetExtension($f).ToLowerInvariant() -ne '.md') { continue }
    $n = (Select-String -LiteralPath (Join-Path $root $f) -Pattern '(?<!`)\{\{[^}]+\}\}' -AllMatches |
        ForEach-Object { $_.Matches.Count } | Measure-Object -Sum).Sum
    if ($n) { $blanks += [pscustomobject]@{ File = $f; Count = $n } }
}
if ($blanks.Count) {
    $total = ($blanks | Measure-Object -Property Count -Sum).Sum
    $notes.Add("$total install blank(s) in double braces are still to fill in, in $($blanks.Count) file(s). See the README's setup steps.")
    $report.Add("[CHECK]   Setup blanks: $total left in $($blanks.Count) file(s)")
    foreach ($b in $blanks) { $report.Add("            $($b.File): $($b.Count)") }
} else {
    $report.Add('[OK]      Setup blanks: none left')
}

# --- Output ------------------------------------------------------------------------------------

Write-Host 'Doc check (.claude/kit/tools/check-docs.ps1)'
Write-Host ''
foreach ($r in $report) { Write-Host $r }
if ($problems.Count) {
    Write-Host ''
    Write-Host 'Problems (Claude should fix):'
    foreach ($p in $problems) { Write-Host "  - $p" }
}
if ($notes.Count) {
    Write-Host ''
    Write-Host "Notes for $Owner (only $Owner can change these):"
    foreach ($n in $notes) { Write-Host "  - $n" }
}
Write-Host ''
Write-Host "Result: $($problems.Count) problem(s), $($notes.Count) note(s) for $Owner."
if ($problems.Count) { exit 1 } else { exit 0 }
