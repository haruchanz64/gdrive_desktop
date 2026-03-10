/// A single revision entry from `gdrive log`.
class LogEntry {
  final String revisionId;
  final DateTime modifiedTime;
  final String modifiedByName;
  final String modifiedByEmail;
  final String? size;
  final String fileName;

  const LogEntry({
    required this.revisionId,
    required this.modifiedTime,
    required this.modifiedByName,
    required this.modifiedByEmail,
    required this.fileName,
    this.size,
  });
}