import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../texts/app_texts.dart';

class QuizQuestionScreen extends StatefulWidget {
  const QuizQuestionScreen({super.key});

  @override
  State<QuizQuestionScreen> createState() => _QuizQuestionScreenState();
}

class _QuizQuestionScreenState extends State<QuizQuestionScreen> {
  int _currentQuestion = 1;
  String? _selectedAnswer;
  final int totalQuestions = 10;

  final List<Map<String, dynamic>> questions = [
    {'key': 'q1', 'label': AppTexts.q1, 'options': [AppTexts.targetMuscleGain, AppTexts.targetStayingHealthy, AppTexts.targetLookFit, AppTexts.targetNoTarget]},
    {'key': 'q2', 'label': 'How is your energy today?', 'options': ['High', 'Normal', 'Low']},
    {'key': 'q3', 'label': 'How motivated do you feel to train?', 'options': ['High', 'Normal', 'Low']},
    {'key': 'q4', 'label': 'How many days per week can you train?', 'options': ['1-2', '3-4', '5+']},
    {'key': 'q5', 'label': 'How long are your usual sessions?', 'options': ['<30 min', '30-60 min', '>60 min']},
    {'key': 'q6', 'label': 'Have real-life interruptions cut sessions short lately?', 'options': ['Yes', 'No', 'Prefer not to say']},
    {'key': 'q7', 'label': 'How confident do you feel with your current program?', 'options': ['High', 'Normal', 'Low']},
    {'key': 'q8', 'label': 'What matters most right now?', 'options': ['Strength', 'Consistency', 'Mobility', 'General health']},
    {'key': 'q9', 'label': 'How ready are you to resume your usual load?', 'options': ['Ready', 'Ease in', 'Not sure']},
    {'key': 'q10', 'label': AppTexts.q10, 'options': [AppTexts.pushYes, AppTexts.pushSame, AppTexts.pushReduced]},
  ];

  @override
  Widget build(BuildContext context) {
    final q = questions[_currentQuestion - 1];
    final isLast = _currentQuestion >= totalQuestions;

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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(AppTexts.progress(_currentQuestion, totalQuestions), style: TextStyle(fontSize: 12, color: AppTheme.mutedLight)),
                        if (_currentQuestion > 1)
                          TextButton(onPressed: () => setState(() => _currentQuestion--), child: Text(AppTexts.backButton, style: TextStyle(fontSize: 14, color: AppTheme.primary))),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppTheme.cardLight, borderRadius: BorderRadius.circular(AppTheme.radiusCard), border: Border.all(color: AppTheme.lineLight)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
                            child: Text(AppTexts.nonDiagnostic, style: const TextStyle(fontSize: 10, color: AppTheme.mutedLight)),
                          ),
                          const SizedBox(height: 16),
                          Text(q['label'], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.textLight)),
                          const SizedBox(height: 20),
                          ...(q['options'] as List<String>).map((opt) {
                            final isSelected = _selectedAnswer == opt;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              child: SizedBox(
                                width: 250,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: isSelected ? Colors.white : AppTheme.textLight,
                                    backgroundColor: isSelected ? AppTheme.primary : Colors.transparent,
                                    side: BorderSide(color: isSelected ? AppTheme.primary : AppTheme.lineLight),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  onPressed: () => setState(() => _selectedAnswer = opt),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(opt, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                      if (isSelected) const Icon(Icons.check_circle, color: Colors.white, size: 20),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: 250,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _selectedAnswer == null ? null : () {
                          if (isLast) {
                            Navigator.pushNamed(context, '/quiz/explainer');
                          } else {
                            setState(() {
                              _currentQuestion++;
                              _selectedAnswer = null;
                            });
                          }
                        },
                        child: Text(isLast ? AppTexts.q10Button : AppTexts.nextButton, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
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
