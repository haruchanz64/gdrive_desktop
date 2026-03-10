# gdrive Desktop

A developer-oriented Google Drive desktop client built with Flutter. Provides explicit push/pull sync, file diff tracking, revision history, and multi-account support — giving developers full control over what gets synced and when, powered by the [gdrive CLI](https://github.com/haruchanz64/gdrive-cli).

## How is it Different from Google Drive for Desktop?

Google Drive for Desktop (the official app) is a background sync daemon — it mounts your Drive as a virtual disk and silently syncs everything. gdrive Desktop is a developer-oriented tool that gives you explicit control over what gets synced and when.

| | gdrive Desktop | Google Drive for Desktop |
| --- | --- | --- |
| **Sync model** | Manual, explicit push/pull | Automatic, continuous background sync |
| **Change visibility** | Full diff view before syncing | No visibility into what changed |
| **Revision history** | Browsable per-file revision log | Not exposed in the UI |
| **Conflict handling** | Explicit conflict detection | Silent overwrite or duplicate file |
| **Target user** | Developers, power users | General consumers |
| **Installation** | Requires gdrive CLI and Flutter | Standalone installer |
| **Resource usage** | On-demand, no background process | Persistent background daemon |
| **Open source** | Yes | No |

In short, gdrive Desktop trades convenience for control. It is better suited for users who want to treat Google Drive similarly to a Git repository — staging changes, reviewing diffs, and committing syncs deliberately rather than having files silently overwritten in the background.

## Features

- **Folder Management** — Clone, link, or add existing local folders synced to Google Drive.
- **Change Tracking** — View local and remote file changes before syncing.
- **Push / Pull** — Selectively push local changes or pull remote updates.
- **Revision History** — Browse per-file revision history from Google Drive.
- **Diff Viewer** — Inspect differences between local and remote file states.
- **Multi-account Support** — Switch between authenticated Google accounts.
- **Light / Dark Mode** — Persistent theme preference stored locally.
- **Native Window Management** — Custom title bar and window controls via `window_manager`.

## Requirements

- [Flutter](https://docs.flutter.dev/get-started/install) 3.27 or later
- [Node.js](https://nodejs.org) 18 or later
- [gdrive CLI](https://github.com/haruchanz64/gdrive-cli) installed and available on `PATH`
- A Google account authenticated via `gdrive auth login`
- Windows 10 or later, macOS 12 or later, or a modern Linux distribution

## Getting Started

### 1. Install the gdrive CLI

```bash
npm install -g gdrive-cli
```

### 2. Authenticate

```bash
gdrive auth login
```

### 3. Clone this repository

```bash
git clone https://github.com/haruchanz64/gdrive_desktop.git
cd gdrive_desktop
```

### 4. Install dependencies

```bash
flutter pub get
```

### 5. Run the application

```bash
# Windows
flutter run -d windows

# macOS
flutter run -d macos

# Linux
flutter run -d linux
```

## Building

### Windows

```powershell
.\scripts\build.ps1 -Version "1.0.0" -Platform windows
```

### macOS

```bash
bash scripts/build.sh 1.0.0 darwin
```

### Linux

```bash
bash scripts/build.sh 1.0.0 linux
```

### Clean build

```powershell
# Windows
.\scripts\build.ps1 -Version "1.0.0" -Platform windows -Clean
```

```bash
# macOS / Linux
bash scripts/build.sh 1.0.0 darwin true
bash scripts/build.sh 1.0.0 linux true
```

> macOS builds must be run on a Mac. Linux builds must be run on Linux. Cross-compilation is not supported by Flutter for desktop platforms.

## Project Structure

```text
lib/
  core/           # CLI runner, color system, theme definitions
  models/         # Data models (Folder, FileStatus, DiffEntry, LogEntry)
  providers/      # State management (Auth, Folder, Status, Log, Diff, Theme)
  screens/        # Top-level screens (Home, Status, Log, Diff, Auth)
  widgets/        # Reusable UI components (Sidebar, TopBar, Tiles, Viewers)
scripts/
  build.ps1       # Windows build script
  build.sh        # macOS / Linux build script
```

## Dependencies

| Package | Purpose |
| --- | --- |
| `provider` | State management |
| `shared_preferences` | Persistent theme preference |
| `file_picker` | Local folder selection |
| `url_launcher` | Open folders in browser or file explorer |
| `google_fonts` | Inter font family |
| `intl` | Date formatting in revision history |
| `window_manager` | Native window title, size, and controls |

## License

MIT License — Copyright (c) 2026 haruchanz64.  
See the [LICENSE](LICENSE) file for the full license text.
