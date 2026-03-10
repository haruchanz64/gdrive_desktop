import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/log_entry.dart';

class LogEntryTile extends StatelessWidget {
  final LogEntry entry;
  final bool isSelected;
  final VoidCallback onTap;

  const LogEntryTile({
    super.key,
    required this.entry,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final time = DateFormat('HH:mm').format(entry.modifiedTime.toLocal());

    return InkWell(
      onTap: onTap,
      child: Container(
        color: isSelected
            ? (isDark ? const Color(0xFF2D333B) : const Color(0xFFE8F0FE))
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: isDark
                  ? const Color(0xFF373E47)
                  : const Color(0xFFE1E4E8),
              child: Text(
                entry.modifiedByName.isNotEmpty
                    ? entry.modifiedByName[0].toUpperCase()
                    : '?',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? const Color(0xFFCDD9E5)
                      : const Color(0xFF24292F),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.fileName,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? const Color(0xFFCDD9E5)
                          : const Color(0xFF24292F),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    entry.modifiedByName.isNotEmpty
                        ? entry.modifiedByName
                        : 'Unknown',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? const Color(0xFF768390)
                          : const Color(0xFF57606A),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Text(
              time,
              style: TextStyle(
                fontSize: 11,
                color: isDark
                    ? const Color(0xFF545D68)
                    : const Color(0xFFBFBFBF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
