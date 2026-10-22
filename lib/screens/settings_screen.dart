import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../app/shell.dart';
import '../state/app_state.dart';
import '../strings.dart';
import '../theme/app_theme.dart';
import '../widgets/af_widgets.dart';

/// Port of `renderSettingsScreen()` (`index.html` lines 4071-4138).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AfTokens t = context.af;
    final AppState state = AfAppScope.of(context);
    final String method = state.activeWorkout.inputMethod;

    const List<({String id, String label})> modes =
        <({String id, String label})>[
      (id: 'manual', label: AfStrings.settingsManual),
      (id: 'sensor', label: AfStrings.settingsSensor),
      (id: 'voice', label: AfStrings.settingsVoice),
      (id: 'lockscreen', label: AfStrings.settingsLockscreen),
    ];

    return AfScaffold(
      screenId: AfScreen.settings,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // -------------------------------------------------- input channel
          AfCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            AfStrings.settingsInputChannel,
                            style: AfText.strong(t, size: 14),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            AfStrings.settingsInputChannelBody,
                            style: AfText.muted(t, size: 11),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    AfBadge(
                      label: AfStrings.fill(
                        AfStrings.settingsActiveChannel,
                        <String, Object?>{'method': method},
                      ),
                      fontSize: 10,
                      uppercase: true,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Column(
                  children: <Widget>[
                    for (int row = 0; row < 2; row++)
                      Padding(
                        padding: EdgeInsets.only(bottom: row == 1 ? 0 : 8),
                        child: Row(
                          children: <Widget>[
                            for (int column = 0;
                                column < 2;
                                column++) ...<Widget>[
                              if (column == 1) const SizedBox(width: 8),
                              Expanded(
                                child: AfButton(
                                  label: modes[row * 2 + column].label,
                                  variant: method == modes[row * 2 + column].id
                                      ? AfButtonVariant.primary
                                      : AfButtonVariant.secondary,
                                  size: AfButtonSize.medium,
                                  onPressed: () => state.switchInputMethod(
                                    modes[row * 2 + column].id,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // --------------------------------------------------------- theme
          AfCard(
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
          ),
          const SizedBox(height: 12),

          // ------------------------------------------------ device settings
          AfCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  AfStrings.settingsDevice,
                  style: AfText.strong(t, size: 14),
                ),
                const SizedBox(height: 8),
                AfSettingRow(
                  title: AfStrings.settingsBellTitle,
                  description: AfStrings.settingsBellDesc,
                  trailing: AfToggle(
                    value: state.settings.bellSound,
                    onChanged: (_) => state.toggleDeviceSetting('bellSound'),
                  ),
                ),
                AfSettingRow(
                  title: AfStrings.settingsNotifTitle,
                  description: AfStrings.settingsNotifDesc,
                  trailing: AfToggle(
                    value: state.settings.restNotifications,
                    onChanged: (_) =>
                        state.toggleDeviceSetting('restNotifications'),
                  ),
                ),
                AfSettingRow(
                  title: AfStrings.settingsSensorTitle,
                  description: AfStrings.settingsSensorDesc,
                  trailing: AfToggle(
                    value: state.settings.sensorAutoDetect,
                    onChanged: (_) =>
                        state.toggleDeviceSetting('sensorAutoDetect'),
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
                    onChanged: (_) =>
                        state.toggleDeviceSetting('lockscreenWidget'),
                  ),
                ),
                AfSettingRow(
                  title: AfStrings.settingsHapticTitle,
                  description: AfStrings.settingsHapticDesc,
                  trailing: AfToggle(
                    value: state.settings.hapticFeedback,
                    onChanged: (_) =>
                        state.toggleDeviceSetting('hapticFeedback'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ------------------------------------------------ adaptive engine
          AfCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
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
          ),
          const SizedBox(height: 12),
          AfCard(
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
          ),
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
}
