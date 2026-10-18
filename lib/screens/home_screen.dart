import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../texts/app_texts.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
                    Text(AppTexts.welcome('Alex'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textLight)),
                    const SizedBox(height: 4),
                    Text(AppTexts.tagline, style: TextStyle(fontSize: 14, color: AppTheme.mutedLight)),
                    const SizedBox(height: 24),
                    _buildQuizCard(context),
                    const SizedBox(height: 16),
                    _buildCalendarSection(),
                    const SizedBox(height: 16),
                    _buildActionsSection(context),
                    const SizedBox(height: 24),
                    Text(AppTexts.noWorkoutsYet, style: TextStyle(fontSize: 12, color: AppTheme.mutedLight)),
                  ],
                ),
              ),
            ),
            _buildBottomNav(context, 0),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(width: 28, height: 28, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(14)), child: const Center(child: Text('AF', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800)))),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('AtomFit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                Text('${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}', style: const TextStyle(fontSize: 12, color: Colors.white70)),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.notifications_none, color: Colors.white), onPressed: null),
          const SizedBox(width: 4),
          GestureDetector(onTap: () => Navigator.pushNamed(context, '/settings'), child: const Icon(Icons.more_vert, color: Colors.white, size: 28)),
        ],
      ),
    );
  }

  Widget _buildQuizCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.cardLight, borderRadius: BorderRadius.circular(AppTheme.radiusCard), border: Border.all(color: AppTheme.lineLight)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppTexts.quizEntry, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textLight)),
          const SizedBox(height: 8),
          Text('Short non-diagnostic quiz to adjust your program to your pace.', style: TextStyle(fontSize: 12, color: AppTheme.mutedLight)),
          const SizedBox(height: 12),
          SizedBox(
            width: 250,
            child: OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, '/quiz/prompt'),
              child: const Text(AppTexts.startButton),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppTexts.calendarMonth, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textLight)),
            Row(
              children: [
                Container(width: 24, height: 24, decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(12)), child: const Center(child: Text('3', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)))),
                const SizedBox(width: 8),
                Text(AppTexts.monthlyCount, style: TextStyle(fontSize: 12, color: AppTheme.mutedLight)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 300,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 1),
            itemCount: 35,
            itemBuilder: (context, index) {
              final day = index + 1;
              final isToday = day == DateTime.now().day;
              final hasWorkout = day % 5 == 0;
              return Container(
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: isToday ? AppTheme.primaryLight : (hasWorkout ? AppTheme.primary.withOpacity(0.1) : Colors.transparent),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.lineLight),
                ),
                child: Center(
                  child: Text(
                    '$day',
                    style: TextStyle(fontSize: 12, fontWeight: isToday ? FontWeight.w800 : FontWeight.normal, color: isToday ? AppTheme.primaryDark : AppTheme.textLight),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionsSection(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 250,
          height: 52,
          child: ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/workout/active'),
            child: const Text(AppTexts.emptyWorkout, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: 250,
          height: 52,
          child: OutlinedButton(
            onPressed: () => Navigator.pushNamed(context, '/programs'),
            child: const Text(AppTexts.myPrograms, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNav(BuildContext context, int selectedIndex) {
    final items = [
      {'label': 'Home', 'icon': Icons.home},
      {'label': 'History', 'icon': Icons.history},
      {'label': 'Discover', 'icon': Icons.explore},
      {'label': 'Profile', 'icon': Icons.person},
    ];

    return Container(
      height: 72,
      decoration: BoxDecoration(color: AppTheme.cardLight, border: Border(top: BorderSide(color: AppTheme.lineLight))),
      child: Row(
        children: List.generate(items.length, (i) {
          final isSelected = i == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                final routes = ['/home', '/history', '/discover', '/profile'];
                Navigator.pushReplacementNamed(context, routes[i]);
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(items[i]['icon'] as IconData, color: isSelected ? AppTheme.primary : AppTheme.mutedLight, size: 24),
                  const SizedBox(height: 4),
                  Text(items[i]['label'] as String, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: isSelected ? AppTheme.primary : AppTheme.mutedLight)),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
