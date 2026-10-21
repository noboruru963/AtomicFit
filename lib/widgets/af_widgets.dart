import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Reusable widgets mirroring the prototype's CSS classes
/// (`.af-card`, `.af-btn-*`, `.af-badge`, `.af-input`, …).

class AfCard extends StatelessWidget {
  const AfCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderLeftColor,
    this.borderLeftWidth = 0,
    this.onTap,
  });

  final Widget child;
  final EdgeInsets padding;
  final Color? borderLeftColor;
  final double borderLeftWidth;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AfTokens t = context.af;
    final BorderRadius radius = BorderRadius.circular(t.radiusCard);
    final bool hasAccent = borderLeftColor != null && borderLeftWidth > 0;

    final Widget content = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: t.bgCard,
        borderRadius: radius,
        border: Border.all(color: t.borderLine),
        boxShadow: t.shadowCard,
      ),
      child: child,
    );

    final Widget body = hasAccent
        ? ClipRRect(
            borderRadius: radius,
            child: Stack(
              children: <Widget>[
                content,
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: borderLeftWidth,
                  child: ColoredBox(color: borderLeftColor!),
                ),
              ],
            ),
          )
        : content;

    return onTap == null ? body : _TapCard(onTap: onTap!, child: body);
  }
}

class _TapCard extends StatelessWidget {
  const _TapCard({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.af.radiusCard),
        child: child,
      ),
    );
  }
}

/// `.af-subtle` — a soft inset panel.
class AfSubtle extends StatelessWidget {
  const AfSubtle({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(10),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final AfTokens t = context.af;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: t.bgSubtle,
        borderRadius: BorderRadius.circular(t.radiusInput),
      ),
      child: child,
    );
  }
}

enum AfButtonSize { compact, medium, regular, large }

class AfButton extends StatelessWidget {
  const AfButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AfButtonVariant.primary,
    this.size = AfButtonSize.regular,
    this.icon,
    this.expand = false,
    this.fontSize,
  });

  final String label;
  final VoidCallback? onPressed;
  final AfButtonVariant variant;
  final AfButtonSize size;
  final Widget? icon;
  final bool expand;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    final AfTokens t = context.af;
    final bool disabled = onPressed == null;

    late final Color background;
    late final Color foreground;
    late final Color? border;

    switch (variant) {
      case AfButtonVariant.primary:
        background = t.accent;
        foreground = Colors.white;
        border = null;
        break;
      case AfButtonVariant.secondary:
        background = t.bgCard;
        foreground = t.textPrimary;
        border = t.borderLine;
        break;
      case AfButtonVariant.tint:
        background = t.accentTint;
        foreground = t.accentTintText;
        border = null;
        break;
      case AfButtonVariant.danger:
        background = t.dangerTint;
        foreground = t.danger;
        border = t.danger;
        break;
    }

    late final EdgeInsets padding;
    double text = fontSize ?? 14;
    switch (size) {
      case AfButtonSize.compact:
        padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
        text = fontSize ?? 12;
        break;
      case AfButtonSize.medium:
        padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
        text = fontSize ?? 12;
        break;
      case AfButtonSize.regular:
        padding = const EdgeInsets.symmetric(horizontal: 21.6, vertical: 11.5);
        break;
      case AfButtonSize.large:
        padding = const EdgeInsets.symmetric(horizontal: 21.6, vertical: 16);
        text = fontSize ?? 16;
        break;
    }

    final Widget button = Opacity(
      opacity: disabled ? 0.45 : 1,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(t.radiusPill),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(t.radiusPill),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(t.radiusPill),
              border:
                  border == null ? null : Border.all(color: border, width: 1.5),
            ),
            child: Row(
              mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (icon != null) ...<Widget>[
                  icon!,
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: foreground,
                      fontSize: text,
                      fontWeight: variant == AfButtonVariant.primary &&
                              size == AfButtonSize.large
                          ? FontWeight.w800
                          : FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

enum AfButtonVariant { primary, secondary, tint, danger }

/// `.af-workout-rep-set-btn` — the large grey workout action buttons.
class AfWorkoutButton extends StatelessWidget {
  const AfWorkoutButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final AfTokens t = context.af;
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: t.workoutBtnBg,
        borderRadius: BorderRadius.circular(t.radiusWorkout),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(t.radiusWorkout),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18.4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(t.radiusWorkout),
              border: Border.all(color: t.workoutBtnBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (icon != null) ...<Widget>[icon!, const SizedBox(width: 8)],
                Text(
                  label,
                  style: TextStyle(
                    color: t.workoutBtnText,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum AfBadgeTone { blue, green, amber }

class AfBadge extends StatelessWidget {
  const AfBadge({
    super.key,
    required this.label,
    this.tone = AfBadgeTone.blue,
    this.fontSize = 12,
    this.uppercase = false,
  });

  final String label;
  final AfBadgeTone tone;
  final double fontSize;
  final bool uppercase;

  @override
  Widget build(BuildContext context) {
    final AfTokens t = context.af;
    late final Color background;
    late final Color foreground;
    switch (tone) {
      case AfBadgeTone.blue:
        background = t.accentTint;
        foreground = t.accentTintText;
        break;
      case AfBadgeTone.green:
        background = t.successTint;
        foreground = t.success;
        break;
      case AfBadgeTone.amber:
        background = t.warningTint;
        foreground = t.warning;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.88, vertical: 3.52),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(t.radiusPill),
      ),
      child: Text(
        uppercase ? label.toUpperCase() : label,
        style: TextStyle(
          color: foreground,
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          height: 1.333,
        ),
      ),
    );
  }
}

/// Accent uppercase section heading (`Current Exercise`, `Logged Sets (n)`).
class AfSectionHead extends StatelessWidget {
  const AfSectionHead(this.text, {super.key, this.fontSize = 14});

  final String text;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final AfTokens t = context.af;
    return Text(
      text,
      style: TextStyle(
        color: t.accent,
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
        height: 1.5,
        letterSpacing: 0.6,
      ),
    );
  }
}

/// Accent eyebrow (`Welcome back`, `AtomFit Onboarding`).
class AfEyebrow extends StatelessWidget {
  const AfEyebrow(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text.toUpperCase(), style: AfText.eyebrow(context.af));
  }
}

/// The pill switch used in Settings.
class AfToggle extends StatelessWidget {
  const AfToggle({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final AfTokens t = context.af;
    return Semantics(
      toggled: value,
      button: true,
      child: GestureDetector(
        onTap: () => onChanged(!value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 44,
          height: 24,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: value ? t.accent : t.borderLine,
            borderRadius: BorderRadius.circular(t.radiusPill),
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 150),
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(t.radiusPill),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 3,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A settings row: title, description and a trailing control.
class AfSettingRow extends StatelessWidget {
  const AfSettingRow({
    super.key,
    required this.title,
    required this.description,
    required this.trailing,
  });

  final String title;
  final String description;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    final AfTokens t = context.af;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: t.borderLine)),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(
                    color: t.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    height: 1.333,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: t.textMuted,
                    fontSize: 11,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          trailing,
        ],
      ),
    );
  }
}

/// Inline error banner (`--danger-tint`).
class AfErrorBanner extends StatelessWidget {
  const AfErrorBanner({super.key, required this.message, this.padding});

  final String message;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    final AfTokens t = context.af;
    return Container(
      padding: padding ?? const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: t.dangerTint,
        borderRadius: BorderRadius.circular(t.radiusInput),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: t.danger,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          height: 1.333,
        ),
      ),
    );
  }
}

/// A muted statistic tile used on Home / Profile / Workout complete.
class AfStatTile extends StatelessWidget {
  const AfStatTile({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final AfTokens t = context.af;
    return AfSubtle(
      padding: const EdgeInsets.all(14),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: t.textMuted,
              fontSize: 12,
              height: 1.333,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: valueColor ?? t.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Progress bar used by the quiz and the rest timer.
class AfProgress extends StatelessWidget {
  const AfProgress({super.key, required this.value, this.height = 10});

  final double value; // 0..1
  final double height;

  @override
  Widget build(BuildContext context) {
    final AfTokens t = context.af;
    return ClipRRect(
      borderRadius: BorderRadius.circular(t.radiusPill),
      child: SizedBox(
        height: height,
        child: Stack(
          children: <Widget>[
            Container(color: t.bgSubtle),
            FractionallySizedBox(
              widthFactor: value.clamp(0.0, 1.0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                color: t.accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Themed text field matching `.af-input`.
class AfTextField extends StatelessWidget {
  const AfTextField({
    super.key,
    required this.controller,
    this.hint,
    this.keyboardType,
    this.textAlign,
    this.onChanged,
    this.style,
    this.emphasised = false,
    this.autofocus = false,
    this.obscureText = false,
  });

  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboardType;
  final TextAlign? textAlign;
  final ValueChanged<String>? onChanged;
  final TextStyle? style;
  final bool emphasised;
  final bool autofocus;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textAlign: textAlign ?? TextAlign.start,
      onChanged: onChanged,
      autofocus: autofocus,
      obscureText: obscureText,
      style: style ??
          (emphasised
              ? theme.textTheme.titleMedium?.copyWith(fontSize: 18)
              : theme.textTheme.bodyMedium),
      decoration: InputDecoration(
        hintText: hint,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}

/// Modal dialog matching `#app-modal-backdrop`.
class AfDialog {
  const AfDialog._();

  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    required Widget body,
    required List<Widget> actions,
    bool scrollable = false,
  }) {
    final AfTokens t = context.af;
    return showDialog<T>(
      context: context,
      barrierColor: const Color(0x99020613),
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 448),
            child: Container(
              decoration: BoxDecoration(
                color: t.bgCard,
                borderRadius: BorderRadius.circular(t.radiusCard),
                border: Border.all(color: t.borderLine),
                boxShadow: t.shadowCard,
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: const Padding(
                          padding: EdgeInsets.all(4),
                          child: Text(
                            '✕',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Flexible(
                    child:
                        scrollable ? SingleChildScrollView(child: body) : body,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      for (final Widget action in actions)
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: action,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// The in-app toast (`#app-toast`).
class AfToastView extends StatelessWidget {
  const AfToastView({
    super.key,
    required this.message,
    required this.kind,
  });

  final String message;
  final ToastTone kind;

  @override
  Widget build(BuildContext context) {
    final AfTokens t = context.af;
    late final Color dot;
    switch (kind) {
      case ToastTone.success:
        dot = const Color(0xFF22C55E);
        break;
      case ToastTone.info:
        dot = const Color(0xFF3B82F6);
        break;
      case ToastTone.danger:
        dot = const Color(0xFFEF4444);
        break;
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 96, right: 24),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const <BoxShadow>[
          BoxShadow(
              color: Color(0x33000000), blurRadius: 16, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: dot,
              borderRadius: BorderRadius.circular(t.radiusPill),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.333,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum ToastTone { success, info, danger }
