import 'package:flutter/material.dart';

import '../app/shell.dart';
import '../state/app_state.dart';
import '../strings.dart';
import '../theme/app_theme.dart';
import '../widgets/af_widgets.dart';

/// Port of `renderRegisterScreen()` (`index.html` lines 1525-1581).
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _username = TextEditingController(text: 'Alex');
  final TextEditingController _email =
      TextEditingController(text: 'alex@example.com');
  final TextEditingController _password =
      TextEditingController(text: 'atomfit2026');
  final TextEditingController _confirm =
      TextEditingController(text: 'atomfit2026');
  final TextEditingController _dob = TextEditingController(text: '1998-05-14');

  String _gender = 'Prefer not to say';
  bool _terms = true;
  String? _error;

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    _dob.dispose();
    super.dispose();
  }

  void _submit() {
    final AppState state = AfAppScope.of(context);
    if (_password.text != _confirm.text) {
      setState(() => _error = AfStrings.registerPasswordMismatch);
      return;
    }
    if (!_terms) {
      setState(() => _error = AfStrings.registerTermsMissing);
      return;
    }
    setState(() => _error = null);
    state.saveProfile(
      username: _username.text,
      email: _email.text,
      gender: _gender,
      dobMonth: _dob.text,
      weightKg: state.user.weightKg,
      heightCm: state.user.heightCm,
    );
    state.showToast(
      AfStrings.fill(AfStrings.registerCreatedToast, <String, Object?>{
        'name': _username.text.trim().isEmpty ? 'Alex' : _username.text.trim(),
      }),
    );
    Navigator.of(context).pushReplacementNamed(AfScreen.home);
  }

  @override
  Widget build(BuildContext context) {
    final AfTokens t = context.af;

    return AfScaffold(
      screenId: AfScreen.register,
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 24),
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
                  AfStrings.registerUsername,
                  style: AfText.muted(t, weight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                AfTextField(
                  controller: _username,
                  hint: AfStrings.registerUsernamePlaceholder,
                ),
                const SizedBox(height: 14),
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            AfStrings.registerPassword,
                            style: AfText.muted(t, weight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          AfTextField(controller: _password, obscureText: true),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            AfStrings.registerConfirmPassword,
                            style: AfText.muted(t, weight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          AfTextField(controller: _confirm, obscureText: true),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            AfStrings.registerDob,
                            style: AfText.muted(t, weight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          AfTextField(controller: _dob),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            AfStrings.registerGender,
                            style: AfText.muted(t, weight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          DropdownButtonFormField<String>(
                            initialValue: _gender,
                            isExpanded: true,
                            decoration: const InputDecoration(),
                            style: Theme.of(context).textTheme.bodyMedium,
                            items: const <DropdownMenuItem<String>>[
                              DropdownMenuItem<String>(
                                value: AfStrings.registerSelectOption,
                                child: Text(
                                  AfStrings.registerSelectOption,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              DropdownMenuItem<String>(
                                value: AfStrings.genderMale,
                                child: Text(AfStrings.genderMale),
                              ),
                              DropdownMenuItem<String>(
                                value: AfStrings.genderFemale,
                                child: Text(AfStrings.genderFemale),
                              ),
                              DropdownMenuItem<String>(
                                value: AfStrings.genderPreferNot,
                                child: Text(
                                  AfStrings.genderPreferNot,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                            onChanged: (String? value) {
                              if (value == null ||
                                  value == AfStrings.registerSelectOption) {
                                return;
                              }
                              setState(() => _gender = value);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
                  label: AfStrings.registerButton,
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
