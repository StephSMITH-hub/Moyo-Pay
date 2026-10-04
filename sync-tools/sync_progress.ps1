# ==============================================================================
# Moyo-Pay: Automated GitHub Progress Sync Script
# ==============================================================================
param(
    [string]$Message = ""
)

$ErrorActionPreference = "Stop"

# Set encoding to UTF8 for clean emoji & formatting output
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

# Resolve repository root
$repoRoot = (git rev-parse --show-toplevel 2>$null)
if (-not $repoRoot) {
    Write-Host "[ERROR] This folder is not a Git repository!" -ForegroundColor Red
    exit 1
}
Set-Location $repoRoot

Write-Banner "MOYO-PAY: GITHUB AUTO-SYNC PROGRESS" "Cyan"

# Get current branch
$branch = (git rev-parse --abbrev-ref HEAD 2>$null)
if (-not $branch) {
    $branch = "main"
}
Write-Host "[INFO] Repository Root: $repoRoot" -ForegroundColor DarkGray
Write-Host "[INFO] Active Branch:   $branch" -ForegroundColor DarkGray

# Check git status
$changes = (git status --porcelain 2>$null)
$unpushed = (git cherry -v 2>$null)

if (-not $changes -and -not $unpushed) {
    Write-Host "`n[OK] Everything is up to date! No changes or pending commits to sync." -ForegroundColor Green
    Write-Host "     Your local folder matches GitHub perfectly.`n" -ForegroundColor DarkGray
    exit 0
}

# Summarize changes
if ($changes) {
    $changeCount = ($changes | Measure-Object).Count
    Write-Host "`n[FOUND] $changeCount modified/new/deleted file(s) detected:" -ForegroundColor Yellow
    $changes | Select-Object -First 10 | ForEach-Object {
        Write-Host "   $_" -ForegroundColor DarkYellow
    }
    if ($changeCount -gt 10) {
        Write-Host "   ... and $($changeCount - 10) more" -ForegroundColor DarkYellow
    }
} else {
    Write-Host "`n[FOUND] Local unpushed commit(s) detected:" -ForegroundColor Yellow
    $unpushed | ForEach-Object { Write-Host "   $_" -ForegroundColor DarkYellow }
}

# Commit message determination
$nowStr = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
if ([string]::IsNullOrWhiteSpace($Message)) {
    if ([Environment]::UserInteractive) {
        Write-Host ""
        Write-Host "Enter an optional commit message (Press ENTER to use auto-generated timestamp):" -ForegroundColor Cyan
        $userInput = Read-Host "Message"
        if (-not [string]::IsNullOrWhiteSpace($userInput)) {
            $Message = $userInput.Trim()
        }
    }
}

if ([string]::IsNullOrWhiteSpace($Message)) {
    $Message = "Progress update: $nowStr ($changeCount file(s) updated)"
}

try {
    if ($changes) {
        Write-Host "`n[1/3] Staging all files..." -ForegroundColor Cyan
        git add -A
        
        Write-Host "[2/3] Committing changes: '$Message'..." -ForegroundColor Cyan
        git commit -m "$Message"
    } else {
        Write-Host "`n[1/2] Staging not required (no unstaged files)..." -ForegroundColor DarkGray
    }

    Write-Host "[3/3] Pushing to GitHub (origin/$branch)..." -ForegroundColor Cyan
    $pushOutput = git push origin $branch 2>&1
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "`n[WARNING] Direct push encountered an issue. Checking for remote updates..." -ForegroundColor Yellow
        Write-Host "Attempting rebase pull..." -ForegroundColor Yellow
        git pull --rebase origin $branch
        git push origin $branch
    }

    $latestCommit = (git log -1 --oneline 2>$null)
    Write-Banner "SUCCESSFULLY SYNCED WITH GITHUB!" "Green"
    Write-Host "Latest Commit: $latestCommit" -ForegroundColor Green
    Write-Host "Synced At:     $nowStr" -ForegroundColor DarkGray
    Write-Host "View online:   https://github.com/StephSMITH-hub/Moyo-Pay" -ForegroundColor Cyan
    Write-Host ""
}
catch {
    Write-Host "`n[ERROR] Sync failed: $_" -ForegroundColor Red
    exit 1
}
