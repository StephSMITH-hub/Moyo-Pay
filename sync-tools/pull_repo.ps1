# ==============================================================================
# Moyo-Pay: GitHub Pull & Repository Updater Script
# ==============================================================================
param(
    [switch]$Force
)

$ErrorActionPreference = "Stop"

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

function Write-Banner {
    param([string]$Text, [string]$Color = "Cyan")
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

Write-Banner "MOYO-PAY: PULL LATEST GITHUB REPOSITORY UPDATES" "Cyan"

$branch = (git rev-parse --abbrev-ref HEAD 2>$null)
if (-not $branch) { $branch = "main" }

Write-Host "[INFO] Repository: $repoRoot" -ForegroundColor DarkGray
Write-Host "[INFO] Current Branch: $branch" -ForegroundColor DarkGray
Write-Host "[INFO] Fetching all updates from remote GitHub origin..." -ForegroundColor Cyan

# Fetch all remote refs
git fetch --all --prune

# Check if there are local uncommitted changes
$localChanges = (git status --porcelain 2>$null)
$stashed = $false

if ($localChanges) {
    Write-Host "`n[NOTICE] Uncommitted local modifications detected." -ForegroundColor Yellow
    Write-Host "Safely stashing local work before pulling remote changes..." -ForegroundColor Yellow
    $stashTag = "auto-stash-pull-" + (Get-Date).ToString("yyyyMMdd-HHmmss")
    git stash push -m "$stashTag"
    $stashed = $true
}

$headBefore = (git rev-parse HEAD 2>$null)

Write-Host "`n[PULL] Merging latest updates from origin/$branch..." -ForegroundColor Cyan
$pullResult = git pull origin $branch 2>&1

$headAfter = (git rev-parse HEAD 2>$null)

# Restore stash if we stashed earlier
if ($stashed) {
    Write-Host "`n[RESTORE] Re-applying your uncommitted local work..." -ForegroundColor Cyan
    $stashPop = git stash pop 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[WARNING] Conflict or issue popping stash. Your changes are preserved in git stash." -ForegroundColor Red
        Write-Host "Run 'git stash list' to view stashed changes." -ForegroundColor Yellow
    } else {
        Write-Host "[OK] Local changes restored successfully." -ForegroundColor Green
    }
}

if ($headBefore -ne $headAfter) {
    Write-Banner "REPOSITORY UPDATED WITH NEW COMMITS!" "Green"
    Write-Host "New updates pulled into local folder:`n" -ForegroundColor Green
    git log --graph --oneline --decorate -n 5
    Write-Host "`nFiles updated in this pull:" -ForegroundColor Cyan
    git diff --stat $headBefore $headAfter
} else {
    Write-Banner "REPOSITORY IS ALREADY UP TO DATE!" "Green"
    Write-Host "No new commits found on GitHub. You already have the latest version.`n" -ForegroundColor DarkGray
    Write-Host "Current HEAD commit:" -ForegroundColor Cyan
    git log -1 --oneline
}

Write-Host ""
