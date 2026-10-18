import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_models.dart';

class LocalStorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Auth
  static Future<bool> isLoggedIn() async {
    await init();
    return _prefs!.getBool('isLoggedIn') ?? false;
  }

  static Future<void> saveUser(UserAccount user) async {
    await init();
    await _prefs!.setString('user', jsonEncode({
      'id': user.id,
      'username': user.username,
      'email': user.email,
      'gender': user.gender,
      'dateOfBirth': user.dateOfBirth,
      'createdAt': user.createdAt.toIso8601String(),
    }));
    await _prefs!.setBool('isLoggedIn', true);
  }

  static UserAccount? getUser() async {
    await init();
    final String? userStr = _prefs!.getString('user');
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

  static Future<void> logout() async {
    await init();
    await _prefs!.clear();
    await _prefs!.setBool('isLoggedIn', false);
  }

  // Theme
  static Future<bool> isDarkMode() async {
    await init();
    return _prefs!.getBool('isDarkMode') ?? false;
  }

  static Future<void> setDarkMode(bool value) async {
    await init();
    await _prefs!.setBool('isDarkMode', value);
  }

  // Workout sets
  static Future<List<WorkoutSet>> getActiveWorkoutSets() async {
    await init();
    final String? setsStr = _prefs!.getString('active_workout_sets');
    if (setsStr == null) return [];
    final List<dynamic> data = jsonDecode(setsStr);
    return data.map((e) => WorkoutSet.fromJson(e)).toList();
  }

  static Future<void> saveActiveWorkoutSets(List<WorkoutSet> sets) async {
    await init();
    await _prefs!.setString(
      'active_workout_sets',
      jsonEncode(sets.map((e) => e.toJson()).toList()),
    );
  }

  static Future<void> clearActiveWorkout() async {
    await init();
    await _prefs!.remove('active_workout_sets');
  }
}

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

  WorkoutSet fromJson(Map<String, dynamic> json) {
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
}
