import 'package:flutter/material.dart';
import 'package:gdrive_desktop/models/folder.dart';
import 'package:provider/provider.dart';

import '../providers/folder_provider.dart';
import '../providers/status_provider.dart';
import '../widgets/file_status_tile.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  Folder? _lastRepo;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final repo = context.read<FolderProvider>().active;
      _lastRepo = repo;
      context.read<StatusProvider>().refresh(repo);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final repo = context.read<FolderProvider>().active;
    if (repo != _lastRepo) {
      _lastRepo = repo;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<StatusProvider>().refresh(repo);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<FolderProvider>().active;
    final status = context.watch<StatusProvider>();

    if (repo == null) return const _NoRepoPlaceholder();

    return _ChangesTab(status: status);
  }
}

class _ChangesTab extends StatelessWidget {
  final StatusProvider status;

  const _ChangesTab({required this.status});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (status.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (status.error.isNotEmpty) {
      return Center(
        child: Text(
          status.error,
          style: const TextStyle(color: Colors.red, fontSize: 13),
        ),
      );
    }

    if (status.files.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 48,
              color: isDark
                  ? const Color(0xFF545D68)
                  : const Color(0xFFBFBFBF),
            ),
            const SizedBox(height: 12),
            Text(
              'No local changes',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? const Color(0xFF768390)
                    : const Color(0xFF57606A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Everything is in sync with Google Drive.',
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? const Color(0xFF545D68)
                    : const Color(0xFFBFBFBF),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: status.files.length,
      separatorBuilder: (_, __) =>
          Divider(height: 1, color: Theme.of(context).dividerColor),
      itemBuilder: (context, i) => FileStatusTile(file: status.files[i]),
    );
  }
}

class _NoRepoPlaceholder extends StatelessWidget {
  const _NoRepoPlaceholder();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.folder_open,
            size: 64,
            color: isDark
                ? const Color(0xFF545D68)
                : const Color(0xFFBFBFBF),
          ),
          const SizedBox(height: 16),
          Text(
            'No folder selected',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? const Color(0xFFCDD9E5)
                  : const Color(0xFF24292F),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add or clone a folder from the sidebar.',
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? const Color(0xFF768390)
                  : const Color(0xFF57606A),
            ),
          ),
        ],
      ),
    );
  }
}