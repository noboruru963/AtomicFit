import 'package:flutter_test/flutter_test.dart';

import 'package:atomfit/services/personal_details_validation.dart';

void main() {
  final DateTime now = DateTime(2026, 10, 22);

  PersonalDetailsCheck valid({
    String username = 'Alex',
    String day = '14',
    String month = 'May',
    String year = '1998',
    String gender = 'Male',
    String weight = '74.5',
    String height = '178',
  }) {
    return validatePersonalDetails(
      username: username,
      dobDay: day,
      dobMonth: month,
      dobYear: year,
      gender: gender,
      weightRaw: weight,
      heightRaw: height,
      now: now,
    );
  }

  test('a complete form is valid', () {
    final PersonalDetailsCheck check = valid();
    expect(check.isValid, isTrue);
    expect(check.username, 'Alex');
    expect(check.dobDay, '14');
    expect(check.dobMonth, 'May');
    expect(check.dobYear, '1998');
    expect(check.gender, 'Male');
    expect(check.weightKg, '74.5');
    expect(check.heightCm, '178');
  });

  test('the username is required', () {
    final PersonalDetailsCheck check = valid(username: '   ');
    expect(check.isValid, isFalse);
    expect(check.field, 'Username');
  });

  test('the date of birth is required', () {
    expect(valid(day: '').field, 'Date of birth');
    expect(valid(month: '').field, 'Date of birth');
    expect(valid(year: '').field, 'Date of birth');
  });

  test('the date of birth must be a real calendar date', () {
    expect(valid(day: '31', month: 'February', year: '2000').field,
        'Date of birth');
    expect(
        valid(day: '31', month: 'April', year: '2000').field, 'Date of birth');
    // 30 April exists.
    expect(valid(day: '30', month: 'April', year: '2000').isValid, isTrue);
  });

  test('the date of birth must be in the past', () {
    final PersonalDetailsCheck check = valid(
      day: '22',
      month: 'October',
      year: '2026',
    );
    expect(check.isValid, isFalse);
    expect(check.field, 'Date of birth');
  });

  test('a numeric month is accepted', () {
    final PersonalDetailsCheck check = valid(month: '5');
    expect(check.isValid, isTrue);
    expect(check.dobMonth, 'May');
  });

  test('the weight is required and limited to one decimal', () {
    expect(valid(weight: '').field, 'Weight');
    expect(valid(weight: '74.55').field, 'Weight');
    expect(valid(weight: '1000').field, 'Weight');
    expect(valid(weight: '-1').field, 'Weight');
    expect(valid(weight: '999.9').isValid, isTrue);
  });

  test('the height must be a whole number in cm', () {
    expect(valid(height: '').field, 'Height');
    expect(valid(height: '17.8').field, 'Height');
    expect(valid(height: '0').field, 'Height');
    expect(valid(height: '301').field, 'Height');
    expect(valid(height: '300').isValid, isTrue);
  });

  test('an empty gender falls back to "Prefer not to say"', () {
    expect(valid(gender: '').gender, 'Prefer not to say');
  });
}
