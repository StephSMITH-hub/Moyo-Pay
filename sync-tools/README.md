# Moyo-Pay Git Sync & Chat Tracker Engine

This folder contains automated synchronization tools created specifically for the **Moyo-Pay** repository. They make it simple to track work, log ongoing chat updates, push progress directly to GitHub, and pull remote repository updates.

---

## 🚀 Quick Start (Root Shortcuts)

You can run these scripts directly by double-clicking them in the root folder, or running them from PowerShell / Command Prompt:

| File | Purpose | When to Use |
| :--- | :--- | :--- |
| `sync_progress.bat` | **Sync & Push Everything** | Run whenever you want to commit all changes in the folder and push directly to GitHub. |
| `log_chat_update.bat` | **Log Chat & Progress** | Run to record your ongoing chat topic, decisions, or session notes into `CHAT_UPDATES.md` and push it to GitHub. |
| `pull_repo.bat` | **Pull Remote Updates** | Run to fetch and pull down all updates from GitHub into your local folder safely (with auto-stash protection). |
| `auto_sync_watcher.bat` | **Continuous Auto-Sync** | Double-click to start a background watcher that checks every 45 seconds for edits and automatically pushes them to GitHub. |
| `CHAT_UPDATES.md` | **Chat & Progress History** | Open anytime to see the chronological record of updates, chats, and work done on this repository per time. |

---

## 🛠️ Detailed Tool Descriptions

### 1. `sync_progress.bat` (`sync-tools/sync_progress.ps1`)
- **What it does**:
  1. Checks Git status for any new, modified, or deleted files.
  2. If there are changes, prompts for an optional commit message (or auto-generates a timestamped message if you press Enter).
  3. Stages all files (`git add -A`).
  4. Commits changes cleanly.
  5. Pushes directly to GitHub `origin/main`.
- **Command-line syntax**:
  ```powershell
  .\sync_progress.bat "Completed direct response copywriting review"
  ```

---

### 2. `log_chat_update.bat` (`sync-tools/log_chat_update.ps1`)
- **What it does**:
  1. Prompts for:
     - **Topic / Category** (e.g. *Affiliate Campaign, Copywriting, Funnel, Development*)
     - **Summary** of the chat / work accomplished
     - **Key bullet points** (optional)
  2. Automatically detects any modified workspace files.
  3. Appends a structured, timestamped entry to `CHAT_UPDATES.md` (newest on top).
  4. Stages, commits, and pushes the update directly to GitHub.
  5. Displays the last 2 updates in the console so you can see your recent history.
- **Command-line syntax**:
  ```powershell
  # Interactive mode:
  .\log_chat_update.bat

  # Direct mode via PowerShell:
  powershell -ExecutionPolicy Bypass -File .\sync-tools\log_chat_update.ps1 -Topic "Brand Strategy" -Summary "Refined value proposition and headline" -Notes "Point 1; Point 2"
  ```

---

### 3. `pull_repo.bat` (`sync-tools/pull_repo.ps1`)
- **What it does**:
  1. Runs `git fetch --all --prune` to check for remote commits on GitHub.
  2. Automatically stashes any unstaged local work before pulling to prevent merge conflicts.
  3. Executes `git pull origin main`.
  4. Restores your uncommitted local work automatically.
  5. Prints a summary of pulled commits and modified files.

---

### 4. `auto_sync_watcher.bat` (`sync-tools/auto_sync_watcher.ps1`)
- **What it does**:
  - Runs in an open console window.
  - Checks the folder every 45 seconds.
  - Whenever you edit or create files, it debounces for 5 seconds, commits them, and pushes them straight to GitHub.
  - Press `Ctrl + C` at any time to stop the watcher.

---

## 📁 Repository Structure
```text
Moyo-Pay/
├── CHAT_UPDATES.md            # Live chat updates and session progress history
├── sync_progress.bat          # 1-Click: Sync & Push all progress to GitHub
├── log_chat_update.bat        # 1-Click: Log chat session & push to GitHub
├── pull_repo.bat              # 1-Click: Pull repository updates from GitHub
├── auto_sync_watcher.bat      # 1-Click: Continuous background auto-sync watcher
└── sync-tools/                # Automation engine directory
    ├── sync_progress.ps1
    ├── log_chat_update.ps1
    ├── pull_repo.ps1
    ├── auto_sync_watcher.ps1
    └── README.md
```
