#!/bin/sh
# Runs a kit PowerShell script with PowerShell 7 (pwsh) if it's installed,
# else Windows PowerShell. Used by Claude Code hooks and the Git pre-commit
# hook, which both start in sh.
# Usage: sh run-ps.sh <script.ps1> [arguments]

if command -v pwsh >/dev/null 2>&1; then
    if [ "$OS" = "Windows_NT" ]; then
        exec pwsh -NoProfile -ExecutionPolicy Bypass -File "$@"
    fi
    exec pwsh -NoProfile -File "$@"
fi
if command -v powershell.exe >/dev/null 2>&1; then
    exec powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$@"
fi
echo "run-ps.sh: neither pwsh nor Windows PowerShell was found. Install PowerShell 7." >&2
exit 1
