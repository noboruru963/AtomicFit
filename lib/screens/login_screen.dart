import 'package:flutter/material.dart';

import '../app/shell.dart';
import '../state/app_state.dart';
import '../strings.dart';
import '../theme/app_theme.dart';
import '../widgets/af_widgets.dart';

/// Port of `renderLoginScreen()` (`index.html` lines 1456-1489).
///
/// Local accounts only: `AppState.login` compares the salted hash and returns
/// an error string, which the screen shows under the fields. A successful
/// login replaces the route with Home, or with the personal-details step when
/// that account never finished it.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    final AppState state = AfAppScope.of(context);
    final String identifier = _email.text.trim();
    final String password = _password.text;

    if (identifier.isEmpty || password.isEmpty) {
      setState(() => _error = AfStrings.loginError);
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });
    final SignInOutcome outcome = await state.loginOnline(
      identifier: identifier,
      password: password,
    );
    if (!mounted) return;
    setState(() => _busy = false);

    // The account exists but its address is not confirmed yet.
    if (outcome.needsVerification) {
      Navigator.of(context).pushReplacementNamed(AfScreen.verifyEmail);
      return;
    }
    if (!outcome.isOk) {
      setState(() => _error = outcome.message ?? AfStrings.loginError);
      return;
    }

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
          onPressed: () async {
            final String email = _email.text.trim();
            Navigator.of(context).pop();
            if (!email.contains('@')) {
              state.showToast(
                'Type your email in the email box first',
                kind: ToastKind.danger,
              );
              return;
            }
            final String? error = await state.sendPasswordReset(email);
            state.showToast(
              error ?? AfStrings.forgotSentToast,
              kind: error == null ? ToastKind.info : ToastKind.danger,
            );
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
              child: Padding(
                padding: const EdgeInsets.all(7),
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.contain,
                ),
              ),
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
                  label: _busy ? 'Please wait...' : AfStrings.loginButton,
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
