import 'package:flutter/material.dart';
import '../models/file_status.dart';

class FileStatusTile extends StatelessWidget {
  final FileStatus file;

  const FileStatusTile({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _StateIcon(state: file.state),
      title: Text(
        file.relativePath,
        style: const TextStyle(fontFamily: 'monospace'),
      ),
      subtitle: Text(_label(file.state)),
      dense: true,
    );
  }

  String _label(FileState state) {
    switch (state) {
      case FileState.localNew:       return 'Added locally';
      case FileState.localModified:  return 'Modified locally';
      case FileState.localDeleted:   return 'Deleted locally';
      case FileState.remoteNew:      return 'New on remote';
      case FileState.remoteModified: return 'Modified on remote';
      case FileState.remoteDeleted:  return 'Deleted on remote';
      case FileState.conflict:       return 'Conflict';
      case FileState.upToDate:       return 'Up to date';
    }
  }
}

class _StateIcon extends StatelessWidget {
  final FileState state;

  const _StateIcon({required this.state});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (state) {
      case FileState.localNew:
        icon = Icons.add_circle_outline;
        color = Colors.green;
        break;
      case FileState.localModified:
        icon = Icons.edit_outlined;
        color = Colors.blue;
        break;
      case FileState.localDeleted:
        icon = Icons.delete_outline;
        color = Colors.red;
        break;
      case FileState.remoteNew:
        icon = Icons.cloud_download_outlined;
        color = Colors.green;
        break;
      case FileState.remoteModified:
        icon = Icons.cloud_sync_outlined;
        color = Colors.orange;
        break;
      case FileState.remoteDeleted:
        icon = Icons.cloud_off_outlined;
        color = Colors.red;
        break;
      case FileState.conflict:
        icon = Icons.warning_amber_outlined;
        color = Colors.orange;
        break;
      case FileState.upToDate:
        icon = Icons.check_circle_outline;
        color = Colors.grey;
        break;
    }

    return Icon(icon, color: color);
  }
}