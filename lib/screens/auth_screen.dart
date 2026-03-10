import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/colors.dart';
import '../providers/auth_provider.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.cliInstalled) {
      return const _CliNotInstalledScreen();
    }

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_outlined, size: 80, color: AppColors.accent),
              const SizedBox(height: 24),
              Text(
                'gdrive Desktop',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in with your Google account to continue.',
                textAlign: TextAlign.center,
                style: TextStyle(color: context.colors.fgMuted),
              ),
              const SizedBox(height: 32),
              if (auth.error.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    auth.error,
                    style: const TextStyle(color: AppColors.danger),
                    textAlign: TextAlign.center,
                  ),
                ),
              FilledButton.icon(
                onPressed: () => auth.login(),
                icon: const Icon(Icons.login, size: 16),
                label: const Text('Sign in with Google'),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── CLI Not Installed ───────────────────────────────────────────────────────

class _CliNotInstalledScreen extends StatefulWidget {
  const _CliNotInstalledScreen();

  @override
  State<_CliNotInstalledScreen> createState() => _CliNotInstalledScreenState();
}

class _CliNotInstalledScreenState extends State<_CliNotInstalledScreen> {
  bool _copied = false;
  bool _installing = false;
  String? _installError;
  bool _installSuccess = false;

  Future<void> _copy() async {
    await Clipboard.setData(
        const ClipboardData(text: 'npm install -g @haruchanz64/gdrive-cli'));
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open $url')),
        );
      }
    }
  }

  Future<void> _installCli() async {
    setState(() {
      _installing = true;
      _installError = null;
      _installSuccess = false;
    });

    try {
      final result = await Process.run(
        Platform.isWindows ? 'npm.cmd' : 'npm',
        ['install', '-g', '@haruchanz64/gdrive-cli'],
        runInShell: true,
      );

      if (!mounted) return;

      if (result.exitCode == 0) {
        setState(() {
          _installSuccess = true;
          _installing = false;
        });
        // Re-check CLI presence after successful install
        await context.read<AuthProvider>().initialize();
      } else {
        setState(() {
          _installError = result.stderr.toString().trim().isNotEmpty
              ? result.stderr.toString().trim()
              : 'Installation failed. Please try manually.';
          _installing = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _installError =
            'Could not run npm. Make sure Node.js is installed and try again.';
        _installing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: c.panel,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: c.border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ───────────────────────────────────────
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.terminal,
                        size: 22,
                        color: AppColors.warning,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'gdrive CLI not installed',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'A required dependency is missing.',
                            style: TextStyle(fontSize: 13, color: c.fgMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                Divider(color: c.divider),
                const SizedBox(height: 24),

                // ── Step 1 ───────────────────────────────────────
                _Step(
                  number: '1',
                  title: 'Install Node.js',
                  description:
                      'gdrive CLI requires Node.js. Download it from nodejs.org if you have not already.',
                  action: OutlinedButton.icon(
                    onPressed: () => _launchUrl('https://nodejs.org'),
                    icon: const Icon(Icons.open_in_new, size: 14),
                    label: const Text('Download Node.js'),
                  ),
                ),

                const SizedBox(height: 20),

                // ── Step 2 ───────────────────────────────────────
                _Step(
                  number: '2',
                  title: 'Install gdrive CLI',
                  description:
                      'Click "Get CLI" to install automatically, or run the command below manually:',
                  action: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Command box
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? Colors.black26 : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: c.border),
                        ),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 12),
                                child: SelectableText(
                                  'npm install -g @haruchanz64/gdrive-cli',
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 13,
                                    color: AppColors.accent,
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: _copy,
                              tooltip: _copied ? 'Copied!' : 'Copy',
                              icon: Icon(
                                _copied ? Icons.check : Icons.copy_outlined,
                                size: 16,
                                color: _copied ? AppColors.success : c.fgSubtle,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Get CLI button
                      FilledButton.icon(
                        onPressed: _installing ? null : _installCli,
                        icon: _installing
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(
                                _installSuccess
                                    ? Icons.check_circle_outline
                                    : Icons.download_outlined,
                                size: 14,
                              ),
                        label: Text(
                          _installing
                              ? 'Installing...'
                              : _installSuccess
                                  ? 'Installed!'
                                  : 'Get CLI',
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor:
                              _installSuccess ? AppColors.success : null,
                        ),
                      ),
                      // Error message
                      if (_installError != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.error_outline,
                                size: 14, color: AppColors.danger),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                _installError!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.danger,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // ── Step 3 ───────────────────────────────────────
                const _Step(
                  number: '3',
                  title: 'Retry',
                  description:
                      'Once installed, click Retry below. The app will detect the CLI automatically.',
                  action: null,
                ),

                const SizedBox(height: 28),
                Divider(color: c.divider),
                const SizedBox(height: 20),

                // ── Actions ──────────────────────────────────────
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _launchUrl(
                          'https://github.com/haruchanz64/gdrive_desktop'),
                      icon: const Icon(Icons.menu_book_outlined, size: 14),
                      label: const Text('Documentation'),
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: () =>
                          context.read<AuthProvider>().initialize(),
                      icon: const Icon(Icons.refresh, size: 14),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Step Widget ─────────────────────────────────────────────────────────────

class _Step extends StatelessWidget {
  final String number;
  final String title;
  final String description;
  final Widget? action;

  const _Step({
    required this.number,
    required this.title,
    required this.description,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.accent,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(fontSize: 12, color: c.fgMuted),
              ),
              if (action != null) ...[
                const SizedBox(height: 10),
                action!,
              ],
            ],
          ),
        ),
      ],
    );
  }
}