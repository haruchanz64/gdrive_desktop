/// The diff classification for a single file.
enum DiffState {
  identical,
  localOnly,
  remoteOnly,
  localAhead,
  remoteAhead,
  conflict,
}

/// A single file entry from `gdrive diff`.
class DiffEntry {
  final String relativePath;
  final DiffState state;
  final int? sizeDelta;

  const DiffEntry({
    required this.relativePath,
    required this.state,
    this.sizeDelta,
  });
}