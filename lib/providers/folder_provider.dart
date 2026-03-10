import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:gdrive_desktop/models/folder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/cli_runner.dart';

class FolderProvider extends ChangeNotifier {
  List<Folder> _folders = [];
  Folder? _active;
  bool _loading = false;
  String _error = '';

  List<Folder> get folders => List.unmodifiable(_folders);
  Folder? get active => _active;
  bool get loading => _loading;
  String get error => _error;

  Future<void> load() async {
    _loading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList('folders') ?? [];
    _folders = raw
        .map((e) => Folder.fromJson(jsonDecode(e) as Map<String, dynamic>))
        .toList();
    _active = _folders.isNotEmpty ? _folders.first : null;
    _loading = false;
    notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'folders',
      _folders.map((r) => jsonEncode(r.toJson())).toList(),
    );
  }

  void setActive(Folder folder) {
    _active = folder;
    notifyListeners();
  }

  Future<void> _addFolder(String path) async {
    String folderId = '';
    String remoteName = path.split(RegExp(r'[\\/]')).last;

    try {
      final configFile = File('$path/.gdrive/config.json');
      if (await configFile.exists()) {
        final raw = await configFile.readAsString();
        final json = jsonDecode(raw) as Map<String, dynamic>;
        folderId = json['folderId'] as String? ??
            json['folder_id'] as String? ??
            json['id'] as String? ??
            '';
        remoteName = json['remoteName'] as String? ??
            json['remote_name'] as String? ??
            json['name'] as String? ??
            remoteName;
      }
    } catch (_) {}

    if (folderId.isEmpty) {
      try {
        final result = await CliRunner.run(
          ['status', '--json'],
          workingDir: path,
        );
        if (result.isSuccess && result.stdout.isNotEmpty) {
          final json = jsonDecode(result.stdout) as Map<String, dynamic>;
          folderId = json['folderId'] as String? ??
              json['folder_id'] as String? ??
              json['id'] as String? ??
              '';
          remoteName = json['remoteName'] as String? ??
              json['remote_name'] as String? ??
              json['name'] as String? ??
              remoteName;
        }
      } catch (_) {}
    }

    final folder = Folder(
      path: path,
      remoteName: remoteName,
      folderId: folderId,
    );

    _folders.add(folder);
    _active = folder;
    await _save();
    notifyListeners();
  }

  Future<bool> addExisting(String path) async {
    if (_folders.any((r) => r.path == path)) {
      _error = 'Folder already added.';
      notifyListeners();
      return false;
    }

    final configFile = File('$path/.gdrive/config.json');
    if (!await configFile.exists()) {
      _error = 'No gdrive folder found in that directory.\n'
          'Make sure it contains a .gdrive/config.json file.';
      notifyListeners();
      return false;
    }

    try {
      await _addFolder(path);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> init(String path, String remoteName) async {
    _loading = true;
    notifyListeners();

    final result = await CliRunner.run(
      ['init', if (remoteName.isNotEmpty) '--name', if (remoteName.isNotEmpty) remoteName],
      workingDir: path,
    );

    _loading = false;

    if (!result.isSuccess) {
      _error = result.stderr;
      notifyListeners();
      return false;
    }

    await _addFolder(path);
    return true;
  }

  Future<bool> clone(String urlOrId, String destPath) async {
    _loading = true;
    notifyListeners();

    // Extract folder ID from URL if needed
    final id = urlOrId.contains('folders/')
        ? urlOrId.split('folders/').last.split('?').first
        : urlOrId;

    final result = await CliRunner.run(
      ['clone', id, destPath],
    );

    _loading = false;

    if (!result.isSuccess) {
      _error = result.stderr;
      notifyListeners();
      return false;
    }

    await _addFolder(destPath);
    return true;
  }

  Future<void> removeFolder(Folder folder) async {
    _folders.remove(folder);
    if (_active == folder) {
      _active = _folders.isNotEmpty ? _folders.first : null;
    }
    await _save();
    notifyListeners();
  }
}