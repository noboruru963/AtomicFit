import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../texts/app_texts.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  String _gender = 'Prefer not to say';
  
  // DOB fields
  String _day = '';
  String? _month;
  String _year = '';

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
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Center(child: Text('AF', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800))),
              ),
              const SizedBox(height: 16),
              Text(AppTexts.appName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.textLight)),
              Text(AppTexts.tagline, style: TextStyle(fontSize: 14, color: AppTheme.mutedLight)),
              const SizedBox(height: 24),
              Text(AppTexts.registerTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textLight)),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildField(AppTexts.usernameLabel, Icons.person_outline, (v) => _username = v ?? ''),
                    const SizedBox(height: 16),
                    _buildField(AppTexts.emailLabel, Icons.email_outlined, (v) => _email = v ?? '', keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 16),
                    _buildField(AppTexts.passwordLabel, Icons.lock_outline, (v) => _password = v ?? '', obscureText: true),
                    const SizedBox(height: 16),
                    _buildField('Confirm password', Icons.lock_outline, (v) => _confirmPassword = v ?? '', obscureText: true),
                    const SizedBox(height: 16),
                    _buildDobField(),
                    const SizedBox(height: 16),
                    _buildGenderField(),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Checkbox(value: _formKey.currentState?.validate() ?? false, onChanged: (_) {}),
                        const SizedBox(width: 8),
                        Expanded(child: Text.rich(TextSpan(
                          text: '${AppTexts.termsLabel} ',
                          style: const TextStyle(fontSize: 14),
                          children: [
                            TextSpan(text: '(Required)', style: TextStyle(fontSize: 12, color: AppTheme.mutedLight)),
                          ],
                        ))),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_password != _confirmPassword) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppTexts.errPasswordsDoNotMatch)));
                            return;
                          }
                          Navigator.pushReplacementNamed(context, '/home');
                        },
                        child: const Text(AppTexts.registerButton, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(AppTexts.haveAccount, style: TextStyle(fontSize: 14, color: AppTheme.mutedLight)),
                        const SizedBox(width: 4),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(AppTexts.loginButton, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.primary)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, IconData icon, Function(String?) onSaved, {bool obscureText = false, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textLight)),
        const SizedBox(height: 8),
        TextFormField(
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppTheme.mutedLight),
            filled: true,
            fillColor: AppTheme.cardLight,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusInput)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusInput), borderSide: BorderSide(color: AppTheme.lineLight)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusInput), borderSide: const BorderSide(color: AppTheme.primary)),
          ),
          obscureText: obscureText,
          keyboardType: keyboardType,
          onSaved: onSaved,
          validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
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
            // Day
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
            // Month
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
            // Year
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
}
