import 'package:intl/intl.dart';

import '../models/app_models.dart';

/// Seed data ported verbatim from the web prototype
/// (`index.html` lines 453-665).
///
/// The only intentional difference: demo session timestamps are generated
/// relative to "now" instead of being pinned to literal dates, so the calendar
/// and the monthly count always reflect real data.
class SeedData {
  const SeedData._();

  static const String userId = 'u_alex_01';

  // ------------------------------------------------------------- quiz (453)
  static const List<QuizQuestion> quizQuestions = <QuizQuestion>[
    QuizQuestion(
      id: 'q1',
      text: 'What is your current fitness target?',
      options: <String>[
        'Muscle gain',
        'Staying healthy',
        'Look fit',
        'No target'
      ],
    ),
    QuizQuestion(
      id: 'q2',
      text: 'How is your energy today?',
      options: <String>['High', 'Normal', 'Low'],
    ),
    QuizQuestion(
      id: 'q3',
      text: 'How motivated do you feel to train?',
      options: <String>['High', 'Normal', 'Low'],
    ),
    QuizQuestion(
      id: 'q4',
      text: 'How many days per week can you train?',
      options: <String>['1-2', '3-4', '5+'],
    ),
    QuizQuestion(
      id: 'q5',
      text: 'How long are your usual sessions?',
      options: <String>['<30 min', '30-60 min', '>60 min'],
    ),
    QuizQuestion(
      id: 'q6',
      text: 'Have real-life interruptions cut sessions short lately?',
      options: <String>['Yes', 'No', 'Prefer micro-workouts'],
    ),
    QuizQuestion(
      id: 'q7',
      text: 'How confident do you feel with your current program?',
      options: <String>['High', 'Normal', 'Low'],
    ),
    QuizQuestion(
      id: 'q8',
      text: 'What matters most right now?',
      options: <String>[
        'Strength',
        'Consistency',
        'Mobility',
        'General health'
      ],
    ),
    QuizQuestion(
      id: 'q9',
      text: 'How ready are you to resume your usual load?',
      options: <String>['Ready', 'Ease in', 'Not sure'],
    ),
    QuizQuestion(
      id: 'q10',
      text: 'Do you still want to push?',
      options: <String>[
        'Yes, progress the weight',
        'No, same program as last',
        'No, reduced intensity',
      ],
    ),
  ];

  // -------------------------------------------------------- catalogue (466)
  static List<Exercise> catalogue(DateTime now) {
    final String ts = now.toUtc().toIso8601String();
    Exercise make(
      String id,
      String name,
      String category,
      double kg,
      int reps,
      String description,
    ) {
      return Exercise(
        id: id,
        userId: userId,
        name: name,
        category: category,
        defaultKg: kg,
        defaultReps: reps,
        defaultSets: 3,
        description: description,
        isCustom: false,
        createdAtUtc: ts,
        updatedAtUtc: ts,
      );
    }

    return <Exercise>[
      make('cat1', 'Barbell shoulder press', 'Shoulders', 30, 8,
          'Overhead press with a barbell targeting anterior deltoids and triceps.'),
      make('cat2', 'Dumbbell shoulder press', 'Shoulders', 16, 10,
          'Seated or standing dumbbell press for balanced shoulder stability.'),
      make('cat3', 'Inverted plank', 'Core', 0, 15,
          'Reverse plank targeting posterior chain, glutes, and core.'),
      make('cat4', 'Dumbbell curl', 'Arms', 15, 10,
          'Bicep curl with dumbbells for isolated elbow flexion.'),
      make('cat5', 'Chest press', 'Chest', 22.5, 8,
          'Bench or floor chest press for pectorals and anterior delts.'),
      make('cat6', 'Tricep raise', 'Arms', 12, 10,
          'Overhead triceps extension for long-head tricep development.'),
      make('cat7', 'Lateral pushdown', 'Arms', 18, 12,
          'Cable or band lateral pushdown for triceps and lats.'),
      make('cat8', 'Bench press', 'Chest', 40, 8,
          'Compound barbell chest press.'),
      make('cat9', 'Inverted row', 'Back', 0, 12,
          'Bodyweight horizontal pulling exercise for upper back.'),
      make('cat10', 'Barbell squat', 'Legs', 60, 8,
          'Compound barbell back squat targeting quadriceps, glutes, and core.'),
      make('cat11', 'Romanian deadlift', 'Legs', 50, 10,
          'Hip-hinge barbell lift targeting hamstrings, glutes, and lower back.'),
      make('cat12', 'Walking lunges', 'Legs', 16, 12,
          'Unilateral dumbbell lunge for quad, glute, and balance development.'),
      make('cat13', 'Standing calf raise', 'Legs', 40, 15,
          'Weighted calf raise targeting gastrocnemius and soleus.'),
    ];
  }

  // ---------------------------------------------------------- programs (482)
  static List<Program> programs(DateTime now) {
    final String ts = now.toUtc().toIso8601String();
    Program make(
      String id,
      String name,
      String splitGroup,
      String type,
      String duration,
      String frequency,
      String difficulty,
      bool active,
      List<ProgramExercise> exercises,
    ) {
      return Program(
        id: id,
        userId: userId,
        name: name,
        splitGroup: splitGroup,
        type: type,
        duration: duration,
        frequency: frequency,
        difficulty: difficulty,
        active: active,
        exercises: exercises,
        createdAtUtc: ts,
        updatedAtUtc: ts,
      );
    }

    ProgramExercise ex(
      String name,
      int sets,
      int reps,
      double weightKg,
    ) =>
        ProgramExercise(name: name, sets: sets, reps: reps, weightKg: weightKg);

    return <Program>[
      make(
        'p_push',
        'Push Day',
        'Push Pull Leg',
        'Built-in',
        '35 min',
        'PPL Split • Day 1',
        'Intermediate',
        true,
        <ProgramExercise>[
          ex('Chest press', 3, 8, 22.5),
          ex('Dumbbell shoulder press', 3, 10, 16),
          ex('Tricep raise', 3, 10, 12),
          ex('Lateral pushdown', 3, 12, 18),
        ],
      ),
      make(
        'p_pull',
        'Pull Day',
        'Push Pull Leg',
        'Built-in',
        '35 min',
        'PPL Split • Day 2',
        'Intermediate',
        false,
        <ProgramExercise>[
          ex('Inverted row', 4, 12, 0),
          ex('Dumbbell curl', 3, 10, 15),
          ex('Inverted plank', 3, 15, 0),
        ],
      ),
      make(
        'p_leg',
        'Leg Day',
        'Push Pull Leg',
        'Built-in',
        '40 min',
        'PPL Split • Day 3',
        'Intermediate',
        false,
        <ProgramExercise>[
          ex('Barbell squat', 4, 8, 60),
          ex('Romanian deadlift', 3, 10, 50),
          ex('Walking lunges', 3, 12, 16),
          ex('Standing calf raise', 4, 15, 40),
        ],
      ),
      make(
        'p_upper',
        'Upper Day',
        'Upper Lower',
        'Built-in',
        '45 min',
        'Upper/Lower • Day 1',
        'Intermediate',
        false,
        <ProgramExercise>[
          ex('Bench press', 3, 8, 40),
          ex('Inverted row', 3, 12, 0),
          ex('Barbell shoulder press', 3, 8, 30),
          ex('Dumbbell curl', 3, 10, 15),
        ],
      ),
      make(
        'p_lower',
        'Lower Day',
        'Upper Lower',
        'Built-in',
        '45 min',
        'Upper/Lower • Day 2',
        'Intermediate',
        false,
        <ProgramExercise>[
          ex('Barbell squat', 4, 8, 60),
          ex('Romanian deadlift', 3, 10, 50),
          ex('Walking lunges', 3, 12, 16),
          ex('Inverted plank', 3, 15, 0),
        ],
      ),
      make(
        'p3',
        'Gorilla Training',
        'Built-in',
        'Built-in',
        '30 min',
        '3 days/wk',
        'Advanced',
        false,
        <ProgramExercise>[
          ex('Dumbbell shoulder press', 4, 10, 18),
          ex('Inverted row', 4, 12, 0),
        ],
      ),
      make(
        'p4',
        '5-Minute Micro Sets',
        'Micro',
        'Micro',
        '5 min',
        'Daily',
        'All Levels',
        false,
        <ProgramExercise>[
          ex('Dumbbell curl', 2, 10, 12),
          ex('Inverted plank', 2, 15, 0),
        ],
      ),
    ];
  }

  // ------------------------------------------------------------ history (592)
  static List<WorkoutSession> history(DateTime now) {
    final DateFormat label = DateFormat('MMM d, HH:mm');
    final DateFormat iso = DateFormat('yyyy-MM-ddTHH:mm:ss');

    WorkoutSession make({
      required String id,
      required String name,
      required String type,
      required DateTime at,
      required int durationMin,
      required int reps,
      required double volume,
      required int setsCount,
      required List<String> methods,
      required List<LoggedSet> sets,
      List<WorkoutSession> children = const <WorkoutSession>[],
    }) {
      final String created = iso.format(at.toUtc());
      return WorkoutSession(
        id: id,
        userId: userId,
        name: name,
        type: type,
        dateLabel: label.format(at),
        dayOfMonth: at.day,
        startedAtUtc: created,
        durationMin: durationMin,
        reps: reps,
        volume: volume,
        setsCount: setsCount,
        methods: methods,
        setsDetail: sets,
        children: children,
        createdAtUtc: created,
        updatedAtUtc: created,
      );
    }

    LoggedSet set(
      String id,
      String exercise,
      int no,
      double kg,
      int reps,
      String method,
      DateTime at,
    ) {
      final String created = iso.format(at.toUtc());
      return LoggedSet(
        id: id,
        userId: userId,
        exerciseName: exercise,
        setNo: no,
        exerciseSetNo: no,
        weightKg: kg,
        reps: reps,
        restS: 120,
        inputMethod: method,
        loggedAtUtc: created,
        createdAtUtc: created,
        updatedAtUtc: created,
      );
    }

    final DateTime d1 = now.subtract(const Duration(days: 2, hours: 3));
    final DateTime d2 = now.subtract(const Duration(days: 3, hours: 8));
    final DateTime d3 = now.subtract(const Duration(days: 5, hours: 2));
    final DateTime d4 = now.subtract(const Duration(days: 8, hours: 5));

    final WorkoutSession upperMorning = make(
      id: 's3_a',
      name: 'Upper Day (Morning Micro)',
      type: 'micro',
      at: d3.subtract(const Duration(hours: 11)),
      durationMin: 12,
      reps: 20,
      volume: 400,
      setsCount: 2,
      methods: const <String>['manual'],
      sets: <LoggedSet>[
        set('s3_a1', 'Bench press', 1, 20, 10, 'manual', d3),
        set('s3_a2', 'Bench press', 2, 20, 10, 'manual', d3),
      ],
    );

    final WorkoutSession upperEvening = make(
      id: 's3_b',
      name: 'Upper Day (Evening Micro)',
      type: 'micro',
      at: d3,
      durationMin: 16,
      reps: 25,
      volume: 500,
      setsCount: 2,
      methods: const <String>['voice'],
      sets: <LoggedSet>[
        set('s3_b1', 'Dumbbell curl', 1, 20, 12, 'voice', d3),
        set('s3_b2', 'Barbell shoulder press', 2, 20, 13, 'voice', d3),
      ],
    );

    return <WorkoutSession>[
      make(
        id: 's1',
        name: 'Push Day',
        type: 'full',
        at: d1,
        durationMin: 32,
        reps: 30,
        volume: 605,
        setsCount: 3,
        methods: const <String>['manual', 'sensor'],
        sets: <LoggedSet>[
          set('s1_1', 'Chest press', 1, 22.5, 10, 'manual', d1),
          set('s1_2', 'Dumbbell shoulder press', 2, 16, 10, 'sensor', d1),
          set('s1_3', 'Tricep raise', 3, 12, 10, 'manual', d1),
        ],
      ),
      make(
        id: 's2',
        name: 'Pull Day (Quick Micro)',
        type: 'micro',
        at: d2,
        durationMin: 6,
        reps: 20,
        volume: 300,
        setsCount: 2,
        methods: const <String>['lockscreen'],
        sets: <LoggedSet>[
          set('s2_1', 'Dumbbell curl', 1, 15, 10, 'lockscreen', d2),
          set('s2_2', 'Dumbbell curl', 2, 15, 10, 'lockscreen', d2),
        ],
      ),
      make(
        id: 's3',
        name: 'Upper Day',
        type: 'stitched',
        at: d3,
        durationMin: 28,
        reps: 45,
        volume: 900,
        setsCount: 4,
        methods: const <String>['manual', 'voice'],
        sets: <LoggedSet>[
          set('s3_1', 'Bench press', 1, 20, 10, 'manual', d3),
          set('s3_2', 'Bench press', 2, 20, 10, 'manual', d3),
          set('s3_3', 'Dumbbell curl', 3, 20, 12, 'voice', d3),
          set('s3_4', 'Barbell shoulder press', 4, 20, 13, 'voice', d3),
        ],
        children: <WorkoutSession>[upperMorning, upperEvening],
      ),
      make(
        id: 's4',
        name: 'Leg Day',
        type: 'full',
        at: d4,
        durationMin: 38,
        reps: 28,
        volume: 1480,
        setsCount: 3,
        methods: const <String>['manual'],
        sets: <LoggedSet>[
          set('s4_1', 'Barbell squat', 1, 60, 8, 'manual', d4),
          set('s4_2', 'Romanian deadlift', 2, 50, 10, 'manual', d4),
          set('s4_3', 'Romanian deadlift', 3, 50, 10, 'manual', d4),
        ],
      ),
    ];
  }
}
