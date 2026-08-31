#Requires -Version 5.1
<#
  BOT-CODE-MODS installer (Windows).
  Installs a persistent system prompt into Claude Code and VS Code Chat / Copilot, plus every agent
  skill under skills\. Optionally installs the caveman compression mode.

  Examples:
    powershell -ExecutionPolicy Bypass -File .\install.ps1
    powershell -ExecutionPolicy Bypass -File .\install.ps1 -Caveman
    powershell -ExecutionPolicy Bypass -File .\install.ps1 -NoSkills
    powershell -ExecutionPolicy Bypass -File .\install.ps1 -OnlySkill auto-audit,auto-doc
#>
param(
    [switch]$Caveman,
    [switch]$NoSkills,
    [Alias('NoAutoAudit')][switch]$NoSkillsAlias,   # deprecated alias, kept so older instructions keep working
    [string[]]$OnlySkill,
    [string]$PromptFile
)
if ($NoSkillsAlias) { $NoSkills = $true }
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

# --- 3. agent skills — every skills\*\SKILL.md (skip with -NoSkills, narrow with -OnlySkill) ---
if (-not $NoSkills) {
    $skillRoots = @((Join-Path $env:USERPROFILE '.claude\skills'))
    # ~/.agents/skills is the cross-runtime alias (Codex, Copilot CLI, Gemini CLI); mirror only if present
    $agentsRoot = Join-Path $env:USERPROFILE '.agents\skills'
    if (Test-Path $agentsRoot) { $skillRoots += $agentsRoot }

    $found = 0
    Get-ChildItem -Path (Join-Path $root 'skills') -Directory -ErrorAction SilentlyContinue | ForEach-Object {
        $name = $_.Name
        $srcDir = $_.FullName
        if (-not (Test-Path (Join-Path $srcDir 'SKILL.md'))) { return }
        if ($OnlySkill -and ($OnlySkill -notcontains $name)) { return }
        $found++
        foreach ($r in $skillRoots) {
            $skillDir = Join-Path $r $name
            # A symlinked skill dir/file means the user develops that skill from its own repo;
            # writing through the link would overwrite their source. Leave it alone.
            $linked = @($skillDir, (Join-Path $skillDir 'SKILL.md')) | Where-Object { Test-Path $_ } |
                      ForEach-Object { (Get-Item $_ -Force).LinkType } | Where-Object { $_ }
            if ($linked) {
                Write-Host "[skip] $name — $skillDir is a link (live-linked to its source repo)" -ForegroundColor DarkYellow
                continue
            }
            # Copy the whole skill directory, not just SKILL.md: a skill may ship a helper
            # script or reference files beside it.
            $changed = @()
            foreach ($f in (Get-ChildItem -Path $srcDir -File -Recurse | Where-Object { $_.Name -notlike '.*' })) {
                $rel = $f.FullName.Substring($srcDir.Length).TrimStart('\', '/')
                $target = Join-Path $skillDir $rel
                if ((Test-Path $target) -and
                    ((Get-FileHash $target).Hash -eq (Get-FileHash $f.FullName).Hash)) { continue }
                $changed += ,@($f.FullName, $target)
            }
            foreach ($pair in $changed) {
                $dir = Split-Path $pair[1] -Parent
                if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
                Backup-IfExists $pair[1]
                Copy-Item -LiteralPath $pair[0] -Destination $pair[1] -Force
            }
            if ($changed.Count -gt 0) {
                Write-Host "[ok] skill        -> $skillDir\ ($($changed.Count) file(s))" -ForegroundColor Green
            } else {
                Write-Host "[ok] skill        -> $skillDir\ (already current)" -ForegroundColor Green
            }
        }
    }
    if ($found -eq 0) { Write-Host "  [warn] no skills matched; nothing installed from skills\." -ForegroundColor Yellow }
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
