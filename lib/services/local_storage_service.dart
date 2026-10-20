import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_models.dart';

class LocalStorageService {
  static SharedPreferences? _prefs;

  static Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ==================== AUTH & ACCOUNTS ====================

  /// Checks if there is an active session
  static Future<bool> isLoggedIn() async {
    final prefs = await _getPrefs();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  /// Internal helper to retrieve the list of registered users
  static Future<List<Map<String, dynamic>>> _getRegisteredUsers() async {
    final prefs = await _getPrefs();
    final String? usersStr = prefs.getString('registered_users');
    if (usersStr == null) return [];
    final List<dynamic> decoded = jsonDecode(usersStr);
    return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  /// Registers a new user account with credentials.
  /// Returns null on success, or an error message if email/username exists.
  static Future<String?> registerAccount({
    required String username,
    required String email,
    required String password,
    String gender = 'Prefer not to say',
    String dateOfBirth = '',
  }) async {
    final prefs = await _getPrefs();
    final users = await _getRegisteredUsers();

    final normalizedEmail = email.trim().toLowerCase();

    // Check if email already exists
    final emailExists = users.any(
      (u) => (u['email'] as String).toLowerCase() == normalizedEmail,
    );
    if (emailExists) {
      return 'An account with this email already exists.';
    }

    final newUser = {
      'id': 'user_${DateTime.now().millisecondsSinceEpoch}',
      'username': username.trim(),
      'email': normalizedEmail,
      'password': password,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      'createdAt': DateTime.now().toIso8601String(),
    };

    users.add(newUser);
    await prefs.setString('registered_users', jsonEncode(users));

    // Automatically set as active user
    await _saveCurrentSession(newUser);
    return null;
  }

  /// Validates email and password against registered users.
  /// Returns the UserAccount if successful, or null if invalid.
  static Future<UserAccount?> login(String email, String password) async {
    final users = await _getRegisteredUsers();
    final normalizedEmail = email.trim().toLowerCase();

    final matched = users.firstWhere(
      (u) =>
          (u['email'] as String).toLowerCase() == normalizedEmail &&
          u['password'] == password,
      orElse: () => {},
    );

    if (matched.isEmpty) {
      return null;
    }

    await _saveCurrentSession(matched);

    return UserAccount(
      id: matched['id'],
      username: matched['username'],
      email: matched['email'],
      gender: matched['gender'] ?? 'Prefer not to say',
      dateOfBirth: matched['dateOfBirth'] ?? '',
      createdAt: DateTime.parse(matched['createdAt']),
    );
  }

  static Future<void> _saveCurrentSession(Map<String, dynamic> userData) async {
    final prefs = await _getPrefs();
    await prefs.setString(
      'current_user',
      jsonEncode({
        'id': userData['id'],
        'username': userData['username'],
        'email': userData['email'],
        'gender': userData['gender'],
        'dateOfBirth': userData['dateOfBirth'],
        'createdAt': userData['createdAt'],
      }),
    );
    await prefs.setBool('isLoggedIn', true);
  }

  /// Gets the currently logged-in user profile
  static Future<UserAccount?> getUser() async {
    final prefs = await _getPrefs();
    final String? userStr = prefs.getString('current_user');
    if (userStr == null) return null;
    final Map<String, dynamic> data = jsonDecode(userStr);

    return UserAccount(
      id: data['id'],
      username: data['username'],
      email: data['email'],
      gender: data['gender'] ?? 'Prefer not to say',
      dateOfBirth: data['dateOfBirth'] ?? '',
      createdAt: DateTime.parse(data['createdAt']),
    );
  }

  /// Clears only the active session, keeping registered users and settings intact
  static Future<void> logout() async {
    final prefs = await _getPrefs();
    await prefs.remove('current_user');
    await prefs.setBool('isLoggedIn', false);
    await clearActiveWorkout();
  }

  // ==================== THEME ====================

  static Future<bool> isDarkMode() async {
    final prefs = await _getPrefs();
    return prefs.getBool('isDarkMode') ?? false;
  }

  static Future<void> setDarkMode(bool value) async {
    final prefs = await _getPrefs();
    await prefs.setBool('isDarkMode', value);
  }

  // ==================== WORKOUT SETS ====================

  static Future<List<WorkoutSet>> getActiveWorkoutSets() async {
    final prefs = await _getPrefs();
    final String? setsStr = prefs.getString('active_workout_sets');
    if (setsStr == null) return [];
    final List<dynamic> data = jsonDecode(setsStr);
    return data
        .map((e) => workoutSetFromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static Future<void> saveActiveWorkoutSets(List<WorkoutSet> sets) async {
    final prefs = await _getPrefs();
    await prefs.setString(
      'active_workout_sets',
      jsonEncode(sets.map((e) => e.toJson()).toList()),
    );
  }

  static Future<void> clearActiveWorkout() async {
    final prefs = await _getPrefs();
    await prefs.remove('active_workout_sets');
  }
}

// ==================== SERIALIZATION HELPERS ====================

extension WorkoutSetJson on WorkoutSet {
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'setNo': setNo,
      'weightKg': weightKg,
      'reps': reps,
      'restS': restS,
      'inputMethod': inputMethod,
    };
  }
}

WorkoutSet workoutSetFromJson(Map<String, dynamic> json) {
  return WorkoutSet(
    id: json['id'],
    exerciseId: json['exerciseId'],
    exerciseName: json['exerciseName'],
    setNo: json['setNo'],
    weightKg: json['weightKg'],
    reps: json['reps'],
    restS: json['restS'],
    inputMethod: json['inputMethod'],
  );
}
