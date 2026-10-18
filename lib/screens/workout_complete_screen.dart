import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../texts/app_texts.dart';

class WorkoutCompleteScreen extends StatelessWidget {
  const WorkoutCompleteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map? ?? {};
    final totalSets = args['totalSets'] ?? 0;

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 64, height: 64, decoration: BoxDecoration(color: AppTheme.success, borderRadius: BorderRadius.circular(32)), child: const Center(child: Text('✓', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)))),
                const SizedBox(height: 20),
                Text(AppTexts.completeTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textLight)),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: AppTheme.cardLight, borderRadius: BorderRadius.circular(AppTheme.radiusCard), border: Border.all(color: AppTheme.lineLight)),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              Text(AppTexts.totalTime, style: TextStyle(fontSize: 12, color: AppTheme.mutedLight)),
                              const SizedBox(height: 4),
                              const Text('00:00', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.textLight)),
                            ],
                          ),
                          Container(width: 1, height: 40, color: AppTheme.lineLight),
                          Column(
                            children: [
                              Text(AppTexts.totalSets, style: TextStyle(fontSize: 12, color: AppTheme.mutedLight)),
                              const SizedBox(height: 4),
                              Text('$totalSets', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.textLight)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text('Every rep counts. Saved to your history.', style: TextStyle(fontSize: 12, color: AppTheme.mutedLight)),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: 250,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                    child: const Text(AppTexts.goHome, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
