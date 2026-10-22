import 'package:flutter/material.dart';

import '../app/shell.dart';
import '../state/app_state.dart';
import '../strings.dart';
import '../theme/app_theme.dart';
import '../widgets/af_widgets.dart';

/// Port of `renderRegisterScreen()` (`index.html` lines 1694-1731).
///
/// The new prototype asks for credentials only — the username, date of birth,
/// gender, weight and height are collected on the personal-details screen
/// that follows.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirm = TextEditingController();

  bool _terms = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() {
    final AppState state = AfAppScope.of(context);
    final String email = _email.text.trim();
    final String password = _password.text;

    if (email.isEmpty || !email.contains('@')) {
      setState(() => _error = AfStrings.registerInvalidEmail);
      return;
    }
    if (password.isEmpty) {
      setState(() => _error = AfStrings.registerPasswordRequired);
      return;
    }
    if (password != _confirm.text) {
      setState(() => _error = AfStrings.registerPasswordMismatch);
      return;
    }
    if (!_terms) {
      setState(() => _error = AfStrings.registerTermsMissing);
      return;
    }

    final String? error = state.registerAccount(
      email: email,
      password: password,
    );
    if (error != null) {
      setState(() => _error = error);
      return;
    }

    setState(() => _error = null);
    Navigator.of(context).pushReplacementNamed(AfScreen.personalDetails);
  }

  @override
  Widget build(BuildContext context) {
    final AfTokens t = context.af;

    return AfScaffold(
      screenId: AfScreen.register,
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Center(child: AfEyebrow(AfStrings.registerEyebrow)),
          const SizedBox(height: 6),
          Center(
            child: Text(
              AfStrings.registerTitle,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: 4),
          Center(child: Text(AfStrings.tagline, style: AfText.muted(t))),
          const SizedBox(height: 18),
          AfCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (_error != null) ...<Widget>[
                  AfErrorBanner(message: _error!),
                  const SizedBox(height: 12),
                ],
                Text(
                  AfStrings.registerEmailLabel,
                  style: AfText.muted(t, weight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                AfTextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  hint: AfStrings.registerEmailPlaceholder,
                ),
                const SizedBox(height: 14),
                Text(
                  AfStrings.registerPassword,
                  style: AfText.muted(t, weight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                AfTextField(controller: _password, obscureText: true),
                const SizedBox(height: 14),
                Text(
                  AfStrings.registerConfirmPassword,
                  style: AfText.muted(t, weight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                AfTextField(controller: _confirm, obscureText: true),
                const SizedBox(height: 14),
                Row(
                  children: <Widget>[
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: Checkbox(
                        value: _terms,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                        activeColor: t.accent,
                        onChanged: (bool? value) =>
                            setState(() => _terms = value ?? false),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AfStrings.registerTerms,
                      style: TextStyle(
                        color: t.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                AfButton(
                  label: AfStrings.registerSubmit,
                  expand: true,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                AfStrings.registerHasAccount,
                style: AfText.muted(t),
              ),
              GestureDetector(
                onTap: () =>
                    Navigator.of(context).pushReplacementNamed(AfScreen.login),
                child: Text(
                  AfStrings.registerLogin,
                  style: TextStyle(
                    color: t.accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
