
import 'package:flutter/foundation.dart';
import '../core/cli_runner.dart';

enum AuthState { unknown, loggedIn, loggedOut }

class AuthProvider extends ChangeNotifier {
  AuthState _state = AuthState.unknown;
  String _displayName = '';
  String _email = '';
  String _storage = '';
  bool _cliInstalled = false;
  String _error = '';

  AuthState get state => _state;
  String get displayName => _displayName;
  String get email => _email;
  String get storage => _storage;
  String? get avatarUrl {
    if (_displayName.isEmpty) return null;
    final name = Uri.encodeComponent(_displayName);
    return 'https://ui-avatars.com/api/?name=$name&size=64&background=0969DA&color=fff&bold=true';
  }
  bool get cliInstalled => _cliInstalled;
  String get error => _error;
  bool get isLoading => _state == AuthState.unknown;

  /// Called once on app startup.
  Future<void> initialize() async {
    _cliInstalled = await CliRunner.isInstalled();
    if (!_cliInstalled) {
      _state = AuthState.loggedOut;
      notifyListeners();
      return;
    }
    await refresh();
  }

  /// Refresh the current user info by running `gdrive auth whoami`.
  Future<void> refresh() async {
    final result = await CliRunner.run(['auth', 'whoami']);
    if (result.isSuccess) {
      _parseWhoami(result.stdout);
      _state = AuthState.loggedIn;
      _error = '';
    } else {
      _state = AuthState.loggedOut;
      _error = result.stderr;
    }
    notifyListeners();
  }

  /// Open the browser login flow via `gdrive auth login`.
  Future<bool> login() async {
    final result = await CliRunner.run(['auth', 'login']);
    if (result.isSuccess) {
      await refresh();
      return true;
    }
    _error = result.stderr;
    notifyListeners();
    return false;
  }

  /// Log out via `gdrive auth logout`.
  Future<void> logout() async {
    await CliRunner.run(['auth', 'logout']);
    _state = AuthState.loggedOut;
    _displayName = '';
    _email = '';
    _storage = '';
    notifyListeners();
  }

  /// Switch accounts via `gdrive auth switch`.
  Future<bool> switchAccount() async {
    final result = await CliRunner.run(['auth', 'switch']);
    if (result.isSuccess) {
      await refresh();
      return true;
    }
    _error = result.stderr;
    notifyListeners();
    return false;
  }

  void _parseWhoami(String output) {
    for (final line in output.split('\n')) {
      if (line.contains('Name:')) {
        _displayName = line.split('Name:').last.trim();
      } else if (line.contains('Email:')) {
        _email = line.split('Email:').last.trim();
      } else if (line.contains('Storage:')) {
        _storage = line.split('Storage:').last.trim();
      }
    }
  }
}
