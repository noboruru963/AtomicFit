/// Validation for the personal-details step.
///
/// Ported 1:1 from the prototype's `validatePersonalDetailsInput`
/// (`index.html` lines 1804-1871), including the month names, the weight
/// format (`0` – `999.9`, one decimal) and the height format (whole cm).
library;

/// The month names used by the date-of-birth picker.
const List<String> calendarMonths = <String>[
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

/// The outcome of validating the personal-details form.
class PersonalDetailsCheck {
  const PersonalDetailsCheck.invalid(this.field, this.error)
      : isValid = false,
        username = '',
        dobDay = '',
        dobMonth = '',
        dobYear = '',
        gender = '',
        weightKg = '',
        heightCm = '';

  const PersonalDetailsCheck.valid({
    required this.username,
    required this.dobDay,
    required this.dobMonth,
    required this.dobYear,
    required this.gender,
    required this.weightKg,
    required this.heightCm,
  })  : isValid = true,
        field = '',
        error = '';

  /// Whether the input is acceptable.
  final bool isValid;

  /// The name of the offending field (empty when valid).
  final String field;

  /// The error message shown to the user (empty when valid).
  final String error;

  final String username;
  final String dobDay;
  final String dobMonth;
  final String dobYear;
  final String gender;
  final String weightKg;
  final String heightCm;
}

/// Validates the personal-details form.
///
/// [now] is injected so the "date in the past" rule is testable.
PersonalDetailsCheck validatePersonalDetails({
  required String username,
  required String dobDay,
  required String dobMonth,
  required String dobYear,
  required String gender,
  required String weightRaw,
  required String heightRaw,
  DateTime? now,
}) {
  final String cleanUsername = username.trim();
  if (cleanUsername.isEmpty) {
    return const PersonalDetailsCheck.invalid(
      'Username',
      'Username is required. Please enter a username.',
    );
  }

  final int dayNumber = int.tryParse(dobDay.trim()) ?? 0;
  final int yearNumber = int.tryParse(dobYear.trim()) ?? 0;
  final String monthText = dobMonth.trim();
  int monthIndex = calendarMonths.indexOf(monthText);
  if (monthIndex == -1 && RegExp(r'^\d+$').hasMatch(monthText)) {
    final int parsed = int.parse(monthText);
    if (parsed >= 1 && parsed <= 12) monthIndex = parsed - 1;
  }

  if (dobDay.trim().isEmpty ||
      monthText.isEmpty ||
      dobYear.trim().isEmpty ||
      dayNumber == 0 ||
      yearNumber == 0 ||
      monthIndex == -1) {
    return const PersonalDetailsCheck.invalid(
      'Date of birth',
      'Date of birth is required. Please enter a valid calendar date in the past.',
    );
  }

  final DateTime today = now ?? DateTime.now();
  // `monthIndex` is 0-based (like the prototype's `Date`), Dart's DateTime
  // constructor expects a 1-based month.
  final DateTime candidate = DateTime(yearNumber, monthIndex + 1, dayNumber);
  final DateTime todayStart = DateTime(today.year, today.month, today.day);
  if (candidate.year != yearNumber ||
      candidate.month != monthIndex + 1 ||
      candidate.day != dayNumber ||
      yearNumber < 1900 ||
      !candidate.isBefore(todayStart)) {
    return const PersonalDetailsCheck.invalid(
      'Date of birth',
      'Date of birth must be a valid calendar date in the past.',
    );
  }

  final String weightText = weightRaw.trim();
  if (weightText.isEmpty) {
    return const PersonalDetailsCheck.invalid(
      'Weight',
      'Weight is required. Please enter a weight between 0 and 999.9 kg.',
    );
  }
  if (!RegExp(r'^\d{1,3}(\.\d)?$').hasMatch(weightText)) {
    return const PersonalDetailsCheck.invalid(
      'Weight',
      'Weight must be a decimal between 0 and 999.9 kg '
          '(up to one decimal place).',
    );
  }
  final double weight = double.parse(weightText);
  if (weight < 0 || weight > 999.9) {
    return const PersonalDetailsCheck.invalid(
      'Weight',
      'Weight must be between 0 and 999.9 kg.',
    );
  }

  final String heightText = heightRaw.trim();
  if (heightText.isEmpty) {
    return const PersonalDetailsCheck.invalid(
      'Height',
      'Height is required. Please enter a whole number in cm.',
    );
  }
  if (!RegExp(r'^\d+$').hasMatch(heightText)) {
    return const PersonalDetailsCheck.invalid(
      'Height',
      'Height must be a whole number in cm.',
    );
  }
  final int height = int.parse(heightText);
  if (height <= 0 || height > 300) {
    return const PersonalDetailsCheck.invalid(
      'Height',
      'Height must be a valid whole number in cm.',
    );
  }

  final String cleanGender =
      gender.trim().isEmpty ? 'Prefer not to say' : gender.trim();

  return PersonalDetailsCheck.valid(
    username: cleanUsername,
    dobDay: '$dayNumber',
    dobMonth: calendarMonths[monthIndex],
    dobYear: '$yearNumber',
    gender: cleanGender,
    weightKg: weightText,
    heightCm: '$height',
  );
}
