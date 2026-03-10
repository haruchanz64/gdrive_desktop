import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/folder_provider.dart';
import '../providers/diff_provider.dart';
import '../widgets/diff_viewer.dart';

class DiffScreen extends StatefulWidget {
  const DiffScreen({super.key});

  @override
  State<DiffScreen> createState() => _DiffScreenState();
}

class _DiffScreenState extends State<DiffScreen> {
  Object? _lastRepo;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final folder = context.read<FolderProvider>().active;
      _lastRepo = folder;
      context.read<DiffProvider>().refresh(folder);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final folder = context.read<FolderProvider>().active;
    if (folder != _lastRepo) {
      _lastRepo = folder;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<DiffProvider>().refresh(folder);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final diff = context.watch<DiffProvider>();

    if (diff.loading) return const Center(child: CircularProgressIndicator());
    if (diff.error.isNotEmpty) {
      return Center(child: Text(diff.error, style: const TextStyle(color: Colors.red)));
    }
    if (diff.entries.isEmpty) {
      return const Center(child: Text('No differences found.'));
    }

    return ListView.separated(
      itemCount: diff.entries.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) => DiffViewer(entry: diff.entries[i]),
    );
  }
}