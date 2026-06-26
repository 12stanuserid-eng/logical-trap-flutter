import 'package:flutter/material.dart';
import 'package:logical_trap_game/game/game_engine.dart';
import 'package:logical_trap_game/utils/i18n.dart';
import 'package:logical_trap_game/utils/theme.dart';
import 'package:logical_trap_game/screens/game_screen.dart';
import 'package:logical_trap_game/screens/level_select_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Brain character
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, _) {
                  return Transform.scale(
                    scale: 1.0 + (_pulseController.value * 0.05),
                    child: const Text('🧠', style: TextStyle(fontSize: 90)),
                  );
                },
              ),
              const SizedBox(height: 8),

              // Thought bubble with tagline
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [AppTheme.softShadow],
                ),
                child: const Text(
                  '"Think outside the box!"',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Title
              const Text(
                'Logical Trap',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${GameEngine().totalLevels} Tricky Puzzles',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.7),
                  fontWeight: FontWeight.w300,
                ),
              ),

              const Spacer(flex: 2),

              // PLAY button
              GestureDetector(
                onTap: () {
                  final engine = GameEngine();
                  if (engine.completedCount > 0 && engine.completedCount < engine.totalLevels) {
                    // Resume from where they left off
                    engine.loadLevel(engine.nextLevel);
                  } else {
                    engine.init();
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GameScreen()),
                  );
                },
                child: Container(
                  width: size.width * 0.65,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: AppTheme.playGradient,
                    borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF6B6B).withOpacity(0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.play_arrow_rounded, color: Colors.white, size: 32),
                        SizedBox(width: 8),
                        Text(
                          'PLAY',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Level Select button
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LevelSelectScreen()),
                  );
                },
                child: Container(
                  width: size.width * 0.5,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppTheme.buttonRadius),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: const Center(
                    child: Text(
                      '📋 LEVELS',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Language toggle
              TextButton(
                onPressed: () {
                  I18n().toggle();
                  setState(() {});
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    I18n().isHindi ? '🇮🇳 हिंदी' : '🇬🇧 English',
                    style: const TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
