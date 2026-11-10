import 'package:flutter/material.dart';

import '../app/shell.dart';
import '../state/app_state.dart';
import '../strings.dart';
import '../theme/app_theme.dart';
import '../widgets/af_widgets.dart';

/// Shown after a sign-up, or after a sign-in with an account whose e-mail
/// address is still unconfirmed.
///
/// The app stays closed until Firebase reports the address as verified: the
/// account is only opened by [AppState.confirmEmailVerified].
class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _busy = false;
  String? _error;

  Future<void> _check() async {
    if (_busy) return;
    final AppState state = AfAppScope.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    final VerificationCheck result = await state.confirmEmailVerified();
    if (!mounted) return;
    setState(() => _busy = false);

    if (result == VerificationCheck.verified) {
      Navigator.of(context).pushReplacementNamed(
        state.personalDetailsComplete
            ? AfScreen.home
            : AfScreen.personalDetails,
      );
      return;
    }
    setState(() {
      _error = result == VerificationCheck.notYet
          ? AfStrings.verifyNotYet
          : AfStrings.verifyFailed;
    });
  }

  Future<void> _resend() async {
    if (_busy) return;
    final AppState state = AfAppScope.of(context);
    setState(() {
      _busy = true;
      _error = null;
    });
    final String? error = await state.resendVerification();
    if (!mounted) return;
    setState(() => _busy = false);
    state.showToast(
      error ?? AfStrings.verifyResent,
      kind: error == null ? ToastKind.success : ToastKind.danger,
    );
  }

  void _backToLogin() {
    AfAppScope.of(context).cancelVerification();
    Navigator.of(context).pushReplacementNamed(AfScreen.login);
  }

  @override
  Widget build(BuildContext context) {
    final AfTokens t = context.af;
    final AppState state = AfAppScope.of(context);
    final String email = state.pendingVerificationEmail;

    return AfScaffold(
      screenId: AfScreen.verifyEmail,
      padding: const EdgeInsets.fromLTRB(8, 24, 8, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Center(child: AfEyebrow(AfStrings.verifyEyebrow)),
          const SizedBox(height: 6),
          Center(
            child: Text(
              AfStrings.verifyTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          const SizedBox(height: 6),
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
                  AfStrings.fill(AfStrings.verifyBody, <String, Object?>{
                    'email': email,
                  }),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 10),
                Text(
                  AfStrings.verifyHint,
                  textAlign: TextAlign.center,
                  style: AfText.muted(t),
                ),
                const SizedBox(height: 18),
                AfButton(
                  label: _busy ? AfStrings.pleaseWait : AfStrings.verifyConfirm,
                  expand: true,
                  onPressed: _busy ? null : _check,
                ),
                const SizedBox(height: 10),
                AfButton(
                  label: AfStrings.verifyResend,
                  variant: AfButtonVariant.secondary,
                  expand: true,
                  onPressed: _busy ? null : _resend,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: GestureDetector(
              onTap: _backToLogin,
              child: Text(
                AfStrings.verifyBack,
                style: TextStyle(
                  color: t.accent,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
