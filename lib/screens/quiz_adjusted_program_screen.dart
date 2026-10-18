import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../texts/app_texts.dart';

class QuizAdjustedProgramScreen extends StatefulWidget {
  const QuizAdjustedProgramScreen({super.key});

  @override
  State<QuizAdjustedProgramScreen> createState() => _QuizAdjustedProgramScreenState();
}

class _QuizAdjustedProgramScreenState extends State<QuizAdjustedProgramScreen> {
  bool _accepted = false;

  @override
  Widget build(BuildContext context) {
    if (_accepted) {
      return Scaffold(
        backgroundColor: AppTheme.bgLight,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 64, height: 64, decoration: BoxDecoration(color: AppTheme.success, borderRadius: BorderRadius.circular(32)), child: const Center(child: Text('✓', style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)))),
                const SizedBox(height: 20),
                Text('Program adjusted', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textLight)),
                const SizedBox(height: 8),
                Text('Your new program version is now Current.', style: TextStyle(fontSize: 14, color: AppTheme.mutedLight)),
                const SizedBox(height: 24),
                SizedBox(
                  width: 250,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                    child: const Text(AppTexts.continueBtn, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: double.infinity),
                    const SizedBox(height: 24),
                    Text(AppTexts.adjustedTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textLight)),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppTheme.cardLight, borderRadius: BorderRadius.circular(AppTheme.radiusCard), border: Border.all(color: AppTheme.lineLight)),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                            child: Text(AppTexts.nonDiagnostic, style: const TextStyle(fontSize: 10, color: AppTheme.mutedLight)),
                          ),
                          const SizedBox(height: 16),
                          _buildPreviewRow(AppTexts.sessionLengthKey, 'Slightly shorter'),
                          _buildPreviewRow(AppTexts.intensityKey, 'Reduce the weight'),
                          _buildPreviewRow(AppTexts.frequencyKey, 'Same as last'),
                          _buildPreviewRow(AppTexts.weightReductionKey, '15% (within 10-20%)'),
                          const SizedBox(height: 16),
                          Text('Reduced intensity requested — easing back in.', style: TextStyle(fontSize: 12, color: AppTheme.mutedLight)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: 250,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () => setState(() => _accepted = true),
                        child: const Text(AppTexts.acceptButton, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: 250,
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                        child: const Text(AppTexts.keepButton, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
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

  Widget _buildPreviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: AppTheme.mutedLight)),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textLight)),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
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
          IconButton(icon: const Icon(Icons.notifications_none, color: Colors.white), onPressed: null),
        ],
      ),
    );
  }
}
