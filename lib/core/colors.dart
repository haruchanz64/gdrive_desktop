import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Brand ──────────────────────────────────────────────────────
  static const accent        = Color(0xFF0969DA);
  static const accentMuted   = Color(0x140969DA); // 20 alpha
  static const success       = Color(0xFF1F883D);
  static const successLight  = Color(0xFF2EA043);
  static const warning       = Colors.orange;
  static const danger        = Colors.red;
  static const dangerMuted   = Color(0x1FFF0000); // 30 alpha

  // ── Dark palette ───────────────────────────────────────────────
  static const darkBg         = Color(0xFF1C2128);
  static const darkSurface    = Color(0xFF22272E);
  static const darkPanel      = Color(0xFF2D333B);
  static const darkCard       = Color(0xFF373E47);
  static const darkBorder     = Color(0xFF444C56);
  static const darkDivider    = Color(0xFF30363D);
  static const darkFg         = Color(0xFFCDD9E5);
  static const darkFgMuted    = Color(0xFFADBBC4);
  static const darkFgSubtle   = Color(0xFF768390);
  static const darkFgGhost    = Color(0xFF545D68);
  static const darkSelection  = Color(0xFF2D333B);

  // ── Light palette ──────────────────────────────────────────────
  static const lightBg        = Color(0xFFF6F8FA);
  static const lightSurface   = Color(0xFFF6F8FA);
  static const lightPanel     = Color(0xFFFFFFFF);
  static const lightCard      = Color(0xFFE1E4E8);
  static const lightBorder    = Color(0xFFD0D7DE);
  static const lightDivider   = Color(0xFFD0D7DE);
  static const lightFg        = Color(0xFF24292F);
  static const lightFgMuted   = Color(0xFF57606A);
  static const lightFgSubtle  = Color(0xFF57606A);
  static const lightFgGhost   = Color(0xFFBFBFBF);
  static const lightSelection = Color(0xFFE8F0FE);

  // ── Diff / State ───────────────────────────────────────────────
  static const diffLocal      = Colors.blue;
  static const diffRemote     = Colors.blue;
  static const diffAhead      = Colors.green;
  static const diffBehind     = Colors.orange;
  static const diffConflict   = Colors.red;
  static const diffIdentical  = Colors.grey;
}

/// Convenience extension so you can write `context.colors.accent` etc.
extension AppColorsX on BuildContext {
  AppColorScheme get colors {
    final dark = Theme.of(this).brightness == Brightness.dark;
    return AppColorScheme(dark);
  }
}

class AppColorScheme {
  final bool _dark;
  const AppColorScheme(this._dark);

  // Surfaces
  Color get bg        => _dark ? AppColors.darkBg        : AppColors.lightBg;
  Color get surface   => _dark ? AppColors.darkSurface   : AppColors.lightSurface;
  Color get panel     => _dark ? AppColors.darkPanel     : AppColors.lightPanel;
  Color get card      => _dark ? AppColors.darkCard      : AppColors.lightCard;

  // Borders
  Color get border    => _dark ? AppColors.darkBorder    : AppColors.lightBorder;
  Color get divider   => _dark ? AppColors.darkDivider   : AppColors.lightDivider;

  // Text
  Color get fg        => _dark ? AppColors.darkFg        : AppColors.lightFg;
  Color get fgMuted   => _dark ? AppColors.darkFgMuted   : AppColors.lightFgMuted;
  Color get fgSubtle  => _dark ? AppColors.darkFgSubtle  : AppColors.lightFgSubtle;
  Color get fgGhost   => _dark ? AppColors.darkFgGhost   : AppColors.lightFgGhost;

  // Selection
  Color get selection => _dark ? AppColors.darkSelection : AppColors.lightSelection;

  // Brand (same in both modes)
  Color get accent      => AppColors.accent;
  Color get accentMuted => AppColors.accentMuted;
  Color get success     => AppColors.success;
  Color get warning     => AppColors.warning;
  Color get danger      => AppColors.danger;
  Color get dangerMuted => AppColors.dangerMuted;
}