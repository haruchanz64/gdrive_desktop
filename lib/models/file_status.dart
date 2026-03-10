/// The sync state of a single file, as reported by `gdrive status`.
enum FileState {
  upToDate,
  localNew,
  localModified,
  localDeleted,
  remoteNew,
  remoteModified,
  remoteDeleted,
  conflict,
}

/// Represents a single file entry in the status output.
class FileStatus {
  /// The relative path of the file within the folder.
  final String relativePath;

  /// The current sync state of the file.
  final FileState state;

  const FileStatus({
    required this.relativePath,
    required this.state,
  });

  /// Parse a single status output line.
  ///
  /// Expected format: `  A report.pdf` or `  M notes.txt`
  factory FileStatus.fromStatusLine(String line) {
    final trimmed = line.trim();
    if (trimmed.length < 3) {
      return FileStatus(relativePath: trimmed, state: FileState.upToDate);
    }

    final code = trimmed[0];
    final path = trimmed.substring(2).trim();

    return FileStatus(
      relativePath: path,
      state: _codeToState(code),
    );
  }

  static FileState _codeToState(String code) {
    switch (code) {
      case 'A':
        return FileState.localNew;
      case 'M':
        return FileState.localModified;
      case 'D':
        return FileState.localDeleted;
      case 'U':
        return FileState.remoteNew;
      case 'R':
        return FileState.remoteModified;
      case 'X':
        return FileState.remoteDeleted;
      case 'C':
        return FileState.conflict;
      default:
        return FileState.upToDate;
    }
  }
}