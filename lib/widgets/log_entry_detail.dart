import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/log_entry.dart';

class LogEntryDetail extends StatelessWidget {
  final LogEntry entry;

  const LogEntryDetail({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final formatted = DateFormat('MMMM d, yyyy  HH:mm')
        .format(entry.modifiedTime.toLocal());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Author ─────────────────────────────────────────────
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: isDark
                    ? const Color(0xFF373E47)
                    : const Color(0xFFE1E4E8),
                child: Text(
                  entry.modifiedByName.isNotEmpty
                      ? entry.modifiedByName[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? const Color(0xFFCDD9E5)
                        : const Color(0xFF24292F),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.modifiedByName.isNotEmpty
                        ? entry.modifiedByName
                        : 'Unknown',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? const Color(0xFFCDD9E5)
                          : const Color(0xFF24292F),
                    ),
                  ),
                  if (entry.modifiedByEmail.isNotEmpty)
                    Text(
                      entry.modifiedByEmail,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? const Color(0xFF768390)
                            : const Color(0xFF57606A),
                      ),
                    ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Details ────────────────────────────────────────────
          _DetailRow(
            icon: Icons.access_time,
            label: 'Synced',
            value: formatted,
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          _DetailRow(
            icon: Icons.tag,
            label: 'Revision',
            value: entry.revisionId,
            isDark: isDark,
            mono: true,
          ),
          if (entry.size != null) ...[
            const SizedBox(height: 10),
            _DetailRow(
              icon: Icons.data_usage,
              label: 'Size',
              value: entry.size!,
              isDark: isDark,
            ),
          ],
          // ── File name ──────────────────────────────────────────
          _DetailRow(
            icon: Icons.insert_drive_file_outlined,
            label: 'File',
            value: entry.fileName,
            isDark: isDark,
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDark;
  final bool mono;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDark,
    this.mono = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon,
            size: 15,
            color: isDark
                ? const Color(0xFF768390)
                : const Color(0xFF57606A)),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark
                ? const Color(0xFF768390)
                : const Color(0xFF57606A),
          ),
        ),
        Expanded(
          child: SelectableText(
            value,
            style: TextStyle(
              fontSize: 12,
              fontFamily: mono ? 'monospace' : null,
              color: isDark
                  ? const Color(0xFFCDD9E5)
                  : const Color(0xFF24292F),
            ),
          ),
        ),
      ],
    );
  }
}