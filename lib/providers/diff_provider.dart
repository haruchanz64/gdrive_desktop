import 'package:flutter/foundation.dart';
import '../core/cli_runner.dart';
import '../models/diff_entry.dart';
import '../models/folder.dart';

class DiffProvider extends ChangeNotifier {
  List<DiffEntry> _entries = [];
  bool _loading = false;
  String _error = '';

  List<DiffEntry> get entries => List.unmodifiable(_entries);
  bool get loading => _loading;
  String get error => _error;

  Future<void> refresh(Folder? repo) async {
    if (repo == null) return;
    _loading = true;
    _error = '';
    notifyListeners();

    final result = await CliRunner.run(['diff'], workingDir: repo.path);

    _loading = false;

    if (result.isSuccess) {
      _parseDiff(result.stdout);
    } else {
      _error = result.stderr;
    }

    notifyListeners();
  }

  void _parseDiff(String output) {
    _entries = [];
    for (final line in output.split('\n')) {
      final t = line.trim();
      if (t.isEmpty) continue;

      DiffState? state;
      if (t.startsWith('[local only]')) {
        state = DiffState.localOnly;
      } else if (t.startsWith('[remote only]'))  {
        state = DiffState.remoteOnly;
      }
      else if (t.startsWith('[local ahead]'))  {
        state = DiffState.localAhead;
      }
      else if (t.startsWith('[remote ahead]')) {
        state = DiffState.remoteAhead;
      }
      else if (t.startsWith('[conflict]'))     {
        state = DiffState.conflict;
      }

      if (state != null) {
        final path = t.split(']').last.trim();
        _entries.add(DiffEntry(relativePath: path, state: state));
      }
    }
  }
}