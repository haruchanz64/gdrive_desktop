import 'dart:convert';
import 'dart:io';
import 'cli_result.dart';

/// Spawns the `gdrive` CLI as a subprocess and captures its output.
///
/// On all platforms we look for `gdrive` on PATH. If the user has installed
/// it via `npm install -g .` it will be available as a system command.
class CliRunner {
  /// The base command used to invoke the CLI.
  ///
  /// - Windows : `gdrive.cmd` (npm global bin wrapper)
  /// - macOS / Linux : `gdrive`
  static String get _executable =>
      Platform.isWindows ? 'gdrive.cmd' : 'gdrive';

  /// Run a gdrive command and return the result.
  ///
  /// [args]        : CLI arguments, e.g. `['status']` or `['push', '--force']`.
  /// [workingDir]  : The directory to run the command in (the folder root).
  /// [onStdout]    : Optional callback for streaming stdout lines (used for
  ///                 push/pull progress).
  static Future<CliResult> run(
    List<String> args, {
    String? workingDir,
    void Function(String line)? onStdout,
  }) async {
    final process = await Process.start(
      _executable,
      args,
      workingDirectory: workingDir,
      runInShell: true,
    );

    final stdoutBuffer = StringBuffer();
    final stderrBuffer = StringBuffer();

    // Stream stdout line by line so the UI can update in real time
    await Future.wait([
      process.stdout
          .transform(const SystemEncoding().decoder)
          .transform(const LineSplitter())
          .forEach((line) {
        stdoutBuffer.writeln(line);
        onStdout?.call(line);
      }),
      process.stderr
          .transform(const SystemEncoding().decoder)
          .transform(const LineSplitter())
          .forEach(stderrBuffer.writeln),
    ]);

    final exitCode = await process.exitCode;

    return CliResult(
      stdout: stdoutBuffer.toString().trim(),
      stderr: stderrBuffer.toString().trim(),
      exitCode: exitCode,
    );
  }

  /// Check whether the `gdrive` CLI is installed and reachable on PATH.
  static Future<bool> isInstalled() async {
    try {
      final result = await run(['--version']);
      return result.isSuccess;
    } catch (_) {
      return false;
    }
  }
}