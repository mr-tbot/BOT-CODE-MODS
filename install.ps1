#Requires -Version 5.1
<#
  BOT-CODE-MODS installer (Windows).
  Installs a persistent system prompt into Claude Code and VS Code Chat / Copilot, plus the auto-audit
  agent skill. Optionally installs the caveman compression mode.

  Examples:
    powershell -ExecutionPolicy Bypass -File .\install.ps1
    powershell -ExecutionPolicy Bypass -File .\install.ps1 -Caveman
    powershell -ExecutionPolicy Bypass -File .\install.ps1 -NoAutoAudit
#>
param(
    [switch]$Caveman,
    [switch]$NoAutoAudit,
    [string]$PromptFile
)
$ErrorActionPreference = 'Stop'
$root = $PSScriptRoot

function Write-Utf8NoBom([string]$Path, [string]$Content) {
    $dir = Split-Path -Parent $Path
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    [System.IO.File]::WriteAllText($Path, $Content, (New-Object System.Text.UTF8Encoding($false)))
}
function Backup-IfExists([string]$Path) {
    if (Test-Path $Path) {
        Copy-Item $Path "$Path.bak-$(Get-Date -Format yyyyMMdd-HHmmss)" -Force
        Write-Host "  backed up existing -> $Path.bak-*" -ForegroundColor DarkYellow
    }
}

# --- load the prompt ---
$instrPath = if ($PromptFile) { $PromptFile } else { Join-Path $root 'system-prompt.md' }
if (-not (Test-Path $instrPath)) { throw "prompt file not found: $instrPath" }
$instr = [System.IO.File]::ReadAllText($instrPath)

# --- 1. Claude Code (~/.claude/CLAUDE.md) ---
$claude = Join-Path $env:USERPROFILE '.claude\CLAUDE.md'
Backup-IfExists $claude
Write-Utf8NoBom $claude $instr
Write-Host "[ok] Claude Code  -> $claude" -ForegroundColor Green

# --- 2. VS Code Chat / Copilot user instructions (all detected variants) ---
$frontmatter = @"
---
description: BOT-CODE-MODS global agent instructions (applies to every chat request)
applyTo: '**'
---

"@
$vscodeContent = $frontmatter + $instr
$variants = @(
    (Join-Path $env:APPDATA 'Code\User'),
    (Join-Path $env:APPDATA 'Code - Insiders\User'),
    (Join-Path $env:APPDATA 'VSCodium\User')
)
$found = @()
foreach ($u in $variants) { if (Test-Path $u) { $found += $u } }
if (-not $found) { $found = @((Join-Path $env:APPDATA 'Code\User')) }
foreach ($u in $found) {
    $target = Join-Path $u 'prompts\bot-code-mods.instructions.md'
    Backup-IfExists $target
    Write-Utf8NoBom $target $vscodeContent
    Write-Host "[ok] VS Code Chat -> $target" -ForegroundColor Green
}

# --- 3. auto-audit agent skill (skip with -NoAutoAudit) ---
if (-not $NoAutoAudit) {
    $skillSrc = Join-Path $root 'skills\auto-audit\SKILL.md'
    if (Test-Path $skillSrc) {
        $skillRoots = @((Join-Path $env:USERPROFILE '.claude\skills'))
        # ~/.agents/skills is the cross-runtime alias (Codex, Copilot CLI, Gemini CLI); mirror only if present
        $agentsRoot = Join-Path $env:USERPROFILE '.agents\skills'
        if (Test-Path $agentsRoot) { $skillRoots += $agentsRoot }
        foreach ($r in $skillRoots) {
            $target = Join-Path $r 'auto-audit\SKILL.md'
            Backup-IfExists $target
            Write-Utf8NoBom $target ([System.IO.File]::ReadAllText($skillSrc))
            Write-Host "[ok] auto-audit   -> $target" -ForegroundColor Green
        }
    } else {
        Write-Host "  [warn] skills\auto-audit\SKILL.md not found; auto-audit skipped." -ForegroundColor Yellow
    }
}

# --- 4. Optional caveman compression mode (third-party, public) ---
if ($Caveman) {
    if (Get-Command node -ErrorAction SilentlyContinue) {
        Write-Host "[*] Installing caveman (github.com/JuliusBrussee/caveman)..." -ForegroundColor Cyan
        try {
            & npx -y "github:JuliusBrussee/caveman" -- --non-interactive
            & npx -y "github:JuliusBrussee/caveman" -- --only claude --with-hooks --force --non-interactive
            Write-Host "[ok] caveman installed (reload the editor to activate)" -ForegroundColor Green
        } catch { Write-Host "  [warn] caveman install error: $($_.Exception.Message)" -ForegroundColor Yellow }
    } else {
        Write-Host "  [warn] node not found; caveman skipped." -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Done. Reload VS Code (Developer: Reload Window) / restart Claude Code, then in chat ask:" -ForegroundColor Cyan
Write-Host "  'what standing instructions are you following?'" -ForegroundColor Cyan
