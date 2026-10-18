import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../texts/app_texts.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: const Center(
                    child: Text('AF', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                  ),
                ),
                const SizedBox(height: 16),
                Text(AppTexts.appName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.textLight)),
                const SizedBox(height: 8),
                Text(AppTexts.tagline, style: TextStyle(fontSize: 14, color: AppTheme.mutedLight)),
                const SizedBox(height: 32),
                Text(AppTexts.loginTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textLight)),
                const SizedBox(height: 24),
                _buildTextField(AppTexts.emailLabel, Icons.email_outlined),
                const SizedBox(height: 16),
                _buildTextField(AppTexts.passwordLabel, Icons.lock_outline, obscureText: true),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                    child: const Text(AppTexts.loginButton, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(AppTexts.noAccount, style: TextStyle(fontSize: 14, color: AppTheme.mutedLight)),
                    const SizedBox(width: 4),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/register'),
                      child: Text(AppTexts.registerButton, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.primary)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {},
                  child: Text(AppTexts.forgotPassword, style: TextStyle(fontSize: 14, color: AppTheme.mutedLight)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, IconData icon, {bool obscureText = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textLight)),
        const SizedBox(height: 8),
        TextField(
          obscureText: obscureText,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppTheme.mutedLight),
            filled: true,
            fillColor: AppTheme.cardLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusInput),
              borderSide: BorderSide(color: AppTheme.lineLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusInput),
              borderSide: BorderSide(color: AppTheme.lineLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusInput),
              borderSide: const BorderSide(color: AppTheme.primary),
            ),
          ),
        ),
      ],
    );
  }
}
