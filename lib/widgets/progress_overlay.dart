import 'package:flutter/material.dart';

/// A semi-transparent overlay shown while a CLI command is running.
class ProgressOverlay extends StatelessWidget {
  const ProgressOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black26,
      child: const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Running...'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}