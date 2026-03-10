import 'package:flutter/material.dart';
import 'package:gdrive_desktop/providers/folder_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../providers/log_provider.dart';
import '../models/log_entry.dart';
import '../widgets/log_entry_tile.dart';
import '../widgets/log_entry_detail.dart';

class LogScreen extends StatefulWidget {
  const LogScreen({super.key});

  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  Object? _lastFolder;
  LogEntry? _selected;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final folder = context.read<FolderProvider>().active;
      _lastFolder = folder;
      context.read<LogProvider>().refresh(folder);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final folder = context.read<FolderProvider>().active;
    if (folder != _lastFolder) {
      _lastFolder = folder;
      _selected = null;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<LogProvider>().refresh(folder);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final log = context.watch<LogProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dividerColor =
        isDark ? const Color(0xFF30363D) : const Color(0xFFD0D7DE);

    if (log.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (log.error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline,
                size: 40,
                color: isDark
                    ? const Color(0xFF545D68)
                    : const Color(0xFFBFBFBF)),
            const SizedBox(height: 12),
            Text(
              log.error,
              style: const TextStyle(color: Colors.red, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (log.entries.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history,
                size: 48,
                color: isDark
                    ? const Color(0xFF545D68)
                    : const Color(0xFFBFBFBF)),
            const SizedBox(height: 12),
            Text(
              'No revision history found',
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
              'Push some changes to see history here.',
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

    // Group entries by date
    final grouped = <String, List<LogEntry>>{};
    for (final entry in log.entries) {
      final key =
          DateFormat('MMMM d, yyyy').format(entry.modifiedTime.toLocal());
      grouped.putIfAbsent(key, () => []).add(entry);
    }

    return Row(
      children: [
        // ── Entry List ─────────────────────────────────────────
        SizedBox(
          width: 280,
          child: ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: grouped.length,
            itemBuilder: (context, groupIndex) {
              final date = grouped.keys.elementAt(groupIndex);
              final entries = grouped[date]!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
                    color: isDark
                        ? const Color(0xFF1C2128)
                        : const Color(0xFFF6F8FA),
                    child: Text(
                      date,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: isDark
                            ? const Color(0xFF768390)
                            : const Color(0xFF57606A),
                      ),
                    ),
                  ),
                  ...entries.map((e) => LogEntryTile(
                        entry: e,
                        isSelected: _selected == e,
                        onTap: () => setState(() => _selected = e),
                      )),
                ],
              );
            },
          ),
        ),

        VerticalDivider(width: 1, color: dividerColor),

        // ── Entry Detail ───────────────────────────────────────
        Expanded(
          child: _selected == null
              ? Center(
                  child: Text(
                    'Select a revision to view details',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? const Color(0xFF545D68)
                          : const Color(0xFFBFBFBF),
                    ),
                  ),
                )
              : LogEntryDetail(entry: _selected!),
        ),
      ],
    );
  }
}