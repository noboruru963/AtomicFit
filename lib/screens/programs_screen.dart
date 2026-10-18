import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../texts/app_texts.dart';
import '../models/app_models.dart';

class ProgramsScreen extends StatefulWidget {
  const ProgramsScreen({super.key});

  @override
  State<ProgramsScreen> createState() => _ProgramsScreenState();
}

class _ProgramsScreenState extends State<ProgramsScreen> {
  String? _currentProgramId;

  final List<Program> programs = [
    Program(id: 'p1', name: 'Upper Lower', type: 'Built-in', exercises: ['Bench press', 'Dumbbell curl', 'Chest press', 'Tricep raise'], sets: 3, weight: 10, rest: '2:00'),
    Program(id: 'p2', name: 'Push Pull Leg', type: 'Built-in', exercises: ['Dumbbell curl', 'Chest press', 'Tricep raise', 'Lateral pushdown'], sets: 3, weight: 10, rest: '2:00', isCurrent: true),
    Program(id: 'p3', name: 'Gorilla Training', type: 'Built-in', exercises: ['Dumbbell shoulder press', 'Inverted plank', 'Barbell shoulder press'], sets: 3, weight: 12, rest: '2:00'),
  ];

  @override
  void initState() {
    super.initState();
    _currentProgramId = 'p2';
  }

  Widget _buildProgramCard(Program prog) {
    final isCurrent = _currentProgramId == prog.id;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(prog.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textLight)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(prog.type, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: AppTheme.primary)),
                        ),
                        if (isCurrent) const SizedBox(width: 8),
                        if (isCurrent)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.success,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('Current', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(prog.exercises.join(' · '), style: TextStyle(fontSize: 12, color: AppTheme.mutedLight)),
                    const SizedBox(height: 6),
                    Text('${prog.sets} sets × ${prog.weight} kg · rest ${prog.rest}', style: TextStyle(fontSize: 12, color: AppTheme.mutedLight)),
                  ],
                ),
              ),
              Column(
                children: [
                  SizedBox(
                    width: 200,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() => _currentProgramId = prog.id);
                        Navigator.pushReplacementNamed(context, '/workout/active');
                      },
                      child: const Text(AppTexts.continueBtn, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                  ),
                  if (!isCurrent) const SizedBox(height: 8),
                  if (!isCurrent)
                    SizedBox(
                      width: 200,
                      height: 40,
                      child: OutlinedButton(
                        onPressed: () => setState(() => _currentProgramId = prog.id),
                        child: const Text('Set current', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                    Text(AppTexts.programsTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textLight)),
                    const SizedBox(height: 20),
                    ...programs.map((prog) => _buildProgramCard(prog)).toList(),
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
          IconButton(icon: const Icon(Icons.notifications_none, color: Colors.white), onPressed: null),
        ],
      ),
    );
  }
}
