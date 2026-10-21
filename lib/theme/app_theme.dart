import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Design tokens ported 1:1 from the web prototype's CSS custom properties
/// (`index.html` lines 14-63). Light values live in [AfTheme.light], dark
/// values in [AfTheme.dark]; widgets read them through [AfTokens.of].
@immutable
class AfTokens extends ThemeExtension<AfTokens> {
  const AfTokens({
    required this.bgPage,
    required this.bgCard,
    required this.bgSubtle,
    required this.textPrimary,
    required this.textMuted,
    required this.borderLine,
    required this.accent,
    required this.accentDark,
    required this.accentTint,
    required this.accentTintText,
    required this.danger,
    required this.dangerTint,
    required this.success,
    required this.successTint,
    required this.warning,
    required this.warningTint,
    required this.workoutBtnBg,
    required this.workoutBtnHover,
    required this.workoutBtnText,
    required this.workoutBtnBorder,
    required this.radiusCard,
    required this.radiusInput,
    required this.radiusPill,
    required this.radiusWorkout,
    required this.shadowCard,
  });

  final Color bgPage;
  final Color bgCard;
  final Color bgSubtle;
  final Color textPrimary;
  final Color textMuted;
  final Color borderLine;
  final Color accent;
  final Color accentDark;
  final Color accentTint;
  final Color accentTintText;
  final Color danger;
  final Color dangerTint;
  final Color success;
  final Color successTint;
  final Color warning;
  final Color warningTint;
  final Color workoutBtnBg;
  final Color workoutBtnHover;
  final Color workoutBtnText;
  final Color workoutBtnBorder;
  final double radiusCard;
  final double radiusInput;
  final double radiusPill;
  final double radiusWorkout;
  final List<BoxShadow> shadowCard;

  /// Reads the tokens of the current theme.
  static AfTokens of(BuildContext context) {
    final AfTokens? tokens = Theme.of(context).extension<AfTokens>();
    if (tokens != null) return tokens;
    return Theme.of(context).brightness == Brightness.dark
        ? AfTokens.dark
        : AfTokens.light;
  }

  static const AfTokens light = AfTokens(
    bgPage: Color(0xFFF4F7FE),
    bgCard: Color(0xFFFFFFFF),
    bgSubtle: Color(0xFFEDF2FC),
    textPrimary: Color(0xFF0F172A),
    textMuted: Color(0xFF64748B),
    borderLine: Color(0xFFE2E8F0),
    accent: Color(0xFF2563EB),
    accentDark: Color(0xFF1D4ED8),
    accentTint: Color(0xFFDBEAFE),
    accentTintText: Color(0xFF1E40AF),
    danger: Color(0xFFDC2626),
    dangerTint: Color(0xFFFEE2E2),
    success: Color(0xFF16A34A),
    successTint: Color(0xFFDCFCE7),
    warning: Color(0xFFD97706),
    warningTint: Color(0xFFFEF3C7),
    workoutBtnBg: Color(0xFFE5E7EB),
    workoutBtnHover: Color(0xFFD8DCE3),
    workoutBtnText: Color(0xFF111827),
    workoutBtnBorder: Color(0xFFD1D5DB),
    radiusCard: 18,
    radiusInput: 12,
    radiusPill: 999,
    radiusWorkout: 22,
    shadowCard: <BoxShadow>[
      BoxShadow(
        color: Color(0x0F0F172A),
        blurRadius: 20,
        offset: Offset(0, 4),
        spreadRadius: -2,
      ),
      BoxShadow(
        color: Color(0x0A0F172A),
        blurRadius: 6,
        offset: Offset(0, 2),
        spreadRadius: -1,
      ),
    ],
  );

  static const AfTokens dark = AfTokens(
    bgPage: Color(0xFF0B1220),
    bgCard: Color(0xFF131C2E),
    bgSubtle: Color(0xFF1A263D),
    textPrimary: Color(0xFFE8EEFC),
    textMuted: Color(0xFF94A3B8),
    borderLine: Color(0xFF24304A),
    accent: Color(0xFF2563EB),
    accentDark: Color(0xFF3B82F6),
    accentTint: Color(0xFF1E3A8A),
    accentTintText: Color(0xFFBFDBFE),
    danger: Color(0xFFEF4444),
    dangerTint: Color(0xFF451A1A),
    success: Color(0xFF22C55E),
    successTint: Color(0xFF143523),
    warning: Color(0xFFF59E0B),
    warningTint: Color(0xFF3D2810),
    workoutBtnBg: Color(0xFF1E293B),
    workoutBtnHover: Color(0xFF283548),
    workoutBtnText: Color(0xFFF1F5F9),
    workoutBtnBorder: Color(0xFF334155),
    radiusCard: 18,
    radiusInput: 12,
    radiusPill: 999,
    radiusWorkout: 22,
    shadowCard: <BoxShadow>[
      BoxShadow(
        color: Color(0x59000000),
        blurRadius: 24,
        offset: Offset(0, 8),
        spreadRadius: -4,
      ),
    ],
  );

  @override
  AfTokens copyWith({
    Color? bgPage,
    Color? bgCard,
    Color? bgSubtle,
    Color? textPrimary,
    Color? textMuted,
    Color? borderLine,
    Color? accent,
    Color? accentDark,
    Color? accentTint,
    Color? accentTintText,
    Color? danger,
    Color? dangerTint,
    Color? success,
    Color? successTint,
    Color? warning,
    Color? warningTint,
    Color? workoutBtnBg,
    Color? workoutBtnHover,
    Color? workoutBtnText,
    Color? workoutBtnBorder,
    double? radiusCard,
    double? radiusInput,
    double? radiusPill,
    double? radiusWorkout,
    List<BoxShadow>? shadowCard,
  }) {
    return AfTokens(
      bgPage: bgPage ?? this.bgPage,
      bgCard: bgCard ?? this.bgCard,
      bgSubtle: bgSubtle ?? this.bgSubtle,
      textPrimary: textPrimary ?? this.textPrimary,
      textMuted: textMuted ?? this.textMuted,
      borderLine: borderLine ?? this.borderLine,
      accent: accent ?? this.accent,
      accentDark: accentDark ?? this.accentDark,
      accentTint: accentTint ?? this.accentTint,
      accentTintText: accentTintText ?? this.accentTintText,
      danger: danger ?? this.danger,
      dangerTint: dangerTint ?? this.dangerTint,
      success: success ?? this.success,
      successTint: successTint ?? this.successTint,
      warning: warning ?? this.warning,
      warningTint: warningTint ?? this.warningTint,
      workoutBtnBg: workoutBtnBg ?? this.workoutBtnBg,
      workoutBtnHover: workoutBtnHover ?? this.workoutBtnHover,
      workoutBtnText: workoutBtnText ?? this.workoutBtnText,
      workoutBtnBorder: workoutBtnBorder ?? this.workoutBtnBorder,
      radiusCard: radiusCard ?? this.radiusCard,
      radiusInput: radiusInput ?? this.radiusInput,
      radiusPill: radiusPill ?? this.radiusPill,
      radiusWorkout: radiusWorkout ?? this.radiusWorkout,
      shadowCard: shadowCard ?? this.shadowCard,
    );
  }

  @override
  AfTokens lerp(AfTokens? other, double t) {
    if (other == null) return this;
    return AfTokens(
      bgPage: Color.lerp(bgPage, other.bgPage, t)!,
      bgCard: Color.lerp(bgCard, other.bgCard, t)!,
      bgSubtle: Color.lerp(bgSubtle, other.bgSubtle, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      borderLine: Color.lerp(borderLine, other.borderLine, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentDark: Color.lerp(accentDark, other.accentDark, t)!,
      accentTint: Color.lerp(accentTint, other.accentTint, t)!,
      accentTintText: Color.lerp(accentTintText, other.accentTintText, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerTint: Color.lerp(dangerTint, other.dangerTint, t)!,
      success: Color.lerp(success, other.success, t)!,
      successTint: Color.lerp(successTint, other.successTint, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningTint: Color.lerp(warningTint, other.warningTint, t)!,
      workoutBtnBg: Color.lerp(workoutBtnBg, other.workoutBtnBg, t)!,
      workoutBtnHover: Color.lerp(workoutBtnHover, other.workoutBtnHover, t)!,
      workoutBtnText: Color.lerp(workoutBtnText, other.workoutBtnText, t)!,
      workoutBtnBorder:
          Color.lerp(workoutBtnBorder, other.workoutBtnBorder, t)!,
      radiusCard: lerpDouble(radiusCard, other.radiusCard, t)!,
      radiusInput: lerpDouble(radiusInput, other.radiusInput, t)!,
      radiusPill: lerpDouble(radiusPill, other.radiusPill, t)!,
      radiusWorkout: lerpDouble(radiusWorkout, other.radiusWorkout, t)!,
      shadowCard: shadowCard,
    );
  }
}

extension AfTokensX on BuildContext {
  AfTokens get af => AfTokens.of(this);
}

class AfTokensXHelper {
  const AfTokensXHelper._();
}

/// App theme + typography ported from the web prototype.
class AfTheme {
  const AfTheme._();

  static const String fontFamily = 'Inter';

  static ThemeData get light => _build(AfTokens.light, Brightness.light);
  static ThemeData get dark => _build(AfTokens.dark, Brightness.dark);

  static ThemeData _build(AfTokens tokens, Brightness brightness) {
    final TextTheme text = _textTheme(tokens);
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: tokens.bgPage,
      canvasColor: tokens.bgPage,
      dividerColor: tokens.borderLine,
      splashFactory: InkSparkle.splashFactory,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: tokens.accent,
        onPrimary: Colors.white,
        primaryContainer: tokens.accentTint,
        onPrimaryContainer: tokens.accentTintText,
        secondary: tokens.accentDark,
        onSecondary: Colors.white,
        error: tokens.danger,
        onError: Colors.white,
        errorContainer: tokens.dangerTint,
        onErrorContainer: tokens.danger,
        surface: tokens.bgCard,
        onSurface: tokens.textPrimary,
        surfaceContainerHighest: tokens.bgSubtle,
        outline: tokens.borderLine,
        outlineVariant: tokens.borderLine,
      ),
      textTheme: text,
      extensions: <ThemeExtension<dynamic>>[tokens],
      appBarTheme: AppBarTheme(
        backgroundColor: tokens.bgCard,
        foregroundColor: tokens.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: text.titleLarge,
      ),
      iconTheme: IconThemeData(color: tokens.textPrimary, size: 20),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tokens.bgCard,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14.4,
          vertical: 10.4,
        ),
        hintStyle: text.bodyMedium?.copyWith(color: tokens.textMuted),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radiusInput),
          borderSide: BorderSide(color: tokens.borderLine, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radiusInput),
          borderSide: BorderSide(color: tokens.borderLine, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radiusInput),
          borderSide: BorderSide(color: tokens.accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radiusInput),
          borderSide: BorderSide(color: tokens.danger, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(tokens.radiusInput),
          borderSide: BorderSide(color: tokens.danger, width: 1.5),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: tokens.accent,
        selectionColor: tokens.accentTint,
        selectionHandleColor: tokens.accent,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: tokens.textPrimary,
        contentTextStyle: text.labelMedium?.copyWith(color: tokens.bgCard),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: tokens.bgCard,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radiusCard),
        ),
        titleTextStyle: text.titleMedium,
        contentTextStyle: text.bodyMedium,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: tokens.bgCard,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.white
              : Colors.white,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? tokens.accent
              : tokens.borderLine,
        ),
      ),
    );
  }

  /// Type scale taken from the prototype's Tailwind utilities.
  static TextTheme _textTheme(AfTokens t) {
    TextStyle style(
      double size,
      FontWeight weight, {
      double? height,
      double? tracking,
      Color? color,
    }) {
      return TextStyle(
        fontSize: size,
        fontWeight: weight,
        height: height,
        letterSpacing: tracking,
        color: color ?? t.textPrimary,
      );
    }

    return TextTheme(
      displayLarge: style(48, FontWeight.w800, height: 1.0, tracking: -1.2),
      headlineMedium: style(24, FontWeight.w800, height: 1.0, tracking: -0.6),
      headlineSmall: style(20, FontWeight.w800, height: 1.25, tracking: -0.5),
      titleLarge: style(18, FontWeight.w800, height: 1.75, tracking: -0.45),
      titleMedium: style(16, FontWeight.w700, height: 1.5),
      titleSmall: style(14, FontWeight.w700, height: 1.5),
      bodyLarge: style(16, FontWeight.w400, height: 1.5),
      bodyMedium: style(14, FontWeight.w400, height: 1.25),
      bodySmall: style(12, FontWeight.w400, height: 1.333),
      labelLarge: style(14, FontWeight.w600, height: 1.25),
      labelMedium: style(12, FontWeight.w600, height: 1.333),
      labelSmall: style(11, FontWeight.w500, height: 1.45),
    );
  }
}

/// Text styles that the prototype expresses through ad-hoc utility classes.
class AfText {
  const AfText._();

  /// `text-xs font-bold uppercase tracking-widest` — accent eyebrows.
  static TextStyle eyebrow(AfTokens t) => TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        height: 1.333,
        letterSpacing: 1.2,
        color: t.accent,
      );

  /// `text-sm font-extrabold uppercase tracking-wider` — accent section heads.
  static TextStyle sectionHead(AfTokens t) => TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        height: 1.5,
        letterSpacing: 0.6,
        color: t.accent,
      );

  static TextStyle muted(AfTokens t, {double size = 12, FontWeight? weight}) =>
      TextStyle(
        fontSize: size,
        fontWeight: weight ?? FontWeight.w400,
        height: 1.333,
        color: t.textMuted,
      );

  static TextStyle strong(AfTokens t, {double size = 14, FontWeight? weight}) =>
      TextStyle(
        fontSize: size,
        fontWeight: weight ?? FontWeight.w700,
        height: 1.5,
        color: t.textPrimary,
      );
}
