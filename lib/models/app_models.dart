class UserAccount {
  final String id;
  final String username;
  final String email;
  final String gender;
  final String dateOfBirth;
  final DateTime createdAt;

  UserAccount({
    required this.id,
    required this.username,
    required this.email,
    this.gender = 'Prefer not to say',
    this.dateOfBirth = '',
    required this.createdAt,
  });
}

class Exercise {
  final String id;
  final String name;
  final String description;

  Exercise({required this.id, required this.name, this.description = ''});
}

class Program {
  final String id;
  final String name;
  final String type; // 'Built-in' or 'Current'
  final List<String> exercises;
  final int sets;
  final double weight;
  final String rest;
  final bool isCurrent;

  Program({
    required this.id,
    required this.name,
    this.type = 'Built-in',
    required this.exercises,
    this.sets = 3,
    this.weight = 10,
    this.rest = '2:00',
    this.isCurrent = false,
  });
}

class WorkoutSet {
  final String id;
  final String exerciseId;
  final String exerciseName;
  final int setNo;
  double weightKg;
  int reps;
  int restS;
  String inputMethod; // manual, sensor, voice, lockscreen

  WorkoutSet({
    required this.id,
    required this.exerciseId,
    required this.exerciseName,
    required this.setNo,
    this.weightKg = 0,
    this.reps = 0,
    this.restS = 120,
    this.inputMethod = 'manual',
  });
}

class WorkoutSession {
  final String id;
  final String name;
  final String type; // full, micro, stitched
  final String status; // complete, incomplete
  final DateTime startedAt;
  final int reps;
  final double volumeKg;
  final int children;

  WorkoutSession({
    required this.id,
    required this.name,
    this.type = 'full',
    this.status = 'incomplete',
    required this.startedAt,
    this.reps = 0,
    this.volumeKg = 0,
    this.children = 0,
  });
}
