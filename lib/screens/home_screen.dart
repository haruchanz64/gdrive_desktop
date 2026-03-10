import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/folder_provider.dart';
import '../providers/status_provider.dart';
import '../widgets/sidebar.dart';
import '../widgets/top_bar.dart';
import 'auth_screen.dart';
import 'status_screen.dart';
import 'log_screen.dart';
import 'diff_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      final repo = context.read<FolderProvider>();
      await auth.initialize();
      await repo.load();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (auth.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Both "not installed" and "logged out" are handled by AuthScreen
    if (!auth.cliInstalled || auth.state == AuthState.loggedOut) {
      return const AuthScreen();
    }

    final bgColor =
        isDark ? const Color(0xFF1C2128) : const Color(0xFFF6F8FA);
    final panelBg =
        isDark ? const Color(0xFF22272E) : const Color(0xFFFFFFFF);
    final borderColor =
        isDark ? const Color(0xFF30363D) : const Color(0xFFD0D7DE);
    final tabLabelColor =
        isDark ? const Color(0xFFADBBC4) : const Color(0xFF57606A);
    final tabSelectedColor =
        isDark ? const Color(0xFFCDD9E5) : const Color(0xFF24292F);

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // ── Top Bar ──────────────────────────────────────────────
          const TopBar(),
          Divider(height: 1, color: borderColor),

          // ── Main Content ─────────────────────────────────────────
          Expanded(
            child: Row(
              children: [
                // ── Sidebar ───────────────────────────────────────
                const Sidebar(),
                VerticalDivider(width: 1, color: borderColor),

                // ── Right Panel ───────────────────────────────────
                Expanded(
                  child: Column(
                    children: [
                      // ── Tab Bar ─────────────────────────────────
                      Container(
                        color: panelBg,
                        child: Column(
                          children: [
                            TabBar(
                              controller: _tabController,
                              tabs: [
                                _buildTab(context, 'Changes',
                                    _changesCount(context)),
                                _buildTab(context, 'History', null),
                                _buildTab(context, 'Diff', null),
                              ],
                              labelStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                              unselectedLabelStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                              labelColor: tabSelectedColor,
                              unselectedLabelColor: tabLabelColor,
                              indicatorColor: const Color(0xFF0969DA),
                              indicatorWeight: 2,
                              indicatorSize: TabBarIndicatorSize.tab,
                              dividerColor: borderColor,
                            ),
                          ],
                        ),
                      ),

                      // ── Tab Views ────────────────────────────────
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: const [
                            StatusScreen(),
                            LogScreen(),
                            DiffScreen(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int? _changesCount(BuildContext context) {
    final files = context.watch<StatusProvider>().files;
    return files.isNotEmpty ? files.length : null;
  }

  Widget _buildTab(BuildContext context, String label, int? badge) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (badge != null) ...[
            const SizedBox(width: 6),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF373E47)
                    : const Color(0xFFEAECF0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$badge',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? const Color(0xFFCDD9E5)
                      : const Color(0xFF24292F),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}