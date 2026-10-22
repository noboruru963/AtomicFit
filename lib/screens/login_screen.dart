import 'package:flutter/material.dart';

import '../app/shell.dart';
import '../state/app_state.dart';
import '../strings.dart';
import '../theme/app_theme.dart';
import '../widgets/af_widgets.dart';

/// Port of `renderLoginScreen()` (`index.html` lines 1456-1489).
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    final AppState state = AfAppScope.of(context);
    final String identifier = _email.text.trim();
    final String password = _password.text;

    if (identifier.isEmpty || password.isEmpty) {
      setState(() => _error = AfStrings.loginError);
      return;
    }

    final String? error = state.login(
      identifier: identifier,
      password: password,
    );
    if (error != null) {
      setState(() => _error = error);
      return;
    }

    setState(() => _error = null);
    state.showToast(
      AfStrings.fill(AfStrings.loginWelcomeToast, <String, Object?>{
        'name': state.user.username.isEmpty ? identifier : state.user.username,
      }),
    );
    Navigator.of(context).pushReplacementNamed(
      state.personalDetailsComplete ? AfScreen.home : AfScreen.personalDetails,
    );
  }

  Future<void> _forgotPassword() async {
    final AppState state = AfAppScope.of(context);
    await AfDialog.show<void>(
      context,
      title: AfStrings.forgotTitle,
      body: Text(
        AfStrings.forgotBody,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      actions: <Widget>[
        AfButton(
          label: AfStrings.cancel,
          variant: AfButtonVariant.secondary,
          size: AfButtonSize.compact,
          onPressed: () => Navigator.of(context).pop(),
        ),
        AfButton(
          label: AfStrings.forgotSend,
          size: AfButtonSize.compact,
          onPressed: () {
            Navigator.of(context).pop();
            state.showToast(AfStrings.forgotSentToast, kind: ToastKind.info);
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final AfTokens t = context.af;

    return AfScaffold(
      screenId: AfScreen.login,
      padding: const EdgeInsets.fromLTRB(8, 24, 8, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Center(
            child: Container(
              width: 64,
              height: 64,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: t.borderLine),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Image.asset('assets/images/logo.jpg', fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 8),
          const Center(child: AfEyebrow(AfStrings.loginEyebrow)),
          const SizedBox(height: 4),
          Center(
            child: Text(
              AfStrings.loginTitle,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              AfStrings.tagline,
              style: AfText.muted(t),
            ),
          ),
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
                  AfStrings.loginEmailLabel,
                  style: AfText.muted(t, weight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                AfTextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 14),
                Row(
                  children: <Widget>[
                    Text(
                      AfStrings.loginPasswordLabel,
                      style: AfText.muted(t, weight: FontWeight.w600),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: _forgotPassword,
                      child: Text(
                        AfStrings.loginForgotPassword,
                        style: TextStyle(
                          color: t.accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                AfTextField(
                  controller: _password,
                  obscureText: true,
                ),
                const SizedBox(height: 8),
                AfButton(
                  label: AfStrings.loginButton,
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
              Flexible(
                child: Text(
                  AfStrings.loginNoAccount,
                  style: AfText.muted(t),
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context)
                    .pushReplacementNamed(AfScreen.register),
                child: Text(
                  AfStrings.loginCreateAccount,
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
