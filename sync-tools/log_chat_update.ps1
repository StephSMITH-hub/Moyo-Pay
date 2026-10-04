# ==============================================================================
# Moyo-Pay: Chat Update Logger & GitHub Synchronizer
# ==============================================================================
param(
    [string]$Topic = "",
    [string]$Summary = "",
    [string]$Notes = "",
    [switch]$NoPush
)

$ErrorActionPreference = "Continue"

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

function Write-Banner {
    param([string]$Text, [string]$Color = "Magenta")
    Write-Host ""
    Write-Host ("=" * 60) -ForegroundColor $Color
    Write-Host "  $Text" -ForegroundColor $Color
    Write-Host ("=" * 60) -ForegroundColor $Color
    Write-Host ""
}

$repoRoot = (git rev-parse --show-toplevel 2>$null)
if (-not $repoRoot) {
    Write-Host "[ERROR] This folder is not a Git repository!" -ForegroundColor Red
    exit 1
}
Set-Location $repoRoot

$logFile = Join-Path $repoRoot "CHAT_UPDATES.md"
if (-not (Test-Path $logFile)) {
    Write-Host "[INFO] Initializing CHAT_UPDATES.md..." -ForegroundColor Yellow
    $initContent = @(
        "# Moyo Pay Project & Chat Updates Log",
        "",
        "This file tracks progress, ongoing chat sessions, decisions, and updates made to the **Moyo Pay** repository. Every time you log an update using ``log_chat_update.bat`` or sync progress, it is recorded here and automatically pushed to GitHub.",
        "",
        "---",
        "",
        "## Quick Summary & Current Status",
        "- **Repository**: [StephSMITH-hub/Moyo-Pay](https://github.com/StephSMITH-hub/Moyo-Pay)",
        "- **Active Branch**: main",
        "",
        "---",
        "",
        "## Chronological Chat & Progress Logs",
        ""
    ) -join "`r`n"
    [System.IO.File]::WriteAllText($logFile, $initContent, [System.Text.Encoding]::UTF8)
}

Write-Banner "MOYO-PAY: LOG CHAT UPDATE & SYNC" "Magenta"

# Interactive prompts if arguments were not passed
if ([string]::IsNullOrWhiteSpace($Topic) -and [string]::IsNullOrWhiteSpace($Summary)) {
    Write-Host "Enter details for your current chat session / progress update:`n" -ForegroundColor Cyan
    
    $Topic = Read-Host "Topic / Category (e.g., Affiliate Model, Copywriting, Funnel, Dev)"
    if ([string]::IsNullOrWhiteSpace($Topic)) {
        $Topic = "General Progress & Workspace Chat"
    }

    $Summary = Read-Host "Summary of chat / work done"
    if ([string]::IsNullOrWhiteSpace($Summary)) {
        $Summary = "Updated project materials, strategies, and workspace assets."
    }

    $Notes = Read-Host "Key bullet points (optional, separate multiple with semicolon ';')"
} elseif ([string]::IsNullOrWhiteSpace($Topic)) {
    $Topic = "Folder & Chat Update"
}

# Inspect git modified files to record what was changed alongside this chat
$gitChanges = (git status --porcelain 2>$null)
$fileList = @()
if ($gitChanges) {
    foreach ($line in $gitChanges) {
        if ($line.Length -gt 3) {
            $fileList += ($line.Substring(3)).Trim()
        }
    }
}

$nowStr = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
$dateTag = (Get-Date).ToString("yyyy-MM-dd")

# Build the entry as lines
$lines = [System.Collections.Generic.List[string]]::new()
$lines.Add("### [$nowStr] $Topic")
$lines.Add("- **Summary**: $Summary")

if (-not [string]::IsNullOrWhiteSpace($Notes)) {
    $lines.Add("- **Key Discussion / Action Items**:")
    $bulletItems = $Notes -split ";"
    foreach ($b in $bulletItems) {
        $trimmed = $b.Trim()
        if (-not [string]::IsNullOrWhiteSpace($trimmed)) {
            $lines.Add("  - $trimmed")
        }
    }
}

if ($fileList.Count -gt 0) {
    $lines.Add("- **Workspace Files Impacted**:")
    foreach ($f in ($fileList | Select-Object -First 8)) {
        $lines.Add("  - ``$f``")
    }
    if ($fileList.Count -gt 8) {
        $lines.Add("  - ... and $($fileList.Count - 8) additional files")
    }
}

$lines.Add("- **GitHub Sync Status**: Synced")
$lines.Add("---")
$lines.Add("")

$newEntryText = ($lines -join "`r`n") + "`r`n"

# Insert new entry right under "## Chronological Chat & Progress Logs"
$content = [System.IO.File]::ReadAllText($logFile, [System.Text.Encoding]::UTF8)
$targetAnchor = "## Chronological Chat & Progress Logs"
if (-not $content.Contains($targetAnchor)) {
    $targetAnchor = "## 🕒 Chronological Chat & Progress Logs"
}

if ($content.Contains($targetAnchor)) {
    $targetIndex = $content.IndexOf($targetAnchor) + $targetAnchor.Length
    $updatedContent = $content.Substring(0, $targetIndex) + "`r`n`r`n" + $newEntryText + $content.Substring($targetIndex).TrimStart("`r`n")
    [System.IO.File]::WriteAllText($logFile, $updatedContent, [System.Text.Encoding]::UTF8)
} else {
    [System.IO.File]::AppendAllText($logFile, "`r`n" + $newEntryText, [System.Text.Encoding]::UTF8)
}

Write-Host "`n[SUCCESS] Chat update logged to CHAT_UPDATES.md!" -ForegroundColor Green

# Push directly to GitHub unless -NoPush is specified
if (-not $NoPush) {
    Write-Host "`n[SYNC] Committing and pushing update to GitHub..." -ForegroundColor Cyan
    $branch = (git rev-parse --abbrev-ref HEAD 2>$null)
    if (-not $branch) { $branch = "main" }
    
    git add -A
    $commitMsg = "docs(chat-log): [$dateTag] $Topic - $Summary"
    if ($commitMsg.Length -gt 72) {
        $commitMsg = $commitMsg.Substring(0, 69) + "..."
    }
    git commit -m "$commitMsg"
    git push origin $branch
    
    if ($LASTEXITCODE -eq 0) {
        Write-Banner "CHAT UPDATE SAVED & SYNCED TO GITHUB!" "Green"
    } else {
        Write-Host "`n[WARNING] Push to GitHub encountered an issue. Changes are saved locally." -ForegroundColor Yellow
    }
} else {
    Write-Host "[NOTE] Local file updated. GitHub push skipped (-NoPush)." -ForegroundColor Yellow
}

# Display recent updates summary for user awareness
Write-Host "`n----- RECENT CHAT UPDATES IN MOYO-PAY -----" -ForegroundColor Cyan
$recentLines = Get-Content -Path $logFile -Encoding utf8
$count = 0
foreach ($line in $recentLines) {
    if ($line.StartsWith("### [")) {
        $count++
        if ($count -gt 2) { break }
    }
    if ($count -ge 1 -and $line -ne "---") {
        Write-Host $line -ForegroundColor Gray
    }
}
Write-Host "--------------------------------------------`n" -ForegroundColor Cyan
Write-Host "Full log file: CHAT_UPDATES.md" -ForegroundColor DarkGray
