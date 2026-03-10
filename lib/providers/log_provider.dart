import 'package:flutter/foundation.dart';
import '../core/cli_runner.dart';
import '../models/log_entry.dart';
import '../models/folder.dart';

class LogProvider extends ChangeNotifier {
  List<LogEntry> _entries = [];
  bool _loading = false;
  String _error = '';

  List<LogEntry> get entries => List.unmodifiable(_entries);
  bool get loading => _loading;
  String get error => _error;

  Future<void> refresh(Folder? repo) async {
    if (repo == null) return;
    _loading = true;
    _error = '';
    notifyListeners();

    final result = await CliRunner.run(['log'], workingDir: repo.path);

    _loading = false;

    if (!result.isSuccess || result.stdout.trim().isEmpty) {
      _error = result.stderr.isNotEmpty
          ? result.stderr
          : 'No revision history found.';
      notifyListeners();
      return;
    }

    _parse(result.stdout);
    notifyListeners();
  }

  void _parse(String output) {
    _entries = [];

    String? currentFile;

    for (final raw in output.split('\n')) {
      final line = raw.trimRight();

      if (line.trim().isEmpty) continue;

      // Indented line = revision entry for the current file
      // Format:  "  0B9fPvBt  3/10/2026, 11:54:56 AM  Aron Jake Radam  0.0 KB"
      if (line.startsWith('  ') && currentFile != null) {
        final parts = line.trim().split(RegExp(r'\s{2,}'));
        // parts[0] = revId
        // parts[1] = date+time  e.g. "3/10/2026, 11:54:56 AM"
        // parts[2] = name
        // parts[3] = size
        if (parts.length >= 3) {
          final revId = parts[0];
          final dateStr = parts[1]; // "3/10/2026, 11:54:56 AM"
          final name = parts[2];
          final size = parts.length >= 4 ? parts[3] : null;

          // Parse "3/10/2026, 11:54:56 AM"
          DateTime? modifiedTime;
          try {
            // Remove comma after date
            final cleaned = dateStr.replaceFirst(',', '');
            modifiedTime = _parseDate(cleaned);
          } catch (_) {}

          _entries.add(LogEntry(
            revisionId: revId,
            modifiedTime: modifiedTime ?? DateTime.now(),
            modifiedByName: name,
            modifiedByEmail: '',
            size: size,
            fileName: currentFile,
          ));
        }
      } else {
        // Non-indented line = file name (skip the header line)
        final trimmed = line.trim();
        if (!trimmed.startsWith('Revision History')) {
          currentFile = trimmed;
        }
      }
    }

    // Newest first
    _entries.sort((a, b) => b.modifiedTime.compareTo(a.modifiedTime));
  }

  DateTime _parseDate(String s) {
    // Input: "3/10/2026 11:54:56 AM"
    final parts = s.trim().split(' ');
    // parts[0] = "3/10/2026"
    // parts[1] = "11:54:56"
    // parts[2] = "AM" or "PM"
    final dateParts = parts[0].split('/');
    final timeParts = parts[1].split(':');
    final isPm = parts.length >= 3 && parts[2].toUpperCase() == 'PM';

    int month = int.parse(dateParts[0]);
    int day = int.parse(dateParts[1]);
    int year = int.parse(dateParts[2]);
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);
    int second = int.parse(timeParts[2]);

    if (isPm && hour != 12) hour += 12;
    if (!isPm && hour == 12) hour = 0;

    return DateTime(year, month, day, hour, minute, second);
  }
}