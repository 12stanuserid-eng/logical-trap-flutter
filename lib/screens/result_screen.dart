import 'package:flutter/material.dart';
import 'package:logical_trap_game/game/game_engine.dart';
import 'package:logical_trap_game/utils/i18n.dart';
import 'package:logical_trap_game/utils/theme.dart';
import 'package:logical_trap_game/screens/game_screen.dart';
import 'package:logical_trap_game/screens/home_screen.dart';

class ResultScreen extends StatefulWidget {
  final int score;
  final int streak;
  final bool isLastLevel;

  const ResultScreen({
    super.key,
    required this.score,
    this.streak = 0,
    this.isLastLevel = false,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
    _scaleAnim = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final engine = GameEngine();
    final isLast = widget.isLastLevel || engine.isAllCompleted;
    final isHindi = I18n().isHindi;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: isLast
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFFD93D), Color(0xFFF2994A)],
                )
              : AppTheme.primaryGradient,
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Celebration icon
              AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return Transform.scale(
                    scale: _scaleAnim.value,
                    child: isLast
                        ? const Text('🏆', style: TextStyle(fontSize: 100))
                        : const Text('🎉', style: TextStyle(fontSize: 100)),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Title
              FadeTransition(
                opacity: _fadeAnim,
                child: Text(
                  isLast ? AppStrings.get('youWin') : AppStrings.get('correct'),
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),

              // Streak
              if (widget.streak > 2)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '🔥 ${widget.streak}x Streak!',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber,
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 32),

              // Score card
              FadeTransition(
                opacity: _fadeAnim,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '⭐ ${widget.score}',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppStrings.get('score'),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.7),
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '❤️ ${engine.lives}',
                            style: const TextStyle(fontSize: 20, color: Colors.white),
                          ),
                          const SizedBox(width: 24),
                          Text(
                            '📊 ${engine.completedCount}/${engine.totalLevels}',
                            style: const TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Action buttons
              FadeTransition(
                opacity: _fadeAnim,
                child: Column(
                  children: [
                    if (!isLast)
                      GestureDetector(
                        onTap: () {
                          engine.nextPuzzle();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const GameScreen()),
                          );
                        },
                        child: _buildButton(
                          '▶  ${AppStrings.get("next")}',
                          AppTheme.playGradient,
                        ),
                      ),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                          (route) => false,
                        );
                      },
                      child: _buildButton(
                        '🏠  ${isLast ? AppStrings.get("newGame") : "Home"}',
                        LinearGradient(
                          colors: [Colors.white.withOpacity(0.3), Colors.white.withOpacity(0.1)],
                        ),
                        isSecondary: true,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButton(String text, Gradient gradient, {bool isSecondary = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(30),
        border: isSecondary ? Border.all(color: Colors.white.withOpacity(0.4)) : null,
        boxShadow: isSecondary
            ? null
            : [
                BoxShadow(
                  color: const Color(0xFFFF6B6B).withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
