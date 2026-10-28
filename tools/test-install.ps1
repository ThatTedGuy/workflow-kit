# Tests tools/install.ps1 in a temp folder: a fresh install, its result,
# the refusals, and an update. -WithClaude also asks a headless Claude Code
# session in the test project what it loaded (uses a little usage).
#
# Run: pwsh -NoProfile -File tools/test-install.ps1 [-WithClaude] [-Keep]
# Windows PowerShell 5.1: powershell -NoProfile -ExecutionPolicy Bypass -File tools/test-install.ps1
# It tests whichever of the two runs it.

param(
    [switch]$WithClaude,
    [switch]$Keep
)

$ErrorActionPreference = 'Stop'
$KitRoot = Split-Path -Parent $PSScriptRoot
$Install = Join-Path $PSScriptRoot 'install.ps1'
$Answers = Join-Path $KitRoot 'tests/sample-answers.psd1'
$Skills = @('code', 'plan-it', 'pre-pro', 'qa-docreview', 'quick-fix', 'review-fix-commit', 'talk')
$Version = (Get-Content -LiteralPath (Join-Path $KitRoot 'VERSION') -Raw).Trim()

$base = Join-Path ([System.IO.Path]::GetTempPath()) 'kit-install-test'
if (Test-Path -LiteralPath $base) { Remove-Item -LiteralPath $base -Recurse -Force }
New-Item -ItemType Directory -Path $base | Out-Null
$project = Join-Path $base 'project'

# Child scripts run in the same PowerShell as this test (pwsh or Windows PowerShell),
# so one run tests one shell.
$PSExe = (Get-Process -Id $PID).Path
$PSArgs = @('-NoProfile')
if ($env:OS -eq 'Windows_NT') { $PSArgs += @('-ExecutionPolicy', 'Bypass') }

$script:failures = 0
function Check([string]$Name, [bool]$Ok, [string]$Detail = '') {
    if ($Ok) { Write-Output "  pass  $Name" }
    else { Write-Output "  FAIL  $Name $Detail"; $script:failures++ }
}
# Skips any personal profile unless a test names one, so results don't depend on the machine.
function Run-Install([string[]]$Arguments) {
    if ($Arguments -notcontains '-ProfilePath' -and $Arguments -notcontains '-Update') { $Arguments += '-SkipProfile' }
    $out = & $PSExe @PSArgs -File $Install @Arguments 2>&1 | Out-String
    return [pscustomobject]@{ Code = $LASTEXITCODE; Output = $out }
}
# Keys use / on every system.
function Get-Hashes([string]$Folder) {
    $h = @{}
    $full = (Resolve-Path -LiteralPath $Folder).Path.TrimEnd('\', '/')
    foreach ($f in Get-ChildItem -LiteralPath $Folder -Recurse -Force -File) {
        $h[$f.FullName.Substring($full.Length + 1).Replace('\', '/')] = (Get-FileHash -LiteralPath $f.FullName).Hash
    }
    return $h
}

Write-Output "Test folder: $base"
Write-Output "Shell: $PSExe ($($PSVersionTable.PSEdition) $($PSVersionTable.PSVersion))"

Write-Output 'Fresh install'
$r = Run-Install @('-Project', $project, '-Answers', $Answers)
Check 'install succeeds' ($r.Code -eq 0) $r.Output
$files = @(Get-ChildItem -LiteralPath $project -Recurse -Force -File)
$left = @($files | Select-String -Pattern '\{\{' -List | ForEach-Object { $_.Path })
Check 'no {{ left anywhere' ($left.Count -eq 0) ($left -join ', ')
$disguised = @(Get-ChildItem -LiteralPath $project -Recurse -Force | Where-Object { $_.Name -like 'dot-*' -or $_.Name -like '*.template.md' })
Check 'no disguised names left' ($disguised.Count -eq 0) (($disguised | ForEach-Object { $_.Name }) -join ', ')
$claude = Get-Content -LiteralPath (Join-Path $project 'CLAUDE.md') -Raw
Check 'CLAUDE.md has the import line' ($claude -match '(?m)^@\.claude/kit/RULES\.md\s*$')
Check 'CLAUDE.md has the owner' ($claude -match 'Owner:\*\* Sam\.')
Check 'Kit settings get their defaults' (($claude -match 'Explanation level:\*\* beginner ') -and ($claude -match 'Token use:\*\* strict ') -and ($claude -match 'Multiple-choice questions:\*\* on '))
Check 'RULES.md installed' (Test-Path -LiteralPath (Join-Path $project '.claude/kit/RULES.md'))
Check '.gitattributes installed' (Test-Path -LiteralPath (Join-Path $project '.gitattributes'))
Check 'VERSION written' ((Get-Content -LiteralPath (Join-Path $project '.claude/kit/VERSION') -Raw).Trim() -eq $Version)
foreach ($s in $Skills) {
    $skill = Join-Path $project ".claude/skills/$s/SKILL.md"
    $ok = (Test-Path -LiteralPath $skill) -and ((Get-Content -LiteralPath $skill -TotalCount 5) -contains "name: $s")
    Check "command /$s present" $ok
}

Write-Output 'Doc check in the installed project'
Push-Location $project
$doc = & $PSExe @PSArgs -File '.claude/kit/tools/check-docs.ps1' 2>&1 | Out-String
$docCode = $LASTEXITCODE
Pop-Location
Check 'doc check passes' ($docCode -eq 0) $doc
$doc.TrimEnd() -split '\r?\n' | ForEach-Object { Write-Output "        $_" }

Write-Output '/talk guard in the installed project'
# Exit 0 lets the tool call run; exit 2 blocks it.
$guard = Join-Path $project '.claude/kit/tools/talk-guard.ps1'
$env:CLAUDE_PROJECT_DIR = $project
$guardCases = @(
    @(2, 'blocks a code edit', @{ tool_name = 'Edit'; tool_input = @{ file_path = (Join-Path $project 'src/main.py') } }),
    @(2, 'blocks a DESIGN.md write', @{ tool_name = 'Write'; tool_input = @{ file_path = (Join-Path $project 'docs/DESIGN.md') } }),
    @(2, 'blocks a path that climbs out', @{ tool_name = 'Edit'; tool_input = @{ file_path = (Join-Path $project 'docs/../src/AFTER_V1.md') } }),
    @(2, 'blocks shell commands', @{ tool_name = 'Bash'; tool_input = @{ command = 'ls' } }),
    @(0, 'allows the parking lot', @{ tool_name = 'Edit'; tool_input = @{ file_path = (Join-Path $project 'docs/AFTER_V1.md') } }),
    @(0, 'allows the decision log, relative', @{ tool_name = 'Write'; tool_input = @{ file_path = 'docs/DECISIONS.md' } }),
    @(0, 'allows reading', @{ tool_name = 'Read'; tool_input = @{ file_path = (Join-Path $project 'src/main.py') } })
)
# The guard writes its reason to stderr, which Windows PowerShell turns into an error under 'Stop'.
$ErrorActionPreference = 'Continue'
foreach ($c in $guardCases) {
    $null = ($c[2] | ConvertTo-Json -Compress) | & $PSExe @PSArgs -File $guard 2>&1
    Check "guard $($c[1])" ($LASTEXITCODE -eq $c[0]) "(exit $LASTEXITCODE)"
}
$ErrorActionPreference = 'Stop'
Remove-Item Env:CLAUDE_PROJECT_DIR

Write-Output 'Refusals'
$r = Run-Install @('-Project', $project, '-Answers', $Answers)
Check 'refuses a folder with CLAUDE.md' ($r.Code -ne 0 -and $r.Output -match 'already has')
$partial = Join-Path $base 'partial.psd1'
"@{ OWNER = 'Sam' }" | Set-Content -LiteralPath $partial -Encoding ascii
$empty = Join-Path $base 'empty'
$r = Run-Install @('-Project', $empty, '-Answers', $partial)
Check 'refuses missing answers, writes nothing' ($r.Code -ne 0 -and -not (Test-Path -LiteralPath $empty)) $r.Output
$r = Run-Install @('-Project', $empty, '-Update')
Check 'update refuses a non-kit folder' ($r.Code -ne 0)
$badSetting = Join-Path $base 'bad-setting.psd1'
(Get-Content -LiteralPath $Answers -Raw) -replace '# EXPLANATION_LEVEL\s*=', 'EXPLANATION_LEVEL =' -replace "'beginner'", "'expert'" |
    Set-Content -LiteralPath $badSetting -Encoding ascii
$r = Run-Install @('-Project', $empty, '-Answers', $badSetting)
Check 'refuses a setting value it does not know' ($r.Code -ne 0 -and $r.Output -match 'EXPLANATION_LEVEL' -and -not (Test-Path -LiteralPath $empty)) $r.Output
$r = Run-Install @('-Project', $empty, '-Answers', $Answers, '-AddOns', 'nosuch')
Check 'refuses an add-on it does not know' ($r.Code -ne 0 -and $r.Output -match 'nosuch' -and -not (Test-Path -LiteralPath $empty)) $r.Output
$r = Run-Install @('-Project', $empty, '-Answers', $Answers, '-AddOns', 'game')
Check 'refuses an add-on without the one it needs' ($r.Code -ne 0 -and $r.Output -match 'creative-content' -and -not (Test-Path -LiteralPath $empty)) $r.Output

Write-Output 'Add-ons and profile'
$withAddons = Join-Path $base 'with-addons'
$r = Run-Install @('-Project', $withAddons, '-Answers', $Answers, '-AddOns', 'creative-content,game')
Check 'install with add-ons succeeds' ($r.Code -eq 0) $r.Output
Check 'add-on files copied' (Test-Path -LiteralPath (Join-Path $withAddons 'docs/LORE_BIBLE.md'))
Check 'add-on file replaces the template''s' ((Get-Content -LiteralPath (Join-Path $withAddons '.gitattributes') -Raw) -match 'filter=lfs')
Check 'CLAUDE.md lists the add-ons' ((Get-Content -LiteralPath (Join-Path $withAddons 'CLAUDE.md') -Raw) -match 'Add-ons:\*\* `creative-content`, `game`\.')
Push-Location $withAddons
$doc = & $PSExe @PSArgs -File '.claude/kit/tools/check-docs.ps1' 2>&1 | Out-String
Pop-Location
Check 'doc check passes with add-ons' ($LASTEXITCODE -eq 0) $doc
$noOwner = Join-Path $base 'no-owner.psd1'
(Get-Content -LiteralPath $Answers) | Where-Object { $_ -notmatch '^\s*OWNER\s*=' } | Set-Content -LiteralPath $noOwner -Encoding ascii
$fromProfile = Join-Path $base 'from-profile'
$r = Run-Install @('-Project', $fromProfile, '-Answers', $noOwner, '-ProfilePath', (Join-Path $KitRoot 'personal/example.psd1'))
$claudeP = if (Test-Path -LiteralPath (Join-Path $fromProfile 'CLAUDE.md')) { Get-Content -LiteralPath (Join-Path $fromProfile 'CLAUDE.md') -Raw } else { '' }
Check 'profile fills the owner and add-ons' ($r.Code -eq 0 -and $claudeP -match 'Owner:\*\* Sam\.' -and $claudeP -match 'Add-ons:\*\* `creative-content`\.') $r.Output
$r = Run-Install @('-Project', (Join-Path $base 'no-profile'), '-Answers', $noOwner)
Check 'without a profile, a missing owner stops install' ($r.Code -ne 0 -and $r.Output -match 'OWNER') $r.Output

Write-Output 'Update'
# Fake an older project: an edited kit file, a file the kit dropped, an old
# version, plus project-owned changes that must survive.
Add-Content -LiteralPath (Join-Path $project '.claude/kit/RULES.md') -Value 'local edit'
Set-Content -LiteralPath (Join-Path $project '.claude/kit/dropped.txt') -Value 'old kit file'
[System.IO.File]::WriteAllText((Join-Path $project '.claude/kit/VERSION'), "0.9.0`n")
New-Item -ItemType Directory -Path (Join-Path $project '.claude/skills/mine') | Out-Null
Set-Content -LiteralPath (Join-Path $project '.claude/skills/mine/SKILL.md') -Value "---`nname: mine`n---`nProject skill."
Add-Content -LiteralPath (Join-Path $project 'CLAUDE.md') -Value 'Project note.'
$before = Get-Hashes $project
$r = Run-Install @('-Project', $project, '-Update')
Check 'update succeeds' ($r.Code -eq 0) $r.Output
Check 'update prints the changelog' ($r.Output -match "## $([regex]::Escape($Version))")
$after = Get-Hashes $project
$templateRules = (Get-FileHash -LiteralPath (Join-Path $KitRoot 'template/dot-claude/kit/RULES.md')).Hash
Check 'kit-owned file replaced' ($after['.claude/kit/RULES.md'] -eq $templateRules)
Check 'dropped kit file removed' (-not $after.ContainsKey('.claude/kit/dropped.txt'))
Check 'VERSION updated' ((Get-Content -LiteralPath (Join-Path $project '.claude/kit/VERSION') -Raw).Trim() -eq $Version)
$kitOwned = '^\.claude/(kit/|skills/(' + ($Skills -join '|') + ')/)'
$changed = @($before.Keys | Where-Object { $_ -notmatch $kitOwned -and $before[$_] -ne $after[$_] })
Check 'project-owned files unchanged' ($changed.Count -eq 0) ($changed -join ', ')

Write-Output 'License hook (Git pre-commit)'
# Git writes progress to stderr, which Windows PowerShell turns into an error under 'Stop'.
$ErrorActionPreference = 'Continue'
function Git-Commit([string]$Message) {
    $out = git -C $project -c commit.gpgsign=false commit -q -m $Message 2>&1 | Out-String
    return [pscustomobject]@{ Code = $LASTEXITCODE; Output = $out }
}
git -C $project init -q 2>&1 | Out-Null
git -C $project config user.name 'Kit Test'
git -C $project config user.email 'kit-test@example.invalid'
git -C $project config core.hooksPath .githooks
git -C $project add -A 2>&1 | Out-Null
$r = Git-Commit 'Initial commit'
Check 'first commit passes' ($r.Code -eq 0) $r.Output
New-Item -ItemType Directory -Path (Join-Path $project 'art') | Out-Null
[System.IO.File]::WriteAllBytes((Join-Path $project 'art/logo.png'), [byte[]](137, 80, 78, 71))
git -C $project add art/logo.png 2>&1 | Out-Null
$r = Git-Commit 'Add logo'
Check 'blocks an asset with no credit' ($r.Code -ne 0 -and $r.Output -match 'art/logo\.png' -and $r.Output -match 'How to fix') $r.Output
Add-Content -LiteralPath (Join-Path $project 'CREDITS.md') -Value "`n## Logo`n`n- Files: ``art/logo.png```n- License: CC0`n"
$r = Git-Commit 'Add logo'
Check 'still blocks while CREDITS.md is unstaged' ($r.Code -ne 0) $r.Output
git -C $project add CREDITS.md 2>&1 | Out-Null
[System.IO.File]::WriteAllBytes((Join-Path $project 'art/other.png'), [byte[]](137, 80, 78, 71))
$r = Git-Commit 'Add logo'
Check 'passes with the entry staged, ignoring unstaged files' ($r.Code -eq 0) $r.Output
$ErrorActionPreference = 'Stop'

if ($WithClaude) {
    Write-Output 'Headless Claude Code session in the test project'
    $exe = (Get-Command claude -ErrorAction SilentlyContinue).Source
    if (-not $exe -and $env:APPDATA) {
        $exe = Get-ChildItem -Path (Join-Path $env:APPDATA 'Claude/claude-code') -Recurse -Filter 'claude.exe' -ErrorAction SilentlyContinue |
            Sort-Object LastWriteTime -Descending | Select-Object -First 1 -ExpandProperty FullName
    }
    if (-not $exe) { Check 'claude found' $false 'no claude on PATH or in the desktop app' }
    else {
        $prompt = 'Answer from your context only, without tools. Line 1: the project owner named in your project instructions. Line 2: YES if your instructions include the text "This file is kit-owned", else NO. Then every slash command or skill defined in this project''s .claude/skills folder, one name per line, and nothing else.'
        Push-Location $project
        $answer = & $exe -p $prompt --model haiku --max-turns 1 2>&1 | Out-String
        Pop-Location
        $answer.TrimEnd() -split '\r?\n' | ForEach-Object { Write-Output "        $_" }
        if ($answer -match 'Not logged in|/login') {
            Write-Output '  skip  headless session: this claude is not signed in. Run it once and use /login, or check in the desktop app (README, "Testing the kit").'
        }
        else {
            Check 'session names the owner' ($answer -match 'Sam')
            Check 'session loaded RULES.md through the import' ($answer -match 'YES')
            foreach ($s in $Skills + @('mine')) { Check "session sees /$s" ($answer -match "(?m)^\W*/?$([regex]::Escape($s))\W*$") }
        }
    }
}

if (-not $Keep) { Remove-Item -LiteralPath $base -Recurse -Force }
if ($script:failures -gt 0) { Write-Output "FAIL: $script:failures check(s) failed."; exit 1 }
Write-Output 'OK: every install check passed.'
exit 0
