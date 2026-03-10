/// Represents a locally initialised gdrive folder.
class Folder {
  /// Absolute path to the folder root on disk.
  final String path;

  /// The remote Google Drive folder name (from .gdrive/config.json).
  final String remoteName;

  /// The Google Drive folder ID.
  final String folderId;

  /// When the folder was last synced.
  final DateTime? lastSync;

  const Folder({
    required this.path,
    required this.remoteName,
    required this.folderId,
    this.lastSync,
  });

  /// The display name shown in the sidebar — uses the local folder name.
  String get displayName => path.split(RegExp(r'[\\/]')).last;

  Folder copyWith({
    String? path,
    String? remoteName,
    String? folderId,
    DateTime? lastSync,
  }) {
    return Folder(
      path: path ?? this.path,
      remoteName: remoteName ?? this.remoteName,
      folderId: folderId ?? this.folderId,
      lastSync: lastSync ?? this.lastSync,
    );
  }

  Map<String, dynamic> toJson() => {
        'path': path,
        'remoteName': remoteName,
        'folderId': folderId,
        'lastSync': lastSync?.toIso8601String(),
      };

  factory Folder.fromJson(Map<String, dynamic> json) => Folder(
        path: json['path'] as String,
        remoteName: json['remoteName'] as String,
        folderId: json['folderId'] as String,
        lastSync: json['lastSync'] != null
            ? DateTime.parse(json['lastSync'] as String)
            : null,
      );
}