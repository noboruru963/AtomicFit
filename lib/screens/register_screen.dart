import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../texts/app_texts.dart';
import '../services/local_storage_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _gender = 'Prefer not to say';

  // DOB fields
  final _dayController = TextEditingController();
  String? _month;
  final _yearController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;
  bool _isLoading = false;

  final List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _dayController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  // --- Validators ---

  String? _validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required';
    }
    if (value.trim().length < 3) {
      return 'Username must be at least 3 characters';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return AppTexts.errPasswordsDoNotMatch;
    }
    return null;
  }

  Future<void> _handleRegister() async {
    // 1. Run all field validations
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 2. Validate Terms agreement
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must accept the terms and conditions to register.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Format DOB string
    final dob = (_dayController.text.isNotEmpty && _month != null && _yearController.text.isNotEmpty)
        ? '${_dayController.text.trim()} $_month ${_yearController.text.trim()}'
        : '';

    // 3. Register user with LocalStorageService
    final error = await LocalStorageService.registerAccount(
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      gender: _gender,
      dateOfBirth: dob,
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful! Welcome to AtomicFit.'),
          backgroundColor: AppTheme.primary,
        ),
      );
      // Navigate to Home dashboard
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      // Show error message (e.g., account with this email already exists)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

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
                child: const Center(
                  child: Text(
                    'AF',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppTexts.appName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textLight,
                ),
              ),
              Text(
                AppTexts.tagline,
                style: TextStyle(fontSize: 14, color: AppTheme.mutedLight),
              ),
              const SizedBox(height: 24),
              Text(
                AppTexts.registerTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textLight,
                ),
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  children: [
                    _buildField(
                      label: AppTexts.usernameLabel,
                      icon: Icons.person_outline,
                      controller: _usernameController,
                      validator: _validateUsername,
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      label: AppTexts.emailLabel,
                      icon: Icons.email_outlined,
                      controller: _emailController,
                      validator: _validateEmail,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      label: AppTexts.passwordLabel,
                      icon: Icons.lock_outline,
                      controller: _passwordController,
                      validator: _validatePassword,
                      obscureText: _obscurePassword,
                      isPassword: true,
                      onToggleVisibility: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildField(
                      label: 'Confirm password',
                      icon: Icons.lock_outline,
                      controller: _confirmPasswordController,
                      validator: _validateConfirmPassword,
                      obscureText: _obscureConfirmPassword,
                      isPassword: true,
                      onToggleVisibility: () {
                        setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildDobField(),
                    const SizedBox(height: 16),
                    _buildGenderField(),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Checkbox(
                          value: _agreedToTerms,
                          activeColor: AppTheme.primary,
                          onChanged: (val) {
                            setState(() => _agreedToTerms = val ?? false);
                          },
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() => _agreedToTerms = !_agreedToTerms);
                            },
                            child: Text.rich(
                              TextSpan(
                                text: '${AppTexts.termsLabel} ',
                                style: const TextStyle(fontSize: 14, color: AppTheme.textLight),
                                children: [
                                  TextSpan(
                                    text: '(Required)',
                                    style: TextStyle(fontSize: 12, color: AppTheme.mutedLight),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleRegister,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                AppTexts.registerButton,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppTexts.haveAccount,
                          style: TextStyle(fontSize: 14, color: AppTheme.mutedLight),
                        ),
                        const SizedBox(width: 4),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            AppTexts.loginButton,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primary,
                            ),
                          ),
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

  Widget _buildField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required String? Function(String?) validator,
    bool obscureText = false,
    bool isPassword = false,
    VoidCallback? onToggleVisibility,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppTheme.textLight,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(color: AppTheme.textLight),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppTheme.mutedLight),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      obscureText ? Icons.visibility_off : Icons.visibility,
                      color: AppTheme.mutedLight,
                    ),
                    onPressed: onToggleVisibility,
                  )
                : null,
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusInput),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusInput),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDobField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppTexts.profileDateOfBirth,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppTheme.textLight,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Day
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Day', style: TextStyle(fontSize: 11, color: AppTheme.mutedLight)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _dayController,
                    keyboardType: TextInputType.number,
                    maxLength: 2,
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: 'DD',
                      filled: true,
                      fillColor: AppTheme.cardLight,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppTheme.cardLight,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
                    value: _month,
                    hint: const Text('Month', style: TextStyle(fontSize: 13, color: AppTheme.mutedLight)),
                    items: _months
                        .map((m) => DropdownMenuItem(
                              value: m,
                              child: Text(m, style: const TextStyle(fontSize: 13)),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _month = v),
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
                  TextFormField(
                    controller: _yearController,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: 'YYYY',
                      filled: true,
                      fillColor: AppTheme.cardLight,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
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
        Text(
          AppTexts.profileGender,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppTheme.textLight,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            filled: true,
            fillColor: AppTheme.cardLight,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
