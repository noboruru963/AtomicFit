import 'package:flutter/material.dart';
import 'dart:async';
import '../theme/app_theme.dart';
import '../texts/app_texts.dart';
import '../models/app_models.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  String? _currentExercise;
  int _reps = 0;
  String _weightInput = '';
  int _restSeconds = 120;
  bool _restRunning = false;
  Timer? _restTimer;

  final List<Map<String, dynamic>> _exercises = [
    {'id': 'e1', 'name': 'Dumbbell curl', 'sets': 3},
    {'id': 'e2', 'name': 'Chest press', 'sets': 3},
    {'id': 'e3', 'name': 'Tricep raise', 'sets': 3},
  ];

  final List<Map<String, dynamic>> _sets = [];

  @override
  void initState() {
    super.initState();
    _currentExercise = _exercises.first['name'];
    _addSet();
  }

  @override
  void dispose() {
    _restTimer?.cancel();
    super.dispose();
  }

  void _addSet() {
    final ex = _exercises.firstWhere((e) => e['name'] == _currentExercise);
    final prev = _sets.isNotEmpty ? _sets.last : null;
    setState(() {
      _sets.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'exerciseId': ex['id'],
        'exerciseName': ex['name'],
        'setNo': _sets.where((s) => s['exerciseId'] == ex['id']).length + 1,
        'weightKg': prev?['weightKg'] ?? 0,
        'reps': 0,
        'restS': prev?['restS'] ?? 120,
      });
    });
  }

  void _incrementReps(Map<String, dynamic> set) {
    setState(() => set['reps'] = set['reps'] + 1);
  }

  void _decrementReps(Map<String, dynamic> set) {
    setState(() => set['reps'] = set['reps'] > 0 ? set['reps'] - 1 : 0);
  }

  void _quickAddRep() {
    if (_sets.isNotEmpty) {
      setState(() => _sets.last['reps'] = (_sets.last['reps'] as int) + 1);
    }
  }

  void _quickAddSet() {
    _addSet();
  }

  void _startRest() => setState(() => _restRunning = true);
  void _pauseRest() => setState(() => _restRunning = false);
  void _skipRest() => setState(() {
    _restRunning = false;
    _restSeconds = 0;
  });
  void _adjustRest(int delta) => setState(() => _restSeconds = (_restSeconds + delta).clamp(15, 999));

  void _showAddExerciseDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController weightController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Exercise'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Exercise name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: weightController,
              decoration: const InputDecoration(
                labelText: 'Weight (kg)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              final weight = double.tryParse(weightController.text) ?? 0;
              setState(() {
                _currentExercise = name;
                _sets.add({
                  'id': DateTime.now().millisecondsSinceEpoch.toString(),
                  'exerciseId': 'manual-${DateTime.now().millisecondsSinceEpoch}',
                  'exerciseName': name,
                  'setNo': 1,
                  'weightKg': weight,
                  'reps': 0,
                  'restS': 120,
                });
              });
              Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ex = _exercises.firstWhere((e) => e['name'] == _currentExercise, orElse: () => {'id': 'custom', 'name': _currentExercise ?? '', 'sets': 3});
    final totalSetsDone = _sets.where((s) => s['reps'] >= 1).length;

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Exercise name header
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _currentExercise ?? '',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textLight),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Sets list
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.cardLight,
                        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                        border: Border.all(color: AppTheme.lineLight),
                      ),
                      child: Column(
                        children: [
                          ..._sets.map((s) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppTheme.bgLight,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.lineLight),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Set ${s['setNo']}',
                                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.mutedLight),
                                      ),
                                      GestureDetector(
                                        onTap: () => setState(() => _sets.remove(s)),
                                        child: const Text('×', style: TextStyle(fontSize: 18, color: AppTheme.mutedLight)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  // Reps input
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          decoration: InputDecoration(
                                            labelText: 'Reps',
                                            hintText: '0',
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                          ),
                                          keyboardType: TextInputType.number,
                                          onChanged: (v) => s['reps'] = int.tryParse(v) ?? 0,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Container(
                                        width: 44,
                                        height: 44,
                                        child: ElevatedButton(
                                          onPressed: () => _decrementReps(s),
                                          child: const Text('-', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppTheme.mutedLight,
                                            foregroundColor: AppTheme.textLight,
                                            padding: EdgeInsets.zero,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        width: 44,
                                        height: 44,
                                        child: ElevatedButton(
                                          onPressed: () => _incrementReps(s),
                                          child: const Text('+', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppTheme.primary,
                                            foregroundColor: Colors.white,
                                            padding: EdgeInsets.zero,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  // Weight input
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextField(
                                          decoration: InputDecoration(
                                            labelText: 'Weight (kg)',
                                            hintText: '0',
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                                          ),
                                          keyboardType: TextInputType.number,
                                          onChanged: (v) => s['weightKg'] = double.tryParse(v) ?? 0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          if (_sets.isEmpty)
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(24),
                                child: Text('No sets yet. Add a set to begin.', style: TextStyle(fontSize: 12, color: AppTheme.mutedLight)),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Add set / Add exercise buttons
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _addSet,
                              child: const Text(AppTexts.addSet, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: OutlinedButton(
                              onPressed: _showAddExerciseDialog,
                              child: const Text(AppTexts.addExercise, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Quick add rep / set
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.cardLight,
                        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                        border: Border.all(color: AppTheme.lineLight),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Quick add', style: TextStyle(fontSize: 12, color: AppTheme.mutedLight)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 70,
                                    height: 40,
                                    child: ElevatedButton(
                                      onPressed: _quickAddRep,
                                      child: const Text('+1 rep', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 70,
                                    height: 40,
                                    child: ElevatedButton(
                                      onPressed: _quickAddSet,
                                      child: const Text('+1 set', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Text('$totalSetsDone sets logged', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textLight)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Rest timer
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.cardLight,
                        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
                        border: Border.all(color: AppTheme.lineLight),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(AppTexts.restTimerTitle, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textLight)),
                              Text(
                                '${(_restSeconds ~/ 60).toString().padLeft(2, '0')}:${(_restSeconds % 60).toString().padLeft(2, '0')}',
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.primary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              SizedBox(
                                width: 60,
                                height: 36,
                                child: OutlinedButton(
                                  onPressed: () => _adjustRest(-15),
                                  child: const Text('-15 s', style: TextStyle(fontSize: 10)),
                                  style: OutlinedButton.styleFrom(padding: EdgeInsets.zero),
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 60,
                                height: 36,
                                child: OutlinedButton(
                                  onPressed: () => _adjustRest(15),
                                  child: const Text('+15 s', style: TextStyle(fontSize: 10)),
                                  style: OutlinedButton.styleFrom(padding: EdgeInsets.zero),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: SizedBox(
                                  height: 36,
                                  child: ElevatedButton(
                                    onPressed: _restRunning ? _pauseRest : _startRest,
                                    child: Text(_restRunning ? AppTexts.pause : AppTexts.setTimer, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _restRunning ? AppTheme.mutedLight : AppTheme.primary,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              TextButton(
                                onPressed: _skipRest,
                                child: Text(AppTexts.skip, style: TextStyle(fontSize: 12, color: AppTheme.primary)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text('Cancel before start · vibrate 300 ms at 0:00 where supported', style: TextStyle(fontSize: 10, color: AppTheme.mutedLight)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Finish button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pushReplacementNamed(
                          context,
                          '/workout/complete',
                          arguments: {'totalSets': totalSetsDone},
                        ),
                        child: const Text(AppTexts.finish, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [AppTheme.primary, AppTheme.primaryDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(14)),
            child: const Center(child: Text('AF', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800))),
          ),
          const SizedBox(width: 12),
          const Text('AtomFit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
          const Spacer(),
          IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        ],
      ),
    );
  }
}
