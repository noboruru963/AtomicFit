import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../texts/app_texts.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _username = 'Alex';
  String _email = 'alex@example.com';
  String _gender = 'Prefer not to say';
  String _day = '';
  String? _month;
  String _year = '';
  String _weight = '';
  String _height = '';
  bool _saved = false;

  final List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppTexts.profileTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textLight)),
              const SizedBox(height: 24),
              _buildField(AppTexts.profileUsername, _username, (v) => _username = v ?? ''),
              const SizedBox(height: 16),
              _buildField(AppTexts.profileEmail, _email, (v) => _email = v ?? '', keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              _buildGenderField(),
              const SizedBox(height: 16),
              _buildDobField(),
              const SizedBox(height: 16),
              _buildField(AppTexts.profileWeight, _weight, (v) => _weight = v ?? '', keyboardType: TextInputType.number, suffix: 'kg'),
              const SizedBox(height: 16),
              _buildField(AppTexts.profileHeight, _height, (v) => _height = v ?? '', keyboardType: TextInputType.number, suffix: 'cm'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() => _saved = true);
                    Future.delayed(const Duration(seconds: 2), () => setState(() => _saved = false));
                  },
                  child: const Text(AppTexts.updateProfile, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
              if (_saved)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(AppTexts.profileUpdated, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.success)),
                ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(AppTheme.radiusCard)),
                child: Text(
                  'Gender is stored/displayed only — it does not affect quiz rules, program adjustments, or analytics.',
                  style: TextStyle(fontSize: 11, color: AppTheme.mutedLight),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, String value, Function(String?) onSaved, {TextInputType? keyboardType, String? suffix}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textLight)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppTheme.cardLight,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusInput)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusInput), borderSide: BorderSide(color: AppTheme.lineLight)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusInput), borderSide: const BorderSide(color: AppTheme.primary)),
            suffixText: suffix,
          ),
          keyboardType: keyboardType,
          onSaved: onSaved,
        ),
      ],
    );
  }

  Widget _buildGenderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppTexts.profileGender, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textLight)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            filled: true,
            fillColor: AppTheme.cardLight,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusInput)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusInput), borderSide: BorderSide(color: AppTheme.lineLight)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusInput), borderSide: const BorderSide(color: AppTheme.primary)),
          ),
          value: _gender,
          items: [
            AppTexts.genderMale,
            AppTexts.genderFemale,
            AppTexts.genderPreferNotToSay,
          ].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
          onChanged: (v) => setState(() => _gender = v ?? 'Prefer not to say'),
        ),
      ],
    );
  }

  Widget _buildDobField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppTexts.profileDateOfBirth, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textLight)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Day', style: TextStyle(fontSize: 11, color: AppTheme.mutedLight)),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 48,
                    child: TextField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppTheme.cardLight,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusInput)),
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 2,
                      onChanged: (v) => _day = v,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Month', style: TextStyle(fontSize: 11, color: AppTheme.mutedLight)),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 48,
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppTheme.cardLight,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusInput)),
                      ),
                      value: _month,
                      items: _months.map((m) => DropdownMenuItem(value: m, child: Text(m, style: const TextStyle(fontSize: 14)))).toList(),
                      onChanged: (v) => setState(() => _month = v),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Year', style: TextStyle(fontSize: 11, color: AppTheme.mutedLight)),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 48,
                    child: TextField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppTheme.cardLight,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusInput)),
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      onChanged: (v) => _year = v,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
