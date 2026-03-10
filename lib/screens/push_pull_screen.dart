import 'package:flutter/material.dart';
import 'package:gdrive_desktop/models/folder.dart';
import 'package:provider/provider.dart';

import '../providers/folder_provider.dart';
import '../providers/status_provider.dart';
import '../core/cli_runner.dart';
import '../widgets/progress_overlay.dart';

class PushPullScreen extends StatefulWidget {
  const PushPullScreen({super.key});

  @override
  State<PushPullScreen> createState() => _PushPullScreenState();
}

class _PushPullScreenState extends State<PushPullScreen> {
  bool _running = false;
  final List<String> _log = [];

  Future<void> _run(List<String> args) async {
    final repo = context.read<FolderProvider>().active;
    if (repo == null) return;

    setState(() {
      _running = true;
      _log.clear();
    });

    await CliRunner.run(
      args,
      workingDir: repo.path,
      onStdout: (line) => setState(() => _log.add(line)),
    );

    setState(() => _running = false);

    if (mounted) {
      context.read<StatusProvider>().refresh(repo as Folder?);
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = context.watch<StatusProvider>();

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  FilledButton.icon(
                    onPressed: _running ? null : () => _run(['push']),
                    icon: const Icon(Icons.upload),
                    label: Text('Push  (${status.toPush.length})'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: _running ? null : () => _run(['pull']),
                    icon: const Icon(Icons.download),
                    label: Text('Pull  (${status.toPull.length})'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (status.conflicts.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    border: Border.all(color: Colors.orange.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Conflicts',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                      ),
                      ...status.conflicts.map(
                        (f) => Text('  ${f.relativePath}',
                            style: const TextStyle(fontFamily: 'monospace')),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: ListView.builder(
                    itemCount: _log.length,
                    itemBuilder: (_, i) => Text(
                      _log[i],
                      style: const TextStyle(
                        color: Colors.greenAccent,
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_running) const ProgressOverlay(),
      ],
    );
  }
}