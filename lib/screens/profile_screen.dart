import 'package:flutter/material.dart';

import '../app/shell.dart';
import '../services/personal_details_validation.dart';
import '../state/app_state.dart';
import '../strings.dart';
import '../theme/app_theme.dart';
import '../widgets/af_widgets.dart';

/// Port of `renderProfileScreen()` (`index.html` lines 4784-4909).
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _username = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _weight = TextEditingController();
  final TextEditingController _height = TextEditingController();

  String _day = '';
  String _month = '';
  String _year = '';
  String _gender = AfStrings.genderPreferNot;
  String? _error;
  bool _initialised = false;

  static const List<String> _months = calendarMonths;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialised) return;
    _initialised = true;
    final AppState state = AfAppScope.of(context);
    _username.text = state.user.username;
    _email.text = state.user.email;
    _weight.text = state.user.weightKg;
    _height.text = state.user.heightCm;
    _day = state.user.dobDay;
    _month = state.user.dobMonth;
    _year = state.user.dobYear;
    _gender = state.user.gender.isEmpty
        ? AfStrings.genderPreferNot
        : state.user.gender;
  }

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _weight.dispose();
    _height.dispose();
    super.dispose();
  }

  void _update(AppState state) {
    final PersonalDetailsCheck check = validatePersonalDetails(
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
    state.saveProfile(
      username: check.username,
      email: _email.text.trim().isEmpty ? state.user.email : _email.text.trim(),
      gender: check.gender,
      dobDay: check.dobDay,
      dobMonth: check.dobMonth,
      dobYear: check.dobYear,
      weightKg: check.weightKg,
      heightCm: check.heightCm,
    );
  }

  @override
  Widget build(BuildContext context) {
    final AfTokens t = context.af;
    final AppState state = AfAppScope.of(context);
    final double totalVolume = state.history.fold<double>(
      0,
      (double sum, session) => sum + session.volume,
    );

    return AfScaffold(
      screenId: AfScreen.profile,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // ------------------------------------------------------- header card
          AfCard(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: <Widget>[
                Container(
                  width: 56,
                  height: 56,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: t.accent, width: 2),
                  ),
                  child: Image.asset(
                    'assets/images/logo.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        state.user.username,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        state.user.email,
                        style: AfText.muted(t),
                      ),
                      const SizedBox(height: 4),
                      AfBadge(
                        label: AfStrings.fill(
                          AfStrings.profileMemberSince,
                          <String, Object?>{'date': state.user.createdAt},
                        ),
                        fontSize: 10,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ------------------------------------------------------------- stats
          Row(
            children: <Widget>[
              Expanded(
                child: AfCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: <Widget>[
                      Text(
                        AfStrings.profileSessions,
                        style: AfText.muted(t, size: 11),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${state.history.length}',
                        style: AfText.strong(t, size: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AfCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: <Widget>[
                      Text(
                        AfStrings.profileVolume,
                        style: AfText.muted(t, size: 11),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${totalVolume.round()} kg',
                        style: TextStyle(
                          color: t.accent,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // -------------------------------------------------- personal details
          AfCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  AfStrings.profileDetails,
                  style: AfText.strong(t, size: 14),
                ),
                if (_error != null) ...<Widget>[
                  const SizedBox(height: 10),
                  AfErrorBanner(message: _error!),
                ],
                const SizedBox(height: 12),
                Text(
                  AfStrings.profileUsername,
                  style: AfText.muted(t, weight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                AfTextField(
                  controller: _username,
                  style: AfText.muted(t, size: 12),
                ),
                const SizedBox(height: 12),
                Text(
                  AfStrings.profileEmail,
                  style: AfText.muted(t, weight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                AfTextField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  style: AfText.muted(t, size: 12),
                ),
                const SizedBox(height: 12),
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
                        style: AfText.muted(t, size: 12),
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
                        style: AfText.muted(t, size: 12),
                        items: _months,
                        onChanged: (String value) =>
                            setState(() => _month = value),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AfDropdown(
                        value: _year,
                        hint: AfStrings.personalDetailsYear,
                        style: AfText.muted(t, size: 12),
                        items: <String>[
                          for (int year = 2025; year >= 1920; year--) '$year',
                        ],
                        onChanged: (String value) =>
                            setState(() => _year = value),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  AfStrings.profileGender,
                  style: AfText.muted(t, weight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                AfDropdown(
                  value: _gender,
                  style: AfText.muted(t, size: 12),
                  items: const <String>[
                    AfStrings.genderMale,
                    AfStrings.genderFemale,
                    AfStrings.genderPreferNot,
                  ],
                  onChanged: (String value) => setState(() => _gender = value),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            AfStrings.profileWeight,
                            style: AfText.muted(t, weight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          AfTextField(
                            controller: _weight,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            style: AfText.muted(t, size: 12),
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
                            AfStrings.profileHeight,
                            style: AfText.muted(t, weight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          AfTextField(
                            controller: _height,
                            keyboardType: TextInputType.number,
                            style: AfText.muted(t, size: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AfButton(
                  label: AfStrings.profileUpdate,
                  size: AfButtonSize.compact,
                  expand: true,
                  onPressed: () => _update(state),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
