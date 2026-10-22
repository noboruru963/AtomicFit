import 'package:flutter/material.dart';

import '../app/shell.dart';
import '../services/personal_details_validation.dart';
import '../state/app_state.dart';
import '../strings.dart';
import '../theme/app_theme.dart';
import '../widgets/af_widgets.dart';

/// Port of `renderPersonalDetailsScreen()` (`index.html` lines 1873-1944).
///
/// The step that follows registration and the first login of an account whose
/// details are not complete yet.
class PersonalDetailsScreen extends StatefulWidget {
  const PersonalDetailsScreen({super.key});

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _weight = TextEditingController();
  final TextEditingController _height = TextEditingController();

  String _day = '';
  String _month = '';
  String _year = '';
  String _gender = 'Prefer not to say';
  String? _error;
  bool _initialised = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialised) return;
    _initialised = true;
    final AppState state = AfAppScope.of(context);
    _username.text = state.user.username;
    _day = state.user.dobDay;
    _month = state.user.dobMonth;
    _year = state.user.dobYear;
    _gender =
        state.user.gender.isEmpty ? 'Prefer not to say' : state.user.gender;
    _weight.text = state.user.weightKg;
    _height.text = state.user.heightCm;
  }

  @override
  void dispose() {
    _username.dispose();
    _weight.dispose();
    _height.dispose();
    super.dispose();
  }

  void _submit() {
    final AppState state = AfAppScope.of(context);
    final PersonalDetailsCheck check = state.savePersonalDetails(
      username: _username.text,
      dobDay: _day,
      dobMonth: _month,
      dobYear: _year,
      gender: _gender,
      weightRaw: _weight.text,
      heightRaw: _height.text,
    );
    if (!check.isValid) {
      setState(() => _error = check.error);
      return;
    }

    setState(() => _error = null);
    state.showToast(
      AfStrings.fill(AfStrings.personalDetailsSavedToast, <String, Object?>{
        'name': check.username,
      }),
    );
    Navigator.of(context).pushReplacementNamed(AfScreen.home);
  }

  @override
  Widget build(BuildContext context) {
    final AfTokens t = context.af;

    return AfScaffold(
      screenId: AfScreen.personalDetails,
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Center(child: AfEyebrow(AfStrings.registerEyebrow)),
          const SizedBox(height: 6),
          Center(
            child: Text(
              AfStrings.personalDetailsTitle,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              AfStrings.personalDetailsSubtitle,
              style: AfText.muted(t),
              textAlign: TextAlign.center,
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
                  AfStrings.personalDetailsUsername,
                  style: AfText.muted(t, weight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                AfTextField(
                  controller: _username,
                  hint: AfStrings.personalDetailsUsernamePlaceholder,
                ),
                const SizedBox(height: 14),
                Text(
                  AfStrings.personalDetailsDob,
                  style: AfText.muted(t, weight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: AfDropdown(
                        value: _day,
                        hint: AfStrings.personalDetailsDay,
                        items: <String>[
                          for (int day = 1; day <= 31; day++) '$day',
                        ],
                        onChanged: (String value) =>
                            setState(() => _day = value),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AfDropdown(
                        value: _month,
                        hint: AfStrings.personalDetailsMonth,
                        items: calendarMonths,
                        onChanged: (String value) =>
                            setState(() => _month = value),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AfDropdown(
                        value: _year,
                        hint: AfStrings.personalDetailsYear,
                        items: <String>[
                          for (int year = 2025; year >= 1920; year--) '$year',
                        ],
                        onChanged: (String value) =>
                            setState(() => _year = value),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  AfStrings.personalDetailsGender,
                  style: AfText.muted(t, weight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                AfDropdown(
                  value: _gender,
                  hint: AfStrings.personalDetailsGender,
                  items: const <String>[
                    'Prefer not to say',
                    'Male',
                    'Female',
                  ],
                  onChanged: (String value) => setState(() => _gender = value),
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
                            AfStrings.personalDetailsWeight,
                            style: AfText.muted(t, weight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          AfTextField(
                            controller: _weight,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            hint: AfStrings.personalDetailsWeightPlaceholder,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            AfStrings.personalDetailsHeight,
                            style: AfText.muted(t, weight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          AfTextField(
                            controller: _height,
                            keyboardType: TextInputType.number,
                            hint: AfStrings.personalDetailsHeightPlaceholder,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AfButton(
                  label: AfStrings.personalDetailsContinue,
                  expand: true,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
