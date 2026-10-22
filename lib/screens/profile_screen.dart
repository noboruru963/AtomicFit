import 'package:flutter/material.dart';

import '../app/shell.dart';
import '../state/app_state.dart';
import '../strings.dart';
import '../theme/app_theme.dart';
import '../widgets/af_widgets.dart';

/// Port of `renderProfileScreen()` (`index.html` lines 3979-4053).
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _username;
  late final TextEditingController _email;
  late final TextEditingController _weight;
  late final TextEditingController _height;
  late String _gender;
  late String _dobMonth;

  static const List<String> _months = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  void initState() {
    super.initState();
    final AppState state = AfAppScope.read(context);
    _username = TextEditingController(text: state.user.username);
    _email = TextEditingController(text: state.user.email);
    _weight = TextEditingController(text: state.user.weightKg);
    _height = TextEditingController(text: state.user.heightCm);
    _gender = state.user.gender;
    _dobMonth = state.user.dobMonth.isEmpty ? 'May' : state.user.dobMonth;
  }

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _weight.dispose();
    _height.dispose();
    super.dispose();
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
          AfCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  AfStrings.profileDetails,
                  style: AfText.strong(t, size: 14),
                ),
                const SizedBox(height: 12),
                Text(
                  AfStrings.profileUsername,
                  style: AfText.muted(t, weight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                AfTextField(
                    controller: _username, style: AfText.muted(t, size: 12)),
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            AfStrings.profileGender,
                            style: AfText.muted(t, weight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          DropdownButtonFormField<String>(
                            initialValue: _gender,
                            isExpanded: true,
                            style: AfText.muted(t, size: 12),
                            items: const <DropdownMenuItem<String>>[
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
                              if (value == null) return;
                              setState(() => _gender = value);
                            },
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
                            AfStrings.profileDobMonth,
                            style: AfText.muted(t, weight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          DropdownButtonFormField<String>(
                            initialValue:
                                _months.contains(_dobMonth) ? _dobMonth : 'May',
                            isExpanded: true,
                            style: AfText.muted(t, size: 12),
                            items: <DropdownMenuItem<String>>[
                              for (final String month in _months)
                                DropdownMenuItem<String>(
                                  value: month,
                                  child: Text(month),
                                ),
                            ],
                            onChanged: (String? value) {
                              if (value == null) return;
                              setState(() => _dobMonth = value);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
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
                                decimal: true),
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
                  onPressed: () {
                    state.saveProfile(
                      username: _username.text,
                      email: _email.text,
                      gender: _gender,
                      dobMonth: _dobMonth,
                      weightKg: _weight.text,
                      heightCm: _height.text,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
