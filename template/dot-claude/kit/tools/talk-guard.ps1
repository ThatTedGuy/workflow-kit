# Claude Code PreToolUse hook for /talk. Keeps the session read-only:
# blocks shell commands and every file edit except the parking lot and
# the decision log. /talk registers it, and it stays on for the rest of
# that session, so building happens in a new session.

$ErrorActionPreference = 'Stop'
$Writable = @('docs/AFTER_V1.md', 'docs/DECISIONS.md')
$Note = '/talk is read-only for the rest of this session. Start a new session to build or run things.'

function Block([string]$Why) {
    [Console]::Error.WriteLine("Blocked: $Why $Note")
    exit 2
}

try { $call = [Console]::In.ReadToEnd() | ConvertFrom-Json }
catch { Block 'the hook could not read the tool call, so it was stopped to be safe.' }

$tool = [string]$call.tool_name
if ($tool -in @('Bash', 'PowerShell')) { Block 'shell commands are off in /talk.' }
if ($tool -notin @('Edit', 'Write', 'MultiEdit', 'NotebookEdit')) { exit 0 }

$path = [string]$call.tool_input.file_path
if (-not $path) { $path = [string]$call.tool_input.notebook_path }
if (-not $path) { Block "$tool gave no file path." }

$root = $env:CLAUDE_PROJECT_DIR
if (-not $root) { $root = [string]$call.cwd }
if (-not [System.IO.Path]::IsPathRooted($path)) { $path = Join-Path $root $path }
$full = [System.IO.Path]::GetFullPath($path)

foreach ($w in $Writable) {
    $allowed = [System.IO.Path]::GetFullPath((Join-Path $root $w))
    # Windows paths ignore case; elsewhere they don't.
    $same = if ([System.IO.Path]::DirectorySeparatorChar -eq '\') { $full -ieq $allowed } else { $full -ceq $allowed }
    if ($same) { exit 0 }
}
Block "in /talk, Claude can change only $($Writable -join ' and ')."
