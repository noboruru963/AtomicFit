import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../texts/app_texts.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDark = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppTexts.settingsTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textLight)),
                    const SizedBox(height: 20),
                    _buildSection(
                      AppTexts.display,
                      [
                        _buildSettingsRow(
                          AppTexts.theme,
                          _isDark ? AppTexts.themeDark : AppTexts.themeLight,
                          onTap: () => setState(() => _isDark = !_isDark),
                        ),
                        const Divider(height: 1),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text('Theme preference saved locally.', style: TextStyle(fontSize: 11, color: AppTheme.mutedLight)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      AppTexts.personalization,
                      [
                        _buildSettingsRow(
                          AppTexts.personalizationComingSoon,
                          '',
                          enabled: false,
                        ),
                        const Divider(height: 1),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Text('Personalization settings are not in the MVP.', style: TextStyle(fontSize: 11, color: AppTheme.mutedLight)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      AppTexts.about,
                      [
                        _buildSettingsRow(AppTexts.aboutName, ''),
                        const Divider(height: 1),
                        _buildSettingsRow(AppTexts.aboutVersion, ''),
                        const Divider(height: 1),
                        _buildSettingsRow(AppTexts.aboutLine, ''),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textLight)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(color: AppTheme.cardLight, borderRadius: BorderRadius.circular(AppTheme.radiusCard), border: Border.all(color: AppTheme.lineLight)),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingsRow(String title, String value, {bool enabled = true, VoidCallback? onTap}) {
    return ListTile(
      title: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: enabled ? AppTheme.textLight : AppTheme.mutedLight)),
      subtitle: value.isNotEmpty ? Text(value, style: TextStyle(fontSize: 12, color: AppTheme.mutedLight)) : null,
      trailing: enabled ? const Icon(Icons.chevron_right, color: AppTheme.mutedLight) : null,
      onTap: onTap ?? (enabled ? () {} : null),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppTheme.primary, AppTheme.primaryDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: Row(
        children: [
          Container(width: 28, height: 28, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(14)), child: const Center(child: Text('AF', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)))),
          const SizedBox(width: 12),
          const Text('AtomFit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
          const Spacer(),
          IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        ],
      ),
    );
  }
}
