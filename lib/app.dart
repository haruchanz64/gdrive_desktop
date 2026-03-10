import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/themes.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';

class GDriveDesktopApp extends StatelessWidget {
  const GDriveDesktopApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeProvider>().mode;

    return MaterialApp(
      title: 'GDrive Desktop',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode, 
      home: const HomeScreen(),
    );
  }
}