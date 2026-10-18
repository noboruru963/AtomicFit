import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../texts/app_texts.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _search = '';
  String _filter = 'All';

  final List<Map<String, dynamic>> _sessions = [
    {'id': 's1', 'name': 'Push Pull Leg', 'type': 'full', 'date': 'Oct 18, 17:30', 'reps': 30, 'volume': 600.0},
    {'id': 's2', 'name': 'Empty program', 'type': 'micro', 'date': 'Oct 17, 08:15', 'reps': 12, 'volume': 240.0},
    {'id': 's3', 'name': 'Upper Lower', 'type': 'stitched', 'date': 'Oct 15, 19:00', 'reps': 45, 'volume': 900.0, 'children': 2},
    {'id': 's4', 'name': 'Push Pull Leg', 'type': 'full', 'date': 'Oct 12, 10:00', 'reps': 28, 'volume': 560.0},
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _sessions.where((s) {
      final match = s['name'].toLowerCase().contains(_search.toLowerCase());
      final typeMatch = _filter == 'All' ||
          (_filter == 'Full' && s['type'] == 'full') ||
          (_filter == 'Micro' && s['type'] == 'micro');
      return match && typeMatch;
    }).toList();

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
                    Text(AppTexts.historyTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textLight)),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        labelText: AppTexts.search,
                        prefixIcon: const Icon(Icons.search),
                      ),
                      onChanged: (v) => setState(() => _search = v),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: ['All', 'Full', 'Micro'].map((f) {
                        final isSelected = _filter == f;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(f == 'All' ? AppTexts.filterAll : f == 'Full' ? AppTexts.filterFull : AppTexts.filterMicro),
                            selected: isSelected,
                            onSelected: (v) => setState(() => _filter = f),
                            selectedColor: AppTheme.primary.withOpacity(0.1),
                            labelStyle: TextStyle(color: isSelected ? AppTheme.primary : AppTheme.mutedLight, fontWeight: FontWeight.w700),
                            backgroundColor: Colors.transparent,
                            shape: isSelected
                                ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusPill), side: const BorderSide(color: AppTheme.primary))
                                : RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusPill), side: BorderSide(color: AppTheme.lineLight)),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    if (filtered.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.all(48),
                          child: Text(AppTexts.noWorkouts, style: TextStyle(fontSize: 14, color: AppTheme.mutedLight)),
                        ),
                      )
                    else
                      ...filtered.map((s) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: AppTheme.cardLight, borderRadius: BorderRadius.circular(AppTheme.radiusCard), border: Border.all(color: AppTheme.lineLight)),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(s['name'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textLight)),
                                        if (s['type'] == 'micro') ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                                            child: Text(AppTexts.microBadge, style: const TextStyle(color: AppTheme.primary, fontSize: 8, fontWeight: FontWeight.w700)),
                                          ),
                                        ],
                                        if (s['type'] == 'stitched') ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(color: AppTheme.mutedLight.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                                            child: Text(AppTexts.stitchedBadge, style: const TextStyle(color: AppTheme.mutedLight, fontSize: 8, fontWeight: FontWeight.w700)),
                                          ),
                                        ],
                                        if (s['children'] != null) ...[
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                                            child: Text('${s['children']} sessions', style: const TextStyle(color: AppTheme.primary, fontSize: 8, fontWeight: FontWeight.w700)),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text('${s['date']} · ${s['reps']} reps · ${s['volume']} kg', style: TextStyle(fontSize: 11, color: AppTheme.mutedLight)),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: AppTheme.danger),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (c) => AlertDialog(
                                      title: const Text('Delete session?'),
                                      content: Text(AppTexts.deleteConfirm),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(c), child: const Text(AppTexts.cancel)),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(c);
                                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(AppTexts.deleted)));
                                          },
                                          child: const Text(AppTexts.delete, style: TextStyle(color: AppTheme.danger)),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      }).toList(),
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
          Container(width: 28, height: 28, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(14)), child: const Center(child: Text('AF', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)))),
          const SizedBox(width: 12),
          const Text('AtomFit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
          const Spacer(),
          IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        ],
      ),
    );
  }
}
