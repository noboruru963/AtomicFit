import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../app/shell.dart';
import '../services/rest_alerts.dart';
import '../state/app_state.dart';
import '../strings.dart';
import '../theme/app_theme.dart';
import '../widgets/af_widgets.dart';

/// Settings hub (port of `renderSettingsScreen()`, `index.html` lines
/// 4071-4138, split into sections).
///
/// The hub lists the sections; nothing else is shown until the user opens one:
/// Appearance, Device, Preferences, About us. Log out stays on the hub so it
/// is one tap away from anywhere in settings.
///
/// "Reset demo data" only exists in debug builds (`kDebugMode`) and always asks
/// for confirmation — it is the fastest way back to a known state while testing
/// on a phone.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  /// The open section, or null while the hub is showing.
  String? _section;

  static const String _appearance = 'appearance';
  static const String _device = 'device';
  static const String _preferences = 'preferences';
  static const String _about = 'about';

  @override
  Widget build(BuildContext context) {
    final AfTokens t = context.af;
    final AppState state = AfAppScope.of(context);
    final String? section = _section;

    return AfScaffold(
      screenId: AfScreen.settings,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (section == null)
            _hub(context, state)
          else ...<Widget>[
            _sectionHeader(t, section),
            const SizedBox(height: 12),
            if (section == _appearance)
              _appearanceCard(context, state)
            else if (section == _device)
              _deviceCard(context, state)
            else if (section == _preferences)
              _preferencesCard(context, state)
            else
              _aboutCard(context),
          ],
          const SizedBox(height: 12),
          AfButton(
            label: AfStrings.settingsLogOut,
            variant: AfButtonVariant.danger,
            size: AfButtonSize.compact,
            expand: true,
            onPressed: () {
              state.logout();
              Navigator.of(context).pushReplacementNamed(AfScreen.login);
            },
          ),
          if (kDebugMode) ...<Widget>[
            const SizedBox(height: 12),
            AfButton(
              label: 'HTML reference (debug)',
              variant: AfButtonVariant.secondary,
              size: AfButtonSize.compact,
              expand: true,
              onPressed: () =>
                  Navigator.of(context).pushNamed('/reference-html'),
            ),
          ],
        ],
      ),
    );
  }

  // ------------------------------------------------------------------ hub

  Widget _hub(BuildContext context, AppState state) {
    final AfTokens t = context.af;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _SectionTile(
          title: AfStrings.settingsSectionAppearance,
          body: AfStrings.settingsSectionAppearanceBody,
          detail: state.isDarkMode
              ? AfStrings.settingsDarkActive
              : AfStrings.settingsLightActive,
          onTap: () => setState(() => _section = _appearance),
        ),
        const SizedBox(height: 10),
        _SectionTile(
          title: AfStrings.settingsSectionDevice,
          body: AfStrings.settingsSectionDeviceBody,
          onTap: () => setState(() => _section = _device),
        ),
        const SizedBox(height: 10),
        _SectionTile(
          title: AfStrings.settingsSectionPreferences,
          body: AfStrings.settingsSectionPreferencesBody,
          onTap: () => setState(() => _section = _preferences),
        ),
        const SizedBox(height: 10),
        _SectionTile(
          title: AfStrings.settingsSectionAbout,
          body: AfStrings.settingsSectionAboutBody,
          onTap: () => setState(() => _section = _about),
        ),
        const SizedBox(height: 12),
        Text(
          AfStrings.settingsAboutVersion,
          textAlign: TextAlign.center,
          style: AfText.muted(t, size: 11),
        ),
      ],
    );
  }

  Widget _sectionHeader(AfTokens t, String section) {
    final String title = switch (section) {
      _appearance => AfStrings.settingsSectionAppearance,
      _device => AfStrings.settingsSectionDevice,
      _preferences => AfStrings.settingsSectionPreferences,
      _ => AfStrings.settingsSectionAbout,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Align(
          alignment: Alignment.centerLeft,
          child: AfButton(
            label: '‹ ${AfStrings.settingsBack}',
            variant: AfButtonVariant.secondary,
            size: AfButtonSize.compact,
            onPressed: () => setState(() => _section = null),
          ),
        ),
        const SizedBox(height: 10),
        Text(title, style: AfText.strong(t, size: 18)),
      ],
    );
  }

  // ------------------------------------------------------------ appearance

  Widget _appearanceCard(BuildContext context, AppState state) {
    final AfTokens t = context.af;
    return AfCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      AfStrings.settingsTheme,
                      style: AfText.strong(t, size: 14),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AfStrings.settingsThemeBody,
                      style: AfText.muted(t, size: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AfBadge(
                label: state.isDarkMode
                    ? AfStrings.settingsDarkActive
                    : AfStrings.settingsLightActive,
                fontSize: 10,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: <Widget>[
              Expanded(
                child: AfButton(
                  label: AfStrings.settingsLightMode,
                  variant: !state.isDarkMode
                      ? AfButtonVariant.primary
                      : AfButtonVariant.secondary,
                  size: AfButtonSize.compact,
                  onPressed: () => state.setThemeExplicit(false),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: AfButton(
                  label: AfStrings.settingsDarkMode,
                  variant: state.isDarkMode
                      ? AfButtonVariant.primary
                      : AfButtonVariant.secondary,
                  size: AfButtonSize.compact,
                  onPressed: () => state.setThemeExplicit(true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------- device

  Widget _deviceCard(BuildContext context, AppState state) {
    return AfCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AfSettingRow(
            title: AfStrings.settingsNotifTitle,
            description: AfStrings.settingsNotifDesc,
            trailing: AfToggle(
              value: state.settings.restNotifications,
              onChanged: (_) => state.toggleDeviceSetting('restNotifications'),
            ),
          ),
          AfSettingRow(
            title: AfStrings.settingsSensorTitle,
            description: AfStrings.settingsSensorDesc,
            trailing: AfToggle(
              value: state.settings.sensorAutoDetect,
              onChanged: (_) => state.toggleDeviceSetting('sensorAutoDetect'),
            ),
          ),
          AfSettingRow(
            title: AfStrings.settingsVoiceTitle,
            description: AfStrings.settingsVoiceDesc,
            trailing: AfToggle(
              value: state.settings.voiceLogging,
              onChanged: (_) => state.toggleDeviceSetting('voiceLogging'),
            ),
          ),
          AfSettingRow(
            title: AfStrings.settingsLockscreenTitle,
            description: AfStrings.settingsLockscreenDesc,
            trailing: AfToggle(
              value: state.settings.lockscreenWidget,
              onChanged: (_) => state.toggleDeviceSetting('lockscreenWidget'),
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: AfButton(
              label: AfStrings.lockWidgetOpen,
              variant: AfButtonVariant.secondary,
              size: AfButtonSize.compact,
              onPressed: () =>
                  Navigator.of(context).pushNamed(AfScreen.lockScreenWidget),
            ),
          ),
          AfSettingRow(
            title: AfStrings.settingsHapticTitle,
            description: AfStrings.settingsHapticDesc,
            trailing: AfToggle(
              value: state.settings.hapticFeedback,
              onChanged: (_) => state.toggleDeviceSetting('hapticFeedback'),
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: AfButton(
              label: AfStrings.settingsHapticTest,
              variant: AfButtonVariant.secondary,
              size: AfButtonSize.compact,
              onPressed: () {
                unawaited(RestAlerts.instance.vibrate());
                state.showToast(
                  AfStrings.settingsHapticTestToast,
                  kind: ToastKind.info,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------- preferences

  Widget _preferencesCard(BuildContext context, AppState state) {
    final AfTokens t = context.af;
    return AfCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          AfSettingRow(
            title: AfStrings.settingsBellTitle,
            description: AfStrings.settingsBellDesc,
            trailing: AfToggle(
              value: state.settings.bellSound,
              onChanged: (_) => state.toggleDeviceSetting('bellSound'),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AfStrings.settingsAdaptive,
            style: AfText.strong(t, size: 14),
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(
                child: AfButton(
                  label: AfStrings.settingsTriggerQuiz,
                  variant: AfButtonVariant.tint,
                  size: AfButtonSize.compact,
                  onPressed: () {
                    state.retriggerQuizBanner();
                    Navigator.of(context).pushNamed(AfScreen.quizPrompt);
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AfButton(
                  label: AfStrings.settingsResetSeed,
                  variant: AfButtonVariant.secondary,
                  size: AfButtonSize.compact,
                  onPressed: state.resetDemoState,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------- about

  Widget _aboutCard(BuildContext context) {
    final AfTokens t = context.af;
    return AfCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            AfStrings.settingsAboutCredits,
            style: AfText.strong(t, size: 14),
          ),
          const SizedBox(height: 6),
          Text(
            AfStrings.settingsAboutVersion,
            style: AfText.muted(t, size: 12),
          ),
          const SizedBox(height: 10),
          Text(
            AfStrings.settingsAboutDevelopers,
            style: AfText.strong(t, size: 12),
          ),
          const SizedBox(height: 2),
          for (final String name in AfStrings.settingsAboutDeveloperNames)
            Text(
              name,
              style: AfText.muted(t, size: 12),
            ),
          const SizedBox(height: 10),
          Text.rich(
            TextSpan(
              children: <InlineSpan>[
                TextSpan(
                  text: '${AfStrings.settingsAboutExerciseData} ',
                  style: TextStyle(
                    color: t.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text: AfStrings.discoverRepDbLink,
                  style: TextStyle(
                    color: t.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One row in the settings hub: a whole card that opens its section.
class _SectionTile extends StatelessWidget {
  const _SectionTile({
    required this.title,
    required this.body,
    required this.onTap,
    this.detail,
  });

  final String title;
  final String body;
  final String? detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AfTokens t = context.af;
    return AfCard(
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        title,
                        style: AfText.strong(t, size: 15),
                      ),
                    ),
                    if (detail != null) ...<Widget>[
                      const SizedBox(width: 8),
                      AfBadge(label: detail!, fontSize: 10),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(body, style: AfText.muted(t, size: 11)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right, color: t.textMuted, size: 22),
        ],
      ),
    );
  }
}
