/// Domain models for AtomFit.
///
/// Every record is a plain JSON map with a stable envelope
/// (`id`, `userId`, `createdAtUtc`, `updatedAtUtc`, `deletedAtUtc`) so the same
/// objects can be stored locally today and dropped into a document database
/// (Firestore) later without a converter layer. See `lib/data/README.md`.
library;

// ignore_for_file: annotate_overrides

String _nowIso() => DateTime.now().toUtc().toIso8601String();

/// Base envelope shared by every persisted record.
mixin RecordEnvelope {
  String get id;
  String get userId;
  String get createdAtUtc;
  String get updatedAtUtc;
  String? get deletedAtUtc;
}

/// The signed-in athlete. Mirrors `appState.user` in the web prototype.
class AppUser with RecordEnvelope {
  const AppUser({
    required this.id,
    required this.userId,
    required this.username,
    required this.email,
    required this.gender,
    required this.dobDay,
    required this.dobMonth,
    required this.dobYear,
    required this.weightKg,
    required this.heightCm,
    required this.createdAt,
    required this.createdAtUtc,
    required this.updatedAtUtc,
    this.deletedAtUtc,
  });

  final String id;
  final String userId;
  final String username;
  final String email;
  final String gender;
  final String dobDay;
  final String dobMonth;
  final String dobYear;
  final String weightKg;
  final String heightCm;

  /// Human readable join date, e.g. "October 2026".
  final String createdAt;
  final String createdAtUtc;
  final String updatedAtUtc;
  final String? deletedAtUtc;

  static AppUser defaultUser() {
    final String now = _nowIso();
    return AppUser(
      id: 'u_alex_01',
      userId: 'u_alex_01',
      username: 'Alex',
      email: 'alex@example.com',
      gender: 'Prefer not to say',
      dobDay: '14',
      dobMonth: 'May',
      dobYear: '1998',
      weightKg: '74',
      heightCm: '178',
      createdAt: 'October 2026',
      createdAtUtc: now,
      updatedAtUtc: now,
    );
  }

  AppUser copyWith({
    String? username,
    String? email,
    String? gender,
    String? dobDay,
    String? dobMonth,
    String? dobYear,
    String? weightKg,
    String? heightCm,
    String? updatedAtUtc,
  }) {
    return AppUser(
      id: id,
      userId: userId,
      username: username ?? this.username,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      dobDay: dobDay ?? this.dobDay,
      dobMonth: dobMonth ?? this.dobMonth,
      dobYear: dobYear ?? this.dobYear,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      createdAt: createdAt,
      createdAtUtc: createdAtUtc,
      updatedAtUtc: updatedAtUtc ?? _nowIso(),
      deletedAtUtc: deletedAtUtc,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'userId': userId,
        'username': username,
        'email': email,
        'gender': gender,
        'dobDay': dobDay,
        'dobMonth': dobMonth,
        'dobYear': dobYear,
        'weightKg': weightKg,
        'heightCm': heightCm,
        'createdAt': createdAt,
        'createdAtUtc': createdAtUtc,
        'updatedAtUtc': updatedAtUtc,
        'deletedAtUtc': deletedAtUtc,
      };

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: (json['id'] ?? 'u_alex_01').toString(),
        userId: (json['userId'] ?? json['id'] ?? 'u_alex_01').toString(),
        username: (json['username'] ?? 'Alex').toString(),
        email: (json['email'] ?? 'alex@example.com').toString(),
        gender: (json['gender'] ?? 'Prefer not to say').toString(),
        dobDay: (json['dobDay'] ?? '').toString(),
        dobMonth: (json['dobMonth'] ?? '').toString(),
        dobYear: (json['dobYear'] ?? '').toString(),
        weightKg: (json['weightKg'] ?? '').toString(),
        heightCm: (json['heightCm'] ?? '').toString(),
        createdAt: (json['createdAt'] ?? '').toString(),
        createdAtUtc: (json['createdAtUtc'] ?? _nowIso()).toString(),
        updatedAtUtc: (json['updatedAtUtc'] ?? _nowIso()).toString(),
        deletedAtUtc: json['deletedAtUtc']?.toString(),
      );
}

/// Device / behaviour preferences. Mirrors `appState.settings`.
class AppSettings with RecordEnvelope {
  const AppSettings({
    required this.id,
    required this.userId,
    required this.sensorAutoDetect,
    required this.voiceLogging,
    required this.hapticFeedback,
    required this.lockscreenWidget,
    required this.bellSound,
    required this.restNotifications,
    required this.createdAtUtc,
    required this.updatedAtUtc,
    this.deletedAtUtc,
  });

  final String id;
  final String userId;
  final bool sensorAutoDetect;
  final bool voiceLogging;
  final bool hapticFeedback;
  final bool lockscreenWidget;
  final bool bellSound;
  final bool restNotifications;
  final String createdAtUtc;
  final String updatedAtUtc;
  final String? deletedAtUtc;

  static AppSettings defaults(String userId) {
    final String now = _nowIso();
    return AppSettings(
      id: 'settings_$userId',
      userId: userId,
      sensorAutoDetect: true,
      voiceLogging: true,
      hapticFeedback: true,
      lockscreenWidget: true,
      bellSound: true,
      restNotifications: true,
      createdAtUtc: now,
      updatedAtUtc: now,
    );
  }

  AppSettings copyWith({
    bool? sensorAutoDetect,
    bool? voiceLogging,
    bool? hapticFeedback,
    bool? lockscreenWidget,
    bool? bellSound,
    bool? restNotifications,
  }) {
    return AppSettings(
      id: id,
      userId: userId,
      sensorAutoDetect: sensorAutoDetect ?? this.sensorAutoDetect,
      voiceLogging: voiceLogging ?? this.voiceLogging,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      lockscreenWidget: lockscreenWidget ?? this.lockscreenWidget,
      bellSound: bellSound ?? this.bellSound,
      restNotifications: restNotifications ?? this.restNotifications,
      createdAtUtc: createdAtUtc,
      updatedAtUtc: _nowIso(),
      deletedAtUtc: deletedAtUtc,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'userId': userId,
        'sensorAutoDetect': sensorAutoDetect,
        'voiceLogging': voiceLogging,
        'hapticFeedback': hapticFeedback,
        'lockscreenWidget': lockscreenWidget,
        'bellSound': bellSound,
        'restNotifications': restNotifications,
        'createdAtUtc': createdAtUtc,
        'updatedAtUtc': updatedAtUtc,
        'deletedAtUtc': deletedAtUtc,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        id: (json['id'] ?? 'settings_u_alex_01').toString(),
        userId: (json['userId'] ?? 'u_alex_01').toString(),
        sensorAutoDetect: json['sensorAutoDetect'] == true,
        voiceLogging: json['voiceLogging'] == true,
        hapticFeedback: json['hapticFeedback'] == true,
        lockscreenWidget: json['lockscreenWidget'] == true,
        bellSound: json['bellSound'] == true,
        restNotifications: json['restNotifications'] == true,
        createdAtUtc: (json['createdAtUtc'] ?? _nowIso()).toString(),
        updatedAtUtc: (json['updatedAtUtc'] ?? _nowIso()).toString(),
        deletedAtUtc: json['deletedAtUtc']?.toString(),
      );
}

/// Catalogue entry. Mirrors `DEFAULT_CATALOGUE` entries.
class Exercise with RecordEnvelope {
  const Exercise({
    required this.id,
    required this.userId,
    required this.name,
    required this.category,
    required this.defaultKg,
    required this.defaultReps,
    required this.defaultSets,
    required this.description,
    required this.isCustom,
    required this.createdAtUtc,
    required this.updatedAtUtc,
    this.nameEn = '',
    this.descriptionEn = '',
    this.bodyPart = '',
    this.bodyPartLabel = '',
    this.exerciseCategory = '',
    this.mechanic = '',
    this.forceType = '',
    this.difficulty = '',
    this.equipment = '',
    this.primaryMuscles = const <String>[],
    this.secondaryMuscles = const <String>[],
    this.goals = const <String>[],
    this.tags = const <String>[],
    this.instructions = const <String>[],
    this.tips = const <String>[],
    this.images = const <String, dynamic>{},
    this.isBodyweight = false,
    this.isUnilateral = false,
    this.met,
    this.variationGroup = '',
    this.searchIndex = '',
    this.deletedAtUtc,
  });

  final String id;
  final String userId;
  final String name;
  final String category;
  final double defaultKg;
  final int defaultReps;
  final int defaultSets;
  final String description;
  final bool isCustom;
  final String createdAtUtc;
  final String updatedAtUtc;

  // ------------------------------------------------- RepDB catalogue fields
  /// English display name (`name_en`).
  final String nameEn;

  /// English description (`description_en`).
  final String descriptionEn;

  /// Raw body part, e.g. `upper_legs`.
  final String bodyPart;

  /// Display body part, e.g. `Hips / Glutes`.
  final String bodyPartLabel;

  /// `strength` | `stretching` | …
  final String exerciseCategory;

  /// `compound` | `isolation`.
  final String mechanic;

  /// `push` | `pull` | `static`.
  final String forceType;

  /// `beginner` | `intermediate` | `advanced`.
  final String difficulty;

  /// Equipment slug, e.g. `pull_up_bar`.
  final String equipment;

  /// Primary muscle slugs.
  final List<String> primaryMuscles;

  /// Secondary muscle slugs.
  final List<String> secondaryMuscles;

  /// Training goals, e.g. `hypertrophy`.
  final List<String> goals;

  /// Free-form safety tags.
  final List<String> tags;

  /// Step-by-step instructions.
  final List<String> instructions;

  /// Form tips.
  final List<String> tips;

  /// Illustration paths (`start`, `peak`, `main`).
  final Map<String, dynamic> images;

  final bool isBodyweight;
  final bool isUnilateral;

  /// Metabolic equivalent, when the dataset provides one.
  final double? met;

  /// Grouping slug for variations of the same movement.
  final String variationGroup;

  /// Lower-cased haystack used by the Discover search.
  final String searchIndex;

  final String? deletedAtUtc;

  Exercise copyWith({
    String? name,
    String? category,
    double? defaultKg,
    int? defaultReps,
    int? defaultSets,
    String? description,
    bool? isCustom,
    String? bodyPartLabel,
    String? bodyPart,
    String? searchIndex,
  }) {
    return Exercise(
      id: id,
      userId: userId,
      name: name ?? this.name,
      category: category ?? this.category,
      defaultKg: defaultKg ?? this.defaultKg,
      defaultReps: defaultReps ?? this.defaultReps,
      defaultSets: defaultSets ?? this.defaultSets,
      description: description ?? this.description,
      isCustom: isCustom ?? this.isCustom,
      createdAtUtc: createdAtUtc,
      updatedAtUtc: _nowIso(),
      nameEn: nameEn,
      descriptionEn: descriptionEn,
      bodyPart: bodyPart ?? this.bodyPart,
      bodyPartLabel: bodyPartLabel ?? this.bodyPartLabel,
      exerciseCategory: exerciseCategory,
      mechanic: mechanic,
      forceType: forceType,
      difficulty: difficulty,
      equipment: equipment,
      primaryMuscles: primaryMuscles,
      secondaryMuscles: secondaryMuscles,
      goals: goals,
      tags: tags,
      instructions: instructions,
      tips: tips,
      images: images,
      isBodyweight: isBodyweight,
      isUnilateral: isUnilateral,
      met: met,
      variationGroup: variationGroup,
      searchIndex: searchIndex ?? this.searchIndex,
      deletedAtUtc: deletedAtUtc,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'userId': userId,
        'name': name,
        'category': category,
        'defaultKg': defaultKg,
        'defaultReps': defaultReps,
        'defaultSets': defaultSets,
        'description': description,
        'isCustom': isCustom,
        'createdAtUtc': createdAtUtc,
        'updatedAtUtc': updatedAtUtc,
        'nameEn': nameEn,
        'descriptionEn': descriptionEn,
        'bodyPart': bodyPart,
        'bodyPartLabel': bodyPartLabel,
        'exerciseCategory': exerciseCategory,
        'mechanic': mechanic,
        'forceType': forceType,
        'difficulty': difficulty,
        'equipment': equipment,
        'primaryMuscles': primaryMuscles,
        'secondaryMuscles': secondaryMuscles,
        'goals': goals,
        'tags': tags,
        'instructions': instructions,
        'tips': tips,
        'images': images,
        'isBodyweight': isBodyweight,
        'isUnilateral': isUnilateral,
        'met': met,
        'variationGroup': variationGroup,
        'searchIndex': searchIndex,
        'deletedAtUtc': deletedAtUtc,
      };

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
        id: (json['id'] ?? '').toString(),
        userId: (json['userId'] ?? 'u_alex_01').toString(),
        name: (json['name'] ?? '').toString(),
        category: (json['category'] ?? 'Custom').toString(),
        defaultKg: _toDouble(json['defaultKg']),
        defaultReps: _toInt(json['defaultReps'], 10),
        defaultSets: _toInt(json['defaultSets'], 3),
        description: (json['description'] ?? '').toString(),
        isCustom: json['isCustom'] == true,
        createdAtUtc: (json['createdAtUtc'] ?? _nowIso()).toString(),
        updatedAtUtc: (json['updatedAtUtc'] ?? _nowIso()).toString(),
        nameEn: (json['nameEn'] ?? '').toString(),
        descriptionEn: (json['descriptionEn'] ?? '').toString(),
        bodyPart: (json['bodyPart'] ?? '').toString(),
        bodyPartLabel: (json['bodyPartLabel'] ?? '').toString(),
        exerciseCategory: (json['exerciseCategory'] ?? '').toString(),
        mechanic: (json['mechanic'] ?? '').toString(),
        forceType: (json['forceType'] ?? '').toString(),
        difficulty: (json['difficulty'] ?? '').toString(),
        equipment: (json['equipment'] ?? '').toString(),
        primaryMuscles: _asStringList(json['primaryMuscles']),
        secondaryMuscles: _asStringList(json['secondaryMuscles']),
        goals: _asStringList(json['goals']),
        tags: _asStringList(json['tags']),
        instructions: _asStringList(json['instructions']),
        tips: _asStringList(json['tips']),
        images: _asStringMap(json['images']),
        isBodyweight: json['isBodyweight'] == true,
        isUnilateral: json['isUnilateral'] == true,
        met: json['met'] == null ? null : _toDouble(json['met']),
        variationGroup: (json['variationGroup'] ?? '').toString(),
        searchIndex: (json['searchIndex'] ?? '').toString(),
        deletedAtUtc: json['deletedAtUtc']?.toString(),
      );
}

/// A single exercise inside a program, with its own targets.
class ProgramExercise {
  const ProgramExercise({
    required this.name,
    required this.sets,
    required this.reps,
    required this.weightKg,
    this.exerciseId,
  });

  final String name;
  final int sets;
  final int reps;
  final double weightKg;
  final String? exerciseId;

  ProgramExercise copyWith({
    String? name,
    int? sets,
    int? reps,
    double? weightKg,
    String? exerciseId,
  }) {
    return ProgramExercise(
      name: name ?? this.name,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      weightKg: weightKg ?? this.weightKg,
      exerciseId: exerciseId ?? this.exerciseId,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'sets': sets,
        'reps': reps,
        'weightKg': weightKg,
        if (exerciseId != null) 'exerciseId': exerciseId,
      };

  factory ProgramExercise.fromJson(Map<String, dynamic> json) =>
      ProgramExercise(
        name: (json['name'] ?? '').toString(),
        sets: _toInt(json['sets'], 3),
        reps: _toInt(json['reps'], 10),
        weightKg: _toDouble(json['weightKg']),
        exerciseId: json['exerciseId']?.toString(),
      );
}

/// Training program. Mirrors `DEFAULT_PROGRAMS` entries.
class Program with RecordEnvelope {
  const Program({
    required this.id,
    required this.userId,
    required this.name,
    required this.splitGroup,
    required this.type,
    required this.duration,
    required this.frequency,
    required this.difficulty,
    required this.active,
    required this.exercises,
    required this.createdAtUtc,
    required this.updatedAtUtc,
    this.deletedAtUtc,
  });

  final String id;
  final String userId;
  final String name;
  final String splitGroup;
  final String type;
  final String duration;
  final String frequency;
  final String difficulty;
  final bool active;
  final List<ProgramExercise> exercises;
  final String createdAtUtc;
  final String updatedAtUtc;
  final String? deletedAtUtc;

  Program copyWith({
    String? name,
    String? splitGroup,
    String? type,
    String? duration,
    String? frequency,
    String? difficulty,
    bool? active,
    List<ProgramExercise>? exercises,
  }) {
    return Program(
      id: id,
      userId: userId,
      name: name ?? this.name,
      splitGroup: splitGroup ?? this.splitGroup,
      type: type ?? this.type,
      duration: duration ?? this.duration,
      frequency: frequency ?? this.frequency,
      difficulty: difficulty ?? this.difficulty,
      active: active ?? this.active,
      exercises: exercises ?? this.exercises,
      createdAtUtc: createdAtUtc,
      updatedAtUtc: _nowIso(),
      deletedAtUtc: deletedAtUtc,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'userId': userId,
        'name': name,
        'splitGroup': splitGroup,
        'type': type,
        'duration': duration,
        'frequency': frequency,
        'difficulty': difficulty,
        'active': active,
        'exercises': exercises.map((ProgramExercise e) => e.toJson()).toList(),
        'createdAtUtc': createdAtUtc,
        'updatedAtUtc': updatedAtUtc,
        'deletedAtUtc': deletedAtUtc,
      };

  factory Program.fromJson(Map<String, dynamic> json) => Program(
        id: (json['id'] ?? '').toString(),
        userId: (json['userId'] ?? 'u_alex_01').toString(),
        name: (json['name'] ?? 'Workout Program').toString(),
        splitGroup: (json['splitGroup'] ?? json['type'] ?? 'Custom').toString(),
        type: (json['type'] ?? 'Custom').toString(),
        duration: (json['duration'] ?? '30 min').toString(),
        frequency: (json['frequency'] ?? '3 days/wk').toString(),
        difficulty: (json['difficulty'] ?? 'Intermediate').toString(),
        active: json['active'] == true,
        exercises: _asMapList(json['exercises'])
            .map(ProgramExercise.fromJson)
            .toList(growable: false),
        createdAtUtc: (json['createdAtUtc'] ?? _nowIso()).toString(),
        updatedAtUtc: (json['updatedAtUtc'] ?? _nowIso()).toString(),
        deletedAtUtc: json['deletedAtUtc']?.toString(),
      );
}

/// One logged set inside a session. Mirrors `aw.sets[]` / `setsDetail[]`.
class LoggedSet with RecordEnvelope {
  const LoggedSet({
    required this.id,
    required this.userId,
    required this.exerciseName,
    required this.setNo,
    required this.exerciseSetNo,
    required this.weightKg,
    required this.reps,
    required this.restS,
    required this.inputMethod,
    required this.loggedAtUtc,
    required this.createdAtUtc,
    required this.updatedAtUtc,
    this.sessionId,
    this.deletedAtUtc,
  });

  final String id;
  final String userId;
  final String? sessionId;
  final String exerciseName;
  final int setNo;
  final int exerciseSetNo;
  final double weightKg;
  final int reps;
  final int restS;
  final String inputMethod;
  final String loggedAtUtc;
  final String createdAtUtc;
  final String updatedAtUtc;
  final String? deletedAtUtc;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'userId': userId,
        'sessionId': sessionId,
        'exerciseName': exerciseName,
        'setNo': setNo,
        'exerciseSetNo': exerciseSetNo,
        'weightKg': weightKg,
        'reps': reps,
        'restS': restS,
        'inputMethod': inputMethod,
        'loggedAtUtc': loggedAtUtc,
        'createdAtUtc': createdAtUtc,
        'updatedAtUtc': updatedAtUtc,
        'deletedAtUtc': deletedAtUtc,
      };

  factory LoggedSet.fromJson(Map<String, dynamic> json) {
    final String loggedAt =
        (json['loggedAtUtc'] ?? json['createdAtUtc'] ?? _nowIso()).toString();
    return LoggedSet(
      id: (json['id'] ?? '').toString(),
      userId: (json['userId'] ?? 'u_alex_01').toString(),
      sessionId: json['sessionId']?.toString(),
      exerciseName: (json['exerciseName'] ?? '').toString(),
      setNo: _toInt(json['setNo'], 1),
      exerciseSetNo: _toInt(json['exerciseSetNo'], 1),
      weightKg: _toDouble(json['weightKg']),
      reps: _toInt(json['reps'], 0),
      restS: _toInt(json['restS'], 0),
      inputMethod: (json['inputMethod'] ?? 'manual').toString(),
      loggedAtUtc: loggedAt,
      createdAtUtc: loggedAt,
      updatedAtUtc: loggedAt,
      deletedAtUtc: json['deletedAtUtc']?.toString(),
    );
  }
}

/// A finished workout. Mirrors `appState.history[]` entries.
class WorkoutSession with RecordEnvelope {
  const WorkoutSession({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.dateLabel,
    required this.dayOfMonth,
    required this.startedAtUtc,
    required this.durationMin,
    required this.reps,
    required this.volume,
    required this.setsCount,
    required this.methods,
    required this.setsDetail,
    required this.createdAtUtc,
    required this.updatedAtUtc,
    this.children = const <WorkoutSession>[],
    this.deletedAtUtc,
  });

  /// `full` | `micro` | `stitched`.
  final String id;
  final String userId;
  final String name;
  final String type;
  final String dateLabel;
  final int dayOfMonth;
  final String startedAtUtc;
  final int durationMin;
  final int reps;
  final double volume;
  final int setsCount;
  final List<String> methods;
  final List<LoggedSet> setsDetail;
  final List<WorkoutSession> children;
  final String createdAtUtc;
  final String updatedAtUtc;
  final String? deletedAtUtc;

  bool get isStitched => type == 'stitched';
  bool get isMicro => type == 'micro';

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'userId': userId,
        'name': name,
        'type': type,
        'dateLabel': dateLabel,
        'dayOfMonth': dayOfMonth,
        'startedAtUtc': startedAtUtc,
        'durationMin': durationMin,
        'reps': reps,
        'volume': volume,
        'setsCount': setsCount,
        'methods': methods,
        'setsDetail': setsDetail.map((LoggedSet s) => s.toJson()).toList(),
        'children': children.map((WorkoutSession s) => s.toJson()).toList(),
        'createdAtUtc': createdAtUtc,
        'updatedAtUtc': updatedAtUtc,
        'deletedAtUtc': deletedAtUtc,
      };

  factory WorkoutSession.fromJson(Map<String, dynamic> json) => WorkoutSession(
        id: (json['id'] ?? '').toString(),
        userId: (json['userId'] ?? 'u_alex_01').toString(),
        name: (json['name'] ?? 'Workout').toString(),
        type: (json['type'] ?? 'full').toString(),
        dateLabel: (json['dateLabel'] ?? '').toString(),
        dayOfMonth: _toInt(json['dayOfMonth'], 1),
        startedAtUtc: (json['startedAtUtc'] ?? _nowIso()).toString(),
        durationMin: _toInt(json['durationMin'], 0),
        reps: _toInt(json['reps'], 0),
        volume: _toDouble(json['volume']),
        setsCount: _toInt(json['setsCount'], 0),
        methods: (json['methods'] as List<dynamic>? ?? const <dynamic>[])
            .map((dynamic e) => e.toString())
            .toList(growable: false),
        setsDetail: _asMapList(json['setsDetail'])
            .map(LoggedSet.fromJson)
            .toList(growable: false),
        children: _asMapList(json['children'])
            .map(WorkoutSession.fromJson)
            .toList(growable: false),
        createdAtUtc: (json['createdAtUtc'] ?? _nowIso()).toString(),
        updatedAtUtc: (json['updatedAtUtc'] ?? _nowIso()).toString(),
        deletedAtUtc: json['deletedAtUtc']?.toString(),
      );
}

/// The workout in progress. Mirrors `appState.activeWorkout`.
class ActiveWorkout {
  const ActiveWorkout({
    required this.programId,
    required this.sessionName,
    required this.sessionType,
    required this.exercises,
    required this.currentExercise,
    required this.weightInput,
    required this.repsInput,
    required this.inputMethod,
    required this.restTotalSeconds,
    required this.restSeconds,
    required this.sets,
    this.voiceSimText = 'add 10 reps',
    this.voiceHistory = const <String>[],
  });

  final String programId;
  final String sessionName;
  final String sessionType;
  final List<ProgramExercise> exercises;
  final String currentExercise;
  final String weightInput;
  final int repsInput;
  final String inputMethod;
  final int restTotalSeconds;
  final int restSeconds;
  final List<LoggedSet> sets;
  final String voiceSimText;

  /// The last few commands the user actually sent, newest first. Shown as
  /// one-tap chips under the microphone so a repeated command costs no typing.
  final List<String> voiceHistory;

  ActiveWorkout copyWith({
    String? programId,
    String? sessionName,
    String? sessionType,
    List<ProgramExercise>? exercises,
    String? currentExercise,
    String? weightInput,
    int? repsInput,
    String? inputMethod,
    int? restTotalSeconds,
    int? restSeconds,
    List<LoggedSet>? sets,
    String? voiceSimText,
    List<String>? voiceHistory,
  }) {
    return ActiveWorkout(
      programId: programId ?? this.programId,
      sessionName: sessionName ?? this.sessionName,
      sessionType: sessionType ?? this.sessionType,
      exercises: exercises ?? this.exercises,
      currentExercise: currentExercise ?? this.currentExercise,
      weightInput: weightInput ?? this.weightInput,
      repsInput: repsInput ?? this.repsInput,
      inputMethod: inputMethod ?? this.inputMethod,
      restTotalSeconds: restTotalSeconds ?? this.restTotalSeconds,
      restSeconds: restSeconds ?? this.restSeconds,
      sets: sets ?? this.sets,
      voiceSimText: voiceSimText ?? this.voiceSimText,
      voiceHistory: voiceHistory ?? this.voiceHistory,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'programId': programId,
        'sessionName': sessionName,
        'sessionType': sessionType,
        'exercises': exercises.map((ProgramExercise e) => e.toJson()).toList(),
        'currentExercise': currentExercise,
        'weightInput': weightInput,
        'repsInput': repsInput,
        'inputMethod': inputMethod,
        'restTotalSeconds': restTotalSeconds,
        'restSeconds': restSeconds,
        'sets': sets.map((LoggedSet s) => s.toJson()).toList(),
        'voiceSimText': voiceSimText,
        'voiceHistory': voiceHistory,
      };

  factory ActiveWorkout.fromJson(Map<String, dynamic> json) {
    final int total = _toInt(json['restTotalSeconds'], 120);
    return ActiveWorkout(
      programId: (json['programId'] ?? '').toString(),
      sessionName: (json['sessionName'] ?? '').toString(),
      sessionType: json['sessionType'] == 'micro' ? 'micro' : 'full',
      exercises: _asMapList(json['exercises'])
          .map(ProgramExercise.fromJson)
          .toList(growable: false),
      currentExercise: (json['currentExercise'] ?? '').toString(),
      weightInput: (json['weightInput'] ?? '0').toString(),
      repsInput: _toInt(json['repsInput'], 0),
      inputMethod: (json['inputMethod'] ?? 'manual').toString(),
      restTotalSeconds: total,
      restSeconds: _toInt(json['restSeconds'], total),
      sets: _asMapList(json['sets'])
          .map(LoggedSet.fromJson)
          .toList(growable: false),
      voiceSimText: (json['voiceSimText'] ?? 'add 10 reps').toString(),
      voiceHistory: _asStringList(json['voiceHistory']),
    );
  }
}

/// Summary of the workout that was just finished.
class WorkoutSummary {
  const WorkoutSummary({
    required this.name,
    required this.type,
    required this.durationMin,
    required this.totalSets,
    required this.totalReps,
    required this.totalVolume,
    required this.methods,
    this.durationSec = 0,
  });

  final String name;
  final String type;
  final int durationMin;

  /// The exact duration in seconds (`mm:ss` on the summary screen).
  final int durationSec;
  final int totalSets;
  final int totalReps;
  final double totalVolume;
  final List<String> methods;
}

/// A quiz question, ported from `QUIZ_QUESTIONS_FULL`.
class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.text,
    required this.options,
  });

  final String id;
  final String text;
  final List<String> options;
}

/// Result of the quiz rule table (`getComputedQuizAdjustment`).
class QuizAdjustment {
  const QuizAdjustment({
    required this.factor,
    required this.pctText,
    required this.intensityLabel,
    required this.sessionLength,
    required this.frequency,
  });

  final double factor;
  final String pctText;
  final String intensityLabel;
  final String sessionLength;
  final String frequency;

  /// Whether the rule table left the load untouched.
  bool get isUnchanged => factor == 1;
}

/// A workout the user planned from the Home calendar.
///
/// The reminder itself lives in the operating system's alarm list; this record
/// only tracks what is planned so the calendar and the "Up next" card can show
/// it and so a reminder can be cancelled or re-armed.
class ScheduledWorkout with RecordEnvelope {
  const ScheduledWorkout({
    required this.id,
    required this.userId,
    required this.programId,
    required this.programName,
    required this.year,
    required this.month,
    required this.day,
    required this.hour,
    required this.minute,
    required this.createdAtUtc,
    required this.updatedAtUtc,
    this.deletedAtUtc,
  });

  final String id;
  final String userId;
  final String programId;
  final String programName;

  /// The planned local wall-clock time.
  final int year;
  final int month;
  final int day;
  final int hour;
  final int minute;

  final String createdAtUtc;
  final String updatedAtUtc;
  final String? deletedAtUtc;

  /// The planned local date and time.
  DateTime get dateTime => DateTime(year, month, day, hour, minute);

  /// Whether the planned time has already passed.
  bool get isPast => !dateTime.isAfter(DateTime.now());

  /// Whether the workout is planned for [day] of the same month and year.
  bool isOn(DateTime day) =>
      year == day.year && month == day.month && this.day == day.day;

  ScheduledWorkout copyWith({
    String? programId,
    String? programName,
    int? hour,
    int? minute,
  }) {
    return ScheduledWorkout(
      id: id,
      userId: userId,
      programId: programId ?? this.programId,
      programName: programName ?? this.programName,
      year: year,
      month: month,
      day: day,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      createdAtUtc: createdAtUtc,
      updatedAtUtc: _nowIso(),
      deletedAtUtc: deletedAtUtc,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'userId': userId,
        'programId': programId,
        'programName': programName,
        'year': year,
        'month': month,
        'day': day,
        'hour': hour,
        'minute': minute,
        'createdAtUtc': createdAtUtc,
        'updatedAtUtc': updatedAtUtc,
        if (deletedAtUtc != null) 'deletedAtUtc': deletedAtUtc,
      };

  factory ScheduledWorkout.fromJson(Map<String, dynamic> json) =>
      ScheduledWorkout(
        id: (json['id'] ?? '').toString(),
        userId: (json['userId'] ?? '').toString(),
        programId: (json['programId'] ?? '').toString(),
        programName: (json['programName'] ?? '').toString(),
        year: _toInt(json['year'], 0),
        month: _toInt(json['month'], 1),
        day: _toInt(json['day'], 1),
        hour: _toInt(json['hour'], 0),
        minute: _toInt(json['minute'], 0),
        createdAtUtc: (json['createdAtUtc'] ?? '').toString(),
        updatedAtUtc: (json['updatedAtUtc'] ?? '').toString(),
        deletedAtUtc: json['deletedAtUtc']?.toString(),
      );
}

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

int _toInt(dynamic value, int fallback) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? fallback;
}

List<Map<String, dynamic>> _asMapList(dynamic value) {
  if (value is! List) return const <Map<String, dynamic>>[];
  return value
      .whereType<Map<dynamic, dynamic>>()
      .map((Map<dynamic, dynamic> e) => e.cast<String, dynamic>())
      .toList(growable: false);
}

List<String> _asStringList(dynamic value) {
  if (value is! List) return const <String>[];
  return value
      .map((dynamic e) => e.toString())
      .where((String e) => e.isNotEmpty)
      .toList(growable: false);
}

Map<String, dynamic> _asStringMap(dynamic value) {
  if (value is! Map) return const <String, dynamic>{};
  return value
      .map((dynamic key, dynamic e) => MapEntry<String, dynamic>(
            key.toString(),
            e,
          ))
      .cast<String, dynamic>();
}
