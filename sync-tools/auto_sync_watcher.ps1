# ==============================================================================
# Moyo-Pay: Continuous Auto-Sync Watcher (Background Engine)
# ==============================================================================
param(
    [int]$IntervalSeconds = 45
)

$ErrorActionPreference = "Continue"

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

function Write-Banner {
    param([string]$Text, [string]$Color = "Green")
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

$branch = (git rev-parse --abbrev-ref HEAD 2>$null)
if (-not $branch) { $branch = "main" }

Write-Banner "MOYO-PAY: CONTINUOUS BACKGROUND GITHUB AUTO-SYNC" "Green"
Write-Host "Watching:       $repoRoot" -ForegroundColor DarkGray
Write-Host "GitHub Remote:  origin/$branch" -ForegroundColor DarkGray
Write-Host "Check Interval: Every $IntervalSeconds seconds" -ForegroundColor DarkGray
Write-Host "Press Ctrl + C at any time to stop.`n" -ForegroundColor Yellow

while ($true) {
    $nowStr = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $changes = (git status --porcelain 2>$null)
    $unpushed = (git cherry -v 2>$null)

    if ($changes -or $unpushed) {
        Write-Host "[$nowStr] Detected unsynced changes. Preparing auto-sync..." -ForegroundColor Cyan
        
        # Debounce briefly to allow multiple rapid file edits to settle
        Start-Sleep -Seconds 5
        
        $changeLines = (git status --porcelain 2>$null)
        $count = ($changeLines | Measure-Object).Count
        
        if ($count -gt 0) {
            git add -A
            $commitMsg = "Auto-sync progress: $nowStr ($count file(s) updated)"
            git commit -m "$commitMsg"
        }
        
        Write-Host "[$nowStr] Pushing to GitHub (origin/$branch)..." -ForegroundColor Cyan
        git push origin $branch
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "[$nowStr] [SUCCESS] All progress successfully synced to GitHub!`n" -ForegroundColor Green
        } else {
            Write-Host "[$nowStr] [WARNING] Push failed, pulling with rebase..." -ForegroundColor Yellow
            git pull --rebase origin $branch
            git push origin $branch
        }
    } else {
        Write-Host "[$nowStr] Folder in sync with GitHub. Sleeping ${IntervalSeconds}s..." -ForegroundColor DarkGray
    }

    Start-Sleep -Seconds $IntervalSeconds
}
