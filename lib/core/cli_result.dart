/// Represents the result of running a gdrive CLI command.
class CliResult {
  /// The raw stdout output from the CLI process.
  final String stdout;

  /// The raw stderr output from the CLI process.
  final String stderr;

  /// The process exit code. 0 means success.
  final int exitCode;

  const CliResult({
    required this.stdout,
    required this.stderr,
    required this.exitCode,
  });

  /// Whether the command exited successfully.
  bool get isSuccess => exitCode == 0;

  /// Combined output for display purposes.
  String get output => stdout.isNotEmpty ? stdout : stderr;

  @override
  String toString() =>
      'CliResult(exitCode: $exitCode, stdout: $stdout, stderr: $stderr)';
}