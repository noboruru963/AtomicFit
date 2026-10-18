import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../texts/app_texts.dart';

class QuizPromptScreen extends StatelessWidget {
  const QuizPromptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(width: 64, height: 64, decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(32)), child: const Center(child: Text('AF', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)))),
                      const SizedBox(height: 24),
                      Text(AppTexts.appName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.textLight)),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: AppTheme.cardLight, borderRadius: BorderRadius.circular(AppTheme.radiusCard), border: Border.all(color: AppTheme.lineLight)),
                        child: Column(
                          children: [
                            Text(AppTexts.promptTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textLight)),
                            const SizedBox(height: 12),
                            Text(AppTexts.promptBody, style: TextStyle(fontSize: 14, color: AppTheme.mutedLight), textAlign: TextAlign.center),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                              child: Text(AppTexts.nonDiagnostic, style: const TextStyle(fontSize: 10, color: AppTheme.mutedLight), textAlign: TextAlign.center),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: 250,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: () => Navigator.pushNamed(context, '/quiz/question'),
                                child: const Text(AppTexts.startButton, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: 250,
                              height: 52,
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text(AppTexts.notNowButton, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
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
