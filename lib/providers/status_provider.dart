import 'package:flutter/foundation.dart';
import '../core/cli_runner.dart';
import '../models/file_status.dart';
import '../models/folder.dart';

class StatusProvider extends ChangeNotifier {
  List<FileStatus> _files = [];
  bool _loading = false;
  String _error = '';
  String _lastSync = '';

  List<FileStatus> get files => List.unmodifiable(_files);
  bool get loading => _loading;
  String get error => _error;
  String get lastSync => _lastSync;

  List<FileStatus> get toPush => _files
      .where((f) => [
            FileState.localNew,
            FileState.localModified,
            FileState.localDeleted,
          ].contains(f.state))
      .toList();

  List<FileStatus> get toPull => _files
      .where((f) => [
            FileState.remoteNew,
            FileState.remoteModified,
            FileState.remoteDeleted,
          ].contains(f.state))
      .toList();

  List<FileStatus> get conflicts =>
      _files.where((f) => f.state == FileState.conflict).toList();

  Future<void> refresh(Folder? repo) async {
    if (repo == null) return;
    _loading = true;
    _error = '';
    notifyListeners();

    final result = await CliRunner.run(['status'], workingDir: repo.path);

    _loading = false;

    if (result.isSuccess) {
      _parseStatus(result.stdout);
    } else {
      _error = result.stderr;
    }

    notifyListeners();
  }

  void _parseStatus(String output) {
    _files = [];
    _lastSync = '';

    for (final line in output.split('\n')) {
      if (line.contains('Last sync:')) {
        _lastSync = line.split('Last sync:').last.trim();
        continue;
      }
      // Lines starting with 2 spaces followed by a status code
      if (line.length > 2 && line.startsWith('  ') && line.trim().isNotEmpty) {
        final trimmed = line.trim();
        final code = trimmed[0];
        if ('AMDURXCamduRxc'.contains(code)) {
          _files.add(FileStatus.fromStatusLine(line));
        }
      }
    }
  }
}