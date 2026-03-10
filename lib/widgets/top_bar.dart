import 'dart:io';
import 'package:flutter/material.dart';
import 'package:gdrive_desktop/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/colors.dart';
import '../providers/folder_provider.dart';
import '../providers/status_provider.dart';
import '../core/cli_runner.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  Future<void> _openInBrowser(BuildContext context, String? folderId) async {
    final messenger = ScaffoldMessenger.of(context);
    if (folderId == null || folderId.isEmpty) {
      messenger.showSnackBar(const SnackBar(
          content: Text('No remote folder configured for this folder.')));
      return;
    }
    final uri = Uri.parse(
        'https://drive.google.com/drive/folders/$folderId?usp=sharing');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      messenger.showSnackBar(const SnackBar(
          content: Text('Could not open Google Drive in browser.')));
    }
  }

  Future<void> _openInExplorer(BuildContext context, String? path) async {
    final messenger = ScaffoldMessenger.of(context);
    if (path == null || path.isEmpty) {
      messenger.showSnackBar(
          const SnackBar(content: Text('No local folder path found.')));
      return;
    }
    try {
      if (Platform.isWindows) {
        await Process.run('explorer', [path]);
      } else if (Platform.isMacOS) {
        await Process.run('open', [path]);
      } else {
        await Process.run('xdg-open', [path]);
      }
    } catch (e) {
      messenger.showSnackBar(
          SnackBar(content: Text('Could not open folder: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final folder = context.watch<FolderProvider>();
    final status = context.watch<StatusProvider>();
    final theme  = context.watch<ThemeProvider>();
    final active = folder.active;
    final c      = context.colors;

    return Container(
      height: 48,
      color: c.panel,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          // ── Folder Name ───────────────────────────────────────
          _TopBarButton(
            icon: Icons.folder_outlined,
            label: active?.displayName ?? 'No folder',
            onTap: null,
          ),
          const SizedBox(width: 4),
          Container(width: 1, height: 24, color: c.border),
          const SizedBox(width: 4),

          // ── Remote Name ───────────────────────────────────────
          _TopBarButton(
            icon: Icons.cloud_outlined,
            label: active?.remoteName ?? 'No Remote',
            onTap: null,
          ),

          const Spacer(),

          // ── Theme Toggle ──────────────────────────────────────
          IconButton(
            icon: Icon(
              theme.isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
              size: 16,
              color: c.fgSubtle,
            ),
            onPressed: () => context.read<ThemeProvider>().toggle(),
            tooltip: theme.isDark ? 'Switch to light mode' : 'Switch to dark mode',
            splashRadius: 16,
          ),
          Container(width: 1, height: 24, color: c.border),
          const SizedBox(width: 4),

          // ── About ─────────────────────────────────────────────
          IconButton(
            icon: Icon(Icons.info_outline, size: 16, color: c.fgSubtle),
            tooltip: 'About',
            splashRadius: 16,
            onPressed: () => _showAbout(context),
          ),
          Container(width: 1, height: 24, color: c.border),
          const SizedBox(width: 4),

          // ── Show in Explorer ──────────────────────────────────
          _TopBarActionButton(
            icon: Icons.folder_open,
            label: Platform.isWindows
                ? 'Show in Explorer'
                : Platform.isMacOS
                    ? 'Show in Finder'
                    : 'Open in Files',
            onTap: active == null
                ? null
                : () => _openInExplorer(context, active.path),
          ),
          const SizedBox(width: 4),
          Container(width: 1, height: 24, color: c.border),
          const SizedBox(width: 4),

          // ── Open in Drive ─────────────────────────────────────
          _TopBarActionButton(
            icon: Icons.open_in_browser_outlined,
            label: 'Open in Drive',
            onTap: active == null
                ? null
                : () => _openInBrowser(context, active.folderId),
          ),
          const SizedBox(width: 4),
          Container(width: 1, height: 24, color: c.border),
          const SizedBox(width: 4),

          // ── Refresh ───────────────────────────────────────────
          status.loading
              ? Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: c.card.withAlpha(100),
                    border: Border.all(color: c.border),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 13,
                        height: 13,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: c.fgGhost,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Refreshing...',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: c.fgGhost,
                        ),
                      ),
                    ],
                  ),
                )
              : _TopBarActionButton(
                  icon: Icons.refresh,
                  label: 'Refresh',
                  onTap: active == null
                      ? null
                      : () =>
                          context.read<StatusProvider>().refresh(active),
                ),
          const SizedBox(width: 4),
          Container(width: 1, height: 24, color: c.border),
          const SizedBox(width: 4),

          // ── Sync ──────────────────────────────────────────────
          _SyncButton(
            badge: status.files.isNotEmpty ? status.files.length : null,
            enabled: active != null,
          ),
        ],
      ),
    );
  }
}

// ─── Sync Button ──────────────────────────────────────────────────────────────

class _SyncButton extends StatefulWidget {
  final bool enabled;
  final int? badge;

  const _SyncButton({required this.enabled, this.badge});

  @override
  State<_SyncButton> createState() => _SyncButtonState();
}

class _SyncButtonState extends State<_SyncButton>
    with SingleTickerProviderStateMixin {
  bool _syncing = false;
  late final AnimationController _spinController;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  Future<void> _sync(List<String> args) async {
    final folder = context.read<FolderProvider>().active;
    if (folder == null || _syncing) return;

    final messenger     = ScaffoldMessenger.of(context);
    final statusProvider = context.read<StatusProvider>();

    setState(() => _syncing = true);
    _spinController.repeat();

    try {
      for (final arg in args) {
        await CliRunner.run([arg], workingDir: folder.path);
      }
      if (mounted) {
        await statusProvider.refresh(folder);
        messenger.showSnackBar(const SnackBar(
          content: Row(children: [
            Icon(Icons.check_circle, color: Colors.greenAccent, size: 16),
            SizedBox(width: 8),
            Text('Sync complete'),
          ]),
          duration: Duration(seconds: 2),
        ));
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(SnackBar(
          content: Row(children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 16),
            const SizedBox(width: 8),
            Text('Sync failed: $e'),
          ]),
          backgroundColor: Colors.red.shade900,
          duration: const Duration(seconds: 4),
        ));
      }
    } finally {
      if (mounted) {
        _spinController
          ..stop()
          ..reset();
        setState(() => _syncing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = context.watch<StatusProvider>();
    final c      = context.colors;
    final hasPush     = status.toPush.isNotEmpty;
    final hasPull     = status.toPull.isNotEmpty;
    final hasConflict = status.conflicts.isNotEmpty;

    final String label;
    final IconData icon;
    final Color? accentColor;
    final List<String> syncArgs;

    if (_syncing) {
      label = 'Syncing...'; icon = Icons.sync;
      accentColor = null; syncArgs = [];
    } else if (hasConflict) {
      label = 'Conflicts'; icon = Icons.warning_amber_rounded;
      accentColor = AppColors.warning; syncArgs = [];
    } else if (hasPush && hasPull) {
      label = 'Sync'; icon = Icons.sync;
      accentColor = AppColors.accent; syncArgs = ['push', 'pull'];
    } else if (hasPush) {
      label = 'Push ${status.toPush.length}'; icon = Icons.upload_outlined;
      accentColor = AppColors.accent; syncArgs = ['push'];
    } else if (hasPull) {
      label = 'Pull ${status.toPull.length}'; icon = Icons.download_outlined;
      accentColor = AppColors.accent; syncArgs = ['pull'];
    } else {
      label = 'Up to date'; icon = Icons.check;
      accentColor = AppColors.successLight; syncArgs = [];
    }

    final disabled = !widget.enabled || _syncing || syncArgs.isEmpty;

    return InkWell(
      onTap: disabled ? null : () => _sync(syncArgs),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: disabled ? c.card.withAlpha(100) : c.card,
          border: Border.all(color: c.border),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            RotationTransition(
              turns: _spinController,
              child: Icon(icon, size: 15,
                  color: disabled ? c.fgGhost : (accentColor ?? c.fg)),
            ),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w500,
                  color: disabled ? c.fgGhost : (accentColor ?? c.fg),
                )),
          ],
        ),
      ),
    );
  }
}

// ─── TopBar Button ────────────────────────────────────────────────────────────

class _TopBarButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _TopBarButton({
    required this.icon, required this.label, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: c.fgMuted),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w500, color: c.fg,
                )),
          ],
        ),
      ),
    );
  }
}

// ─── TopBar Action Button ─────────────────────────────────────────────────────

class _TopBarActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _TopBarActionButton({
    required this.icon, required this.label, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c        = context.colors;
    final disabled = onTap == null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: disabled ? c.card.withAlpha(100) : c.card,
          border: Border.all(color: c.border),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15,
                color: disabled ? c.fgGhost : c.fg),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w500,
                  color: disabled ? c.fgGhost : c.fg,
                )),
          ],
        ),
      ),
    );
  }
}

void _showAbout(BuildContext context) {
  final c = context.colors;
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: c.panel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: c.border),
      ),
      title: const Row(
        children: [
           Icon(Icons.cloud_outlined, size: 20, color: AppColors.accent),
           SizedBox(width: 10),
            Text(
            'GDrive Desktop',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'A developer-oriented desktop client for Google Drive, built with Flutter.',
            style: TextStyle(fontSize: 13, color: c.fgMuted),
          ),
          const SizedBox(height: 16),
          Divider(color: c.divider),
          const SizedBox(height: 12),
          _AboutRow(label: 'Author', value: 'haruchanz64'),
          const SizedBox(height: 6),
          _AboutRow(label: 'Version', value: '1.0.0'),
          const SizedBox(height: 6),
          _AboutRow(label: 'Platform', value: 'Windows'),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => launchUrl(
              Uri.parse('https://github.com/haruchanz64/gdrive_desktop'),
              mode: LaunchMode.externalApplication,
            ),
            icon: const Icon(Icons.open_in_new, size: 14),
            label: const Text('View on GitHub'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(38),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    )
  );
}

class _AboutRow extends StatelessWidget {
  final String label;
  final String value;

  const _AboutRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: TextStyle(fontSize: 12, color: c.fgSubtle),
          ),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}