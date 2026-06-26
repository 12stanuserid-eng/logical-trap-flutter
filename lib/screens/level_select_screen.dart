import 'package:flutter/material.dart';
import 'package:logical_trap_game/game/game_engine.dart';
import 'package:logical_trap_game/utils/i18n.dart';
import 'package:logical_trap_game/utils/theme.dart';
import 'package:logical_trap_game/screens/game_screen.dart';

class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final engine = GameEngine();
    final total = engine.totalLevels;
    final completed = engine.completedCount;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Levels',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$completed/$total',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Progress bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: total > 0 ? completed / total : 0,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accent),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Level grid
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1,
                    ),
                    itemCount: total,
                    itemBuilder: (context, index) {
                      final isCompleted = engine.completedLevels.contains(index);
                      final isCurrent = engine.nextLevel == index;
                      return _LevelTile(
                        number: index + 1,
                        isCompleted: isCompleted,
                        isCurrent: isCurrent,
                        onTap: () {
                          engine.loadLevel(index);
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const GameScreen()),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _LevelTile extends StatelessWidget {
  final int number;
  final bool isCompleted;
  final bool isCurrent;
  final VoidCallback onTap;

  const _LevelTile({
    required this.number,
    required this.isCompleted,
    required this.isCurrent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isCompleted
              ? const Color(0xFF6BCB77)
              : isCurrent
                  ? AppTheme.accent
                  : Colors.white.withOpacity(0.25),
          borderRadius: BorderRadius.circular(14),
          border: isCurrent
              ? Border.all(color: AppTheme.accent, width: 3)
              : null,
        ),
        child: Center(
          child: isCompleted
              ? const Text('✓', style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.bold))
              : Text(
                  '$number',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isCurrent ? const Color(0xFF2D3436) : Colors.white.withOpacity(0.8),
                  ),
                ),
        ),
      ),
    );
  }
}
