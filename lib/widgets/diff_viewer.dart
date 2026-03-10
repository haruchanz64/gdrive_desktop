import 'package:flutter/material.dart';
import '../models/diff_entry.dart';

class DiffViewer extends StatelessWidget {
  final DiffEntry entry;

  const DiffViewer({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _DiffIcon(state: entry.state),
      title: Text(
        entry.relativePath,
        style: const TextStyle(fontFamily: 'monospace'),
      ),
      subtitle: Text(_label(entry.state)),
      dense: true,
    );
  }

  String _label(DiffState state) {
    switch (state) {
      case DiffState.localOnly:    return 'Local only — not on Drive';
      case DiffState.remoteOnly:   return 'Remote only — not pulled yet';
      case DiffState.localAhead:   return 'Local is ahead of remote';
      case DiffState.remoteAhead:  return 'Remote is ahead of local';
      case DiffState.conflict:     return 'Conflict — both sides changed';
      case DiffState.identical:    return 'Identical';
    }
  }
}

class _DiffIcon extends StatelessWidget {
  final DiffState state;

  const _DiffIcon({required this.state});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (state) {
      case DiffState.localOnly:
        icon = Icons.computer;
        color = Colors.blue;
        break;
      case DiffState.remoteOnly:
        icon = Icons.cloud_outlined;
        color = Colors.blue;
        break;
      case DiffState.localAhead:
        icon = Icons.upload_outlined;
        color = Colors.green;
        break;
      case DiffState.remoteAhead:
        icon = Icons.download_outlined;
        color = Colors.orange;
        break;
      case DiffState.conflict:
        icon = Icons.warning_amber_outlined;
        color = Colors.red;
        break;
      case DiffState.identical:
        icon = Icons.check_circle_outline;
        color = Colors.grey;
        break;
    }

    return Icon(icon, color: color);
  }
}