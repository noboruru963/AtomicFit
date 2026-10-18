import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../texts/app_texts.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  String _search = '';
  final Set<String> _added = {};

  final List<Map<String, String>> _catalogue = [
    {'id': 'e1', 'name': 'Barbell shoulder press', 'desc': 'Overhead press with a barbell.'},
    {'id': 'e2', 'name': 'Dumbbell shoulder press', 'desc': 'Seated or standing dumbbell press.'},
    {'id': 'e3', 'name': 'Inverted plank', 'desc': 'Reverse plank targeting posterior chain.'},
    {'id': 'e4', 'name': 'Dumbbell curl', 'desc': 'Bicep curl with dumbbells.'},
    {'id': 'e5', 'name': 'Chest press', 'desc': 'Bench or floor chest press.'},
    {'id': 'e6', 'name': 'Tricep raise', 'desc': 'Triceps extension.'},
    {'id': 'e7', 'name': 'Lateral pushdown', 'desc': 'Cable or band lateral pushdown.'},
  ];

  // Programs available for adding exercises
  final List<Map<String, dynamic>> _programs = [
    {'id': 'p1', 'name': 'Upper Lower'},
    {'id': 'p2', 'name': 'Push Pull Leg'},
    {'id': 'p3', 'name': 'Gorilla Training'},
  ];

  Widget _buildExerciseCard(Map<String, String> ex) {
    final isAdded = _added.contains(ex['id']);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusCard),
        border: Border.all(color: AppTheme.lineLight),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ex['name']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textLight)),
                const SizedBox(height: 4),
                Text(ex['desc']!, style: TextStyle(fontSize: 11, color: AppTheme.mutedLight)),
              ],
            ),
          ),
          SizedBox(
            height: 36,
            child: ElevatedButton(
              onPressed: isAdded ? null : () => _showAddToProgramDialog(ex['id']!, ex['name']!),
              style: ElevatedButton.styleFrom(
                backgroundColor: isAdded ? AppTheme.mutedLight : AppTheme.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(isAdded ? 'Added' : AppTexts.addButton, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddToProgramDialog(String exerciseId, String exerciseName) {
    String? selectedProgramId;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add to Program'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Which program would you like to add this exercise to?', style: TextStyle(fontSize: 13)),
            const SizedBox(height: 16),
            ..._programs.map((prog) => RadioListTile<String>(
              title: Text(prog['name'], style: const TextStyle(fontSize: 14)),
              value: prog['id'],
              groupValue: selectedProgramId,
              onChanged: (val) => setState(() => selectedProgramId = val),
              dense: true,
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (selectedProgramId == null) return;
              setState(() => _added.add(exerciseId));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$exerciseName added to ${_programs.firstWhere((p) => p['id'] == selectedProgramId)['name']}')),
              );
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
    final filtered = _catalogue.where((e) => e['name']!.toLowerCase().contains(_search.toLowerCase())).toList();

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
                    Text(AppTexts.discoverTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textLight)),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        labelText: AppTexts.search,
                        prefixIcon: const Icon(Icons.search),
                      ),
                      onChanged: (v) => setState(() => _search = v),
                    ),
                    const SizedBox(height: 16),
                    ...filtered.map((ex) => _buildExerciseCard(ex)).toList(),
                    if (filtered.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(48),
                          child: Text('No exercises match.', style: TextStyle(fontSize: 14, color: AppTheme.mutedLight)),
                        ),
                      ),
                    const SizedBox(height: 24),
                    Text('Catalogue content coming soon.', style: TextStyle(fontSize: 11, color: AppTheme.mutedLight)),
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
