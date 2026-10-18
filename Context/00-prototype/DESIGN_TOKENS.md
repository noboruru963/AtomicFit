# DESIGN_TOKENS.md — AtomFit design tokens for Flutter

Source: the HTML high-fidelity prototype (`../03-design/AtomFit-High-Fidelity-Prototype.html`) and the Improved App Pages PDF. Layout reference is the PDF; token values come from the HTML. **Never hard-code a `Color(0x…)` inside a widget** — read from the theme (AGENTS.md rule F-26).

## 1. Color tokens
| Token | Light | Dark | Use |
|---|---|---|---|
| primary | `#2563EB` | `#3B82F6` | Buttons, active nav, links |
| primaryDark | `#1D4ED8` | `#2563EB` | Header gradient end, pressed |
| primaryLight | `#DBEAFE` | `#1E3A8A` | Selected option fill, table header |
| background | `#F4F7FE` | `#0B1220` | Scaffold |
| card (surface) | `#FFFFFF` | `#131C2E` | Cards, sheets, inputs |
| text (onSurface) | `#0F172A` | `#E8EEFC` | Body text |
| muted | `#64748B` | `#94A3B8` | Secondary text |
| line | `#E2E8F0` | `#24304A` | Borders, dividers |
| danger (error) | `#DC2626` | `#DC2626` | Destructive actions |
| onPrimary | `#FFFFFF` | `#FFFFFF` | Text on primary |

Header: linear gradient `primary → primaryDark` (135°), white text. Table header text in dark mode: `#BFDBFE`.
Check contrast (≥ 4.5:1) for muted text on cards in both themes before shipping a screen; adjust `muted` only with approval.

## 2. Typography
Font **Plus Jakarta Sans** (weights 400, 600, 800). **Bundle the font files** under `assets/fonts/` and declare them in `pubspec.yaml` (do not fetch fonts at runtime; the app must work offline). Fall back to the platform default if loading fails.
Suggested scale (from the prototype): screen title 19–28 sp / 800 · body 15 sp / 400 · label 12 sp / 600 muted · counter 64 sp / 800 tabular figures · auto-count live counter ≥ 48 sp.
Use `FontFeature.tabularFigures()` for timers and counters.

## 3. Shape, spacing, elevation
| Element | Value |
|---|---|
| Card radius | 18 dp |
| Button / input radius | 12–14 dp |
| Bottom sheet top radius | 24 dp |
| Pill buttons (header) | fully rounded |
| Screen padding | 18 dp |
| Card margin bottom | 12 dp |
| Card shadow | subtle (≈ 0 1 3, 10% black) |
| Min touch target | 48 × 48 dp |
| Max content width | 430 dp, centered on wider screens |

Primary button: full width, height ≈ 48–52 dp, 600 weight. Secondary: outlined with primary color. Destructive: outlined with danger color.

## 4. Brand
Name **AtomFit** · tagline **"Log it. Keep going."** · logo = **panda placeholder** (round blue gradient badge). Render through a single `AtomLogo` widget reading one asset path, so replacing the logo touches one place. The "AF" monogram in the Improved pages is not used.

## 5. Flutter starting point (`lib/app/theme/app_theme.dart`)
Treat this as a starting point to refine, not final code.

```dart
import 'package:flutter/material.dart';

@immutable
class AtomColors extends ThemeExtension<AtomColors> {
  const AtomColors({
    required this.primaryDark,
    required this.primaryLight,
    required this.muted,
    required this.line,
  });

  final Color primaryDark;
  final Color primaryLight;
  final Color muted;
  final Color line;

  static const light = AtomColors(
    primaryDark: Color(0xFF1D4ED8),
    primaryLight: Color(0xFFDBEAFE),
    muted: Color(0xFF64748B),
    line: Color(0xFFE2E8F0),
  );

  static const dark = AtomColors(
    primaryDark: Color(0xFF2563EB),
    primaryLight: Color(0xFF1E3A8A),
    muted: Color(0xFF94A3B8),
    line: Color(0xFF24304A),
  );

  @override
  AtomColors copyWith({
    Color? primaryDark,
    Color? primaryLight,
    Color? muted,
    Color? line,
  }) =>
      AtomColors(
        primaryDark: primaryDark ?? this.primaryDark,
        primaryLight: primaryLight ?? this.primaryLight,
        muted: muted ?? this.muted,
        line: line ?? this.line,
      );

  @override
  AtomColors lerp(ThemeExtension<AtomColors>? other, double t) {
    if (other is! AtomColors) return this;
    return AtomColors(
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      line: Color.lerp(line, other.line, t)!,
    );
  }
}

ThemeData buildAtomTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  final scheme = ColorScheme(
    brightness: brightness,
    primary: isDark ? const Color(0xFF3B82F6) : const Color(0xFF2563EB),
    onPrimary: Colors.white,
    secondary: isDark ? const Color(0xFF3B82F6) : const Color(0xFF2563EB),
    onSecondary: Colors.white,
    error: const Color(0xFFDC2626),
    onError: Colors.white,
    surface: isDark ? const Color(0xFF131C2E) : Colors.white,
    onSurface: isDark ? const Color(0xFFE8EEFC) : const Color(0xFF0F172A),
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor:
        isDark ? const Color(0xFF0B1220) : const Color(0xFFF4F7FE),
    fontFamily: 'PlusJakartaSans',
    extensions: [isDark ? AtomColors.dark : AtomColors.light],
  );
}
```
Access extras with `Theme.of(context).extension<AtomColors>()!`.
