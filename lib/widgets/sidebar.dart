import 'package:flutter/material.dart';
import 'package:gdrive_desktop/core/colors.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

import '../providers/auth_provider.dart';
import '../providers/folder_provider.dart';
import '../providers/status_provider.dart';
import '../models/folder.dart';

// ─── Sidebar ─────────────────────────────────────────────────────────────────

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final auth = context.watch<AuthProvider>();
    final folder = context.watch<FolderProvider>();

    return Container(
      width: 250,
      color: isDark ? const Color(0xFF22272E) : const Color(0xFFF6F8FA),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionHeader(
            label: 'Repositories',
            action: IconButton(
              icon: const Icon(Icons.add, size: 16),
              onPressed: () => _showAddRepoDialog(context),
              tooltip: 'Add folder',
              splashRadius: 16,
            ),
          ),
          Expanded(
            child: folder.folders.isEmpty
                ? _EmptyRepoList(onAdd: () => _showAddRepoDialog(context))
                : ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: folder.folders.length,
                    itemBuilder: (context, i) {
                      final r = folder.folders[i];
                      return _RepoTile(
                        repo: r,
                        isActive: r == folder.active,
                        onTap: () {
                          folder.setActive(r);
                          context.read<StatusProvider>().refresh(r);
                        },
                        onRemove: () => folder.removeFolder(r),
                      );
                    },
                  ),
          ),
          const Divider(height: 1),
          _UserFooter(auth: auth),
        ],
      ),
    );
  }

  void _showAddRepoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const _AddRepoDialog(),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  final Widget? action;

  const _SectionHeader({required this.label, this.action});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 4, 4),
      child: Row(
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
              color: isDark ? const Color(0xFF768390) : const Color(0xFF57606A),
            ),
          ),
          const Spacer(),
          if (action != null) action!,
        ],
      ),
    );
  }
}

// ─── Repo Tile ────────────────────────────────────────────────────────────────

class _RepoTile extends StatelessWidget {
  final Folder repo;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _RepoTile({
    required this.repo,
    required this.isActive,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const activeAccent = Color(0xFF0969DA);

    return InkWell(
      onTap: onTap,
      child: Container(
        color: isActive
            ? (isDark ? const Color(0xFF2D333B) : const Color(0xFFE8F0FE))
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Container(
              width: 3,
              height: 32,
              decoration: BoxDecoration(
                color: isActive ? activeAccent : Colors.transparent,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.folder,
              size: 18,
              color: isActive
                  ? activeAccent
                  : (isDark
                      ? const Color(0xFF768390)
                      : const Color(0xFF57606A)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    repo.displayName,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight:
                          isActive ? FontWeight.w600 : FontWeight.normal,
                      color: isDark
                          ? const Color(0xFFCDD9E5)
                          : const Color(0xFF24292F),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    repo.remoteName,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? const Color(0xFF768390)
                          : const Color(0xFF57606A),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: onRemove,
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.close,
                  size: 14,
                  color: isDark
                      ? const Color(0xFF545D68)
                      : const Color(0xFFBFBFBF),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty Repo List ──────────────────────────────────────────────────────────

class _EmptyRepoList extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyRepoList({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No repositories yet',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? const Color(0xFF768390) : const Color(0xFF57606A),
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: onAdd,
            child: const Text(
              'Add a folder →',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF0969DA),
                decoration: TextDecoration.underline,
                decorationColor: Color(0xFF0969DA),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── User Footer ─────────────────────────────────────────────────────────────

class _UserFooter extends StatelessWidget {
  final AuthProvider auth;

  const _UserFooter({required this.auth});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          // ── Avatar ─────────────────────────────────────────────
          CircleAvatar(
            radius: 14,
            backgroundColor: c.card,
            backgroundImage: auth.avatarUrl != null
                ? NetworkImage(auth.avatarUrl!)
                : null,
            onBackgroundImageError: auth.avatarUrl != null
                ? (_, __) {} // silently fall back to initials
                : null,
            child: auth.avatarUrl == null
                ? Text(
                    auth.displayName.isNotEmpty
                        ? auth.displayName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: c.fg,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  auth.displayName,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: c.fg,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (auth.email.isNotEmpty)
                  Text(
                    auth.email,
                    style: TextStyle(fontSize: 11, color: c.fgSubtle),
                    overflow: TextOverflow.ellipsis,
                  )
                else if (auth.storage.isNotEmpty)
                  Text(
                    auth.storage,
                    style: TextStyle(fontSize: 11, color: c.fgSubtle),
                  ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'switch') auth.switchAccount();
              if (v == 'logout') auth.logout();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'switch', child: Text('Switch account')),
              PopupMenuItem(value: 'logout', child: Text('Sign out')),
            ],
            icon: Icon(Icons.more_horiz, size: 16, color: c.fgSubtle),
          ),
        ],
      ),
    );
  }
}

// ─── Add Repo Dialog ──────────────────────────────────────────────────────────

enum _AddRepoMode { clone, existing, init }

class _AddRepoDialog extends StatefulWidget {
  const _AddRepoDialog();

  @override
  State<_AddRepoDialog> createState() => _AddRepoDialogState();
}

class _AddRepoDialogState extends State<_AddRepoDialog> {
  _AddRepoMode _mode = _AddRepoMode.clone;
  final _urlController = TextEditingController();
  final _nameController = TextEditingController();
  String? _selectedPath;
  bool _loading = false;
  String _error = '';

  @override
  void dispose() {
    _urlController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickFolder() async {
    final result = await FilePicker.platform.getDirectoryPath();
    if (result != null) setState(() => _selectedPath = result);
  }

  Future<void> _submit() async {
    setState(() {
      _error = '';
      _loading = true;
    });

    final repo = context.read<FolderProvider>();
    bool success = false;

    try {
      switch (_mode) {
        case _AddRepoMode.clone:
          final url = _urlController.text.trim();
          if (url.isEmpty) {
            setState(() {
              _error = 'Please enter a Google Drive folder URL or ID.';
              _loading = false;
            });
            return;
          }
          if (_selectedPath == null) {
            setState(() {
              _error = 'Please select a local folder to clone into.';
              _loading = false;
            });
            return;
          }
          success = await repo.clone(url, _selectedPath!);

        case _AddRepoMode.init:
          if (_selectedPath == null) {
            setState(() {
              _error = 'Please select a local folder to initialise.';
              _loading = false;
            });
            return;
          }
          success =
              await repo.init(_selectedPath!, _nameController.text.trim());

        case _AddRepoMode.existing:
          if (_selectedPath == null) {
            setState(() {
              _error = 'Please select a folder.';
              _loading = false;
            });
            return;
          }
          await repo.addExisting(_selectedPath!);
          success = true;
      }
    } catch (e) {
      setState(() => _error = e.toString());
    }

    if (!mounted) return;
    setState(() => _loading = false);

    if (success) {
      Navigator.pop(context);
    } else {
      setState(() => _error =
          repo.error.isNotEmpty ? repo.error : 'Something went wrong.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor =
        isDark ? const Color(0xFF444C56) : const Color(0xFFD0D7DE);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
              child: Row(
                children: [
                  const Text(
                    'Add a folder',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: () => Navigator.pop(context),
                    splashRadius: 16,
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: borderColor),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Mode Cards ───────────────────────────────
                  _ModeCard(
                    selected: _mode == _AddRepoMode.clone,
                    icon: Icons.cloud_download_outlined,
                    title: 'Clone from Google Drive',
                    description:
                        'Download an existing Google Drive folder and link it as a folder.',
                    onTap: () => setState(() => _mode = _AddRepoMode.clone),
                  ),
                  const SizedBox(height: 8),
                  _ModeCard(
                    selected: _mode == _AddRepoMode.existing,
                    icon: Icons.folder_open_outlined,
                    title: 'Add existing folder',
                    description:
                        'Add a local folder that is already linked to Google Drive.',
                    onTap: () => setState(() => _mode = _AddRepoMode.existing),
                  ),
                  const SizedBox(height: 8),
                  _ModeCard(
                    selected: _mode == _AddRepoMode.init,
                    icon: Icons.create_new_folder_outlined,
                    title: 'Create new folder',
                    description:
                        'Initialise a local folder and link it to a new Google Drive folder.',
                    onTap: () => setState(() => _mode = _AddRepoMode.init),
                  ),

                  const SizedBox(height: 20),
                  Divider(height: 1, color: borderColor),
                  const SizedBox(height: 20),

                  // ── Mode Fields ──────────────────────────────
                  if (_mode == _AddRepoMode.clone) ...[
                    const _FieldLabel('Google Drive folder URL or ID'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _urlController,
                      autofocus: true,
                      style: const TextStyle(fontSize: 13),
                      decoration: _inputDecoration(isDark,
                          hint: 'https://drive.google.com/drive/folders/...',
                          prefixIcon: Icons.link),
                    ),
                    const SizedBox(height: 16),
                    const _FieldLabel('Clone into folder'),
                    const SizedBox(height: 6),
                    _PathSelector(
                      path: _selectedPath,
                      isDark: isDark,
                      onSelect: _pickFolder,
                    ),
                  ] else if (_mode == _AddRepoMode.init) ...[
                    const _FieldLabel('Local folder'),
                    const SizedBox(height: 6),
                    _PathSelector(
                      path: _selectedPath,
                      isDark: isDark,
                      onSelect: _pickFolder,
                    ),
                    const SizedBox(height: 16),
                    const _FieldLabel('Remote folder name (optional)'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _nameController,
                      style: const TextStyle(fontSize: 13),
                      decoration: _inputDecoration(isDark,
                          hint: 'Defaults to local folder name',
                          prefixIcon: Icons.drive_file_rename_outline),
                    ),
                  ] else ...[
                    const _FieldLabel('Local folder folder'),
                    const SizedBox(height: 6),
                    _PathSelector(
                      path: _selectedPath,
                      isDark: isDark,
                      onSelect: _pickFolder,
                    ),
                  ],

                  // ── Error ────────────────────────────────────
                  if (_error.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.withAlpha(30),
                        border: Border.all(color: Colors.red.shade300),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              size: 16, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _error,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // ── Footer ──────────────────────────────────────────
            Divider(height: 1, color: borderColor),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: _loading ? null : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      textStyle: const TextStyle(fontSize: 13),
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: _loading ? null : _submit,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF1F883D),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      textStyle: const TextStyle(fontSize: 13),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(switch (_mode) {
                            _AddRepoMode.clone => 'Clone folder',
                            _AddRepoMode.init => 'Create folder',
                            _AddRepoMode.existing => 'Add folder',
                          }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(bool isDark,
      {String? hint, IconData? prefixIcon}) {
    final borderColor =
        isDark ? const Color(0xFF444C56) : const Color(0xFFD0D7DE);
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontSize: 13,
        color: isDark ? const Color(0xFF545D68) : const Color(0xFFBFBFBF),
      ),
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 16) : null,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: borderColor),
      ),
    );
  }
}

// ─── Mode Card ────────────────────────────────────────────────────────────────

class _ModeCard extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _ModeCard({
    required this.selected,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = selected
        ? const Color(0xFF0969DA)
        : (isDark ? const Color(0xFF444C56) : const Color(0xFFD0D7DE));
    final bgColor =
        selected ? const Color(0xFF0969DA).withAlpha(20) : Colors.transparent;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor, width: selected ? 1.5 : 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: selected
                  ? const Color(0xFF0969DA)
                  : (isDark
                      ? const Color(0xFF768390)
                      : const Color(0xFF57606A)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? const Color(0xFF0969DA)
                          : (isDark
                              ? const Color(0xFFCDD9E5)
                              : const Color(0xFF24292F)),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? const Color(0xFF768390)
                          : const Color(0xFF57606A),
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle,
                  size: 18, color: Color(0xFF0969DA)),
          ],
        ),
      ),
    );
  }
}

// ─── Field Label ─────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: isDark ? const Color(0xFFCDD9E5) : const Color(0xFF24292F),
      ),
    );
  }
}

// ─── Path Selector ────────────────────────────────────────────────────────────

class _PathSelector extends StatelessWidget {
  final String? path;
  final bool isDark;
  final VoidCallback onSelect;

  const _PathSelector({
    required this.path,
    required this.isDark,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor =
        isDark ? const Color(0xFF444C56) : const Color(0xFFD0D7DE);
    final bgColor = isDark ? const Color(0xFF2D333B) : const Color(0xFFF6F8FA);

    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: bgColor,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Icon(
              Icons.folder_outlined,
              size: 15,
              color: isDark ? const Color(0xFF768390) : const Color(0xFF57606A),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                path ?? 'Choose a folder...',
                style: TextStyle(
                  fontSize: 13,
                  color: path != null
                      ? (isDark
                          ? const Color(0xFFCDD9E5)
                          : const Color(0xFF24292F))
                      : (isDark
                          ? const Color(0xFF545D68)
                          : const Color(0xFFBFBFBF)),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Text(
              'Browse',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF0969DA),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
