# gdrive Desktop

A desktop client for Google Drive built with Flutter, powered by the [gdrive CLI](https://github.com/haruchanz64/gdrive-cli).

## Overview

gdrive Desktop provides a native desktop interface for managing Google Drive files. It wraps the gdrive CLI to offer folder syncing, revision history, file diff tracking, push/pull operations, and multi-account support — all from a clean, themeable UI.

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
- [gdrive CLI](https://github.com/haruchanz64/gdrive-cli) installed and available on `PATH`
- A Google account authenticated via `gdrive auth login`
- Windows 10 or later

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
flutter run -d windows
```

## Project Structure

```text
lib/
  core/           # CLI runner, color system, theme definitions
  models/         # Data models (Folder, FileStatus, DiffEntry, LogEntry)
  providers/      # State management (Auth, Folder, Status, Log, Diff, Theme)
  screens/        # Top-level screens (Home, Status, Log, Diff, Auth)
  widgets/        # Reusable UI components (Sidebar, TopBar, Tiles, Viewers)
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

## window_manager Setup

This project uses [`window_manager`](https://pub.dev/packages/window_manager) for native window control on Windows.

The following configuration is required in `windows/runner/main.cpp` — no manual changes are needed as this is handled automatically by the package during `flutter pub get`.

If the window title does not update, ensure `windowManager.ensureInitialized()` is called before `runApp` in `main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await windowManager.setTitle('GDrive Desktop');
  runApp(const GDriveDesktopApp());
}
```

## License

MIT License — Copyright (c) 2026 haruchanz64.  
See the [LICENSE](LICENSE) file for the full license text.
