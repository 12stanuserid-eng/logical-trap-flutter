import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:logical_trap_game/models/puzzle.dart';
import 'package:logical_trap_game/game/game_engine.dart';
import 'package:logical_trap_game/utils/i18n.dart';
import 'package:logical_trap_game/utils/theme.dart';
import 'package:logical_trap_game/screens/result_screen.dart';
import 'package:logical_trap_game/widgets/visual_scene.dart';
import 'package:logical_trap_game/widgets/shake_detector.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  final engine = GameEngine();
  final i18n = I18n();
  String? hintText;
  bool showHint = false;
  bool _isShaking = false;
  bool _showCelebration = false;
  bool _transitioning = false;
  int _celebrationPoints = 0;

  // Celebration particles
  final List<_Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    i18n.addListener(_onLangChange);
    engine.addListener(_onEngineChange);
  }

  @override
  void dispose() {
    i18n.removeListener(_onLangChange);
    engine.removeListener(_onEngineChange);
    super.dispose();
  }

  void _onLangChange() {
    if (mounted) setState(() {});
  }

  void _onEngineChange() {
    if (mounted) setState(() {});
  }

  Puzzle get puzzle => engine.currentPuzzle;

  /// Handle correct tap/shake result
  void _handleCorrect(AnswerResult result) {
    if (_transitioning) return;
    _transitioning = true;

    setState(() {
      _showCelebration = true;
      _celebrationPoints = result.points;
      _particles.clear();
      // Generate celebration particles
      for (int i = 0; i < 20; i++) {
        _particles.add(_Particle(
          x: Random().nextDouble(),
          y: 0.5 + Random().nextDouble() * 0.3,
          speed: 0.3 + Random().nextDouble() * 0.5,
          size: 8 + Random().nextDouble() * 16,
          color: _randomCelebrationColor(),
          delay: Random().nextDouble() * 0.5,
        ));
      }
    });

    // Auto-advance after 1.5s
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      engine.clearLevelJustCompleted();

      if (engine.isAllCompleted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              score: engine.score,
              streak: engine.streak,
              isLastLevel: true,
            ),
          ),
        );
      } else if (engine.isGameOver) {
        _showGameOver();
      } else {
        engine.nextPuzzle();
        setState(() {
          _showCelebration = false;
          _transitioning = false;
          _particles.clear();
        });
      }
    });
  }

  /// Handle wrong tap
  void _handleWrong() {
    if (_transitioning) return;
    engine.handleWrongTap();

    // Screen shake animation
    setState(() => _isShaking = true);
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _isShaking = false);
    });

    if (engine.isGameOver) {
      Future.delayed(const Duration(milliseconds: 600), () => _showGameOver());
    }
  }

  void _showGameOver() {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('💀', style: TextStyle(fontSize: 48), textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppStrings.get('gameOver'),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('⭐ ${engine.score}',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppTheme.accent),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context); // back to home
            },
            child: Text(AppStrings.get('newGame')),
          ),
        ],
      ),
    );
  }

  /// Handle tap on visual element
  void _handleElementTap(VisualElement el) {
    if (_transitioning || _showCelebration) return;

    final scene = puzzle.visual;
    if (scene == null) return;

    switch (scene.interaction) {
      case InteractionType.tapCorrect:
        if (el.correct) {
          final result = engine.handleCorrectTap();
          _handleCorrect(result);
        } else {
          _handleWrong();
        }
        break;
      case InteractionType.tapCount:
        if (el.correct) {
          engine.incrementTapCount();
          if (engine.currentTapCount >= engine.neededTapCount) {
            final result = engine.handleCorrectTap();
            _handleCorrect(result);
          }
        } else {
          _handleWrong();
        }
        break;
      case InteractionType.tapAny:
        final result = engine.handleCorrectTap();
        _handleCorrect(result);
        break;
    }
  }

  /// Handle shake detection
  void _handleShake() {
    if (_transitioning || _showCelebration) return;
    if (puzzle.type != 'shake') return;
    final result = engine.handleShake();
    _handleCorrect(result);
  }

  /// Handle tap on button (visible submit)
  void _handleTapSubmit() {
    if (_transitioning || _showCelebration) return;

    // For tap-type puzzles without visual scenes, handle here
    if (puzzle.type == 'tap') {
      if (puzzle.id == 't5') {
        // Tapping = wrong (need to tap 0 times)
        _handleWrong();
      } else {
        engine.incrementTapCount();
        if (engine.currentTapCount >= engine.neededTapCount) {
          final result = engine.handleCorrectTap();
          _handleCorrect(result);
        }
      }
    }
  }

  /// Use hint
  void _useHint() {
    final hint = engine.useHint();
    if (hint != null) {
      setState(() {
        hintText = hint;
        showHint = true;
      });
    }
  }

  /// Show action menu
  void _showMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 20),
              _menuItem(Icons.favorite, '❤️ ${engine.lives} Lives', null),
              _menuItem(Icons.lightbulb_outline, '💡 ${engine.hintsRemaining} Hints', _useHint),
              _menuItem(Icons.grid_view_rounded, '📋 Levels', () {
                Navigator.pop(context);
                Navigator.pop(context);
              }),
              _menuItem(Icons.home_outlined, '🏠 Home', () {
                Navigator.pop(context);
                Navigator.pop(context);
              }),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _menuItem(IconData icon, String text, VoidCallback? onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primary),
        title: Text(text, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: onTap != null ? const Icon(Icons.chevron_right) : null,
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Color _randomCelebrationColor() {
    const colors = [AppTheme.accent, AppTheme.secondary, AppTheme.success, AppTheme.primary, Colors.white];
    return colors[Random().nextInt(colors.length)];
  }

  @override
  Widget build(BuildContext context) {
    final scene = puzzle.visual;
    final bool isShakePuzzle = puzzle.type == 'shake';

    Widget screenContent = Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(gradient: AppTheme.sceneGradient),
        child: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  // Mini HUD
                  _buildHUD(),

                  // Shake indicator for shake puzzles
                  if (isShakePuzzle)
                    _buildShakeIndicator(),

                  // Visual scene
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: scene != null
                          ? VisualSceneWidget(
                              scene: scene,
                              onElementTap: _handleElementTap,
                            )
                          : _buildFallbackScene(),
                    ),
                  ),

                  // Question overlay at bottom
                  _buildQuestionOverlay(),
                ],
              ),

              // Hint overlay
              if (showHint && hintText != null)
                Positioned(
                  top: 80,
                  left: 20,
                  right: 20,
                  child: _buildHintBubble(),
                ),

              // Celebration overlay
              if (_showCelebration)
                _buildCelebrationOverlay(),

              // Screen shake transform
              if (_isShaking)
                Positioned.fill(
                  child: IgnorePointer(
                    child: _buildShakeOverlay(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    // Wrap with shake detector for shake puzzles
    if (isShakePuzzle) {
      screenContent = ShakeDetectorWidget(
        onShake: _handleShake,
        child: screenContent,
      );
    }

    return screenContent;
  }

  Widget _buildHUD() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Row(
        children: [
          // Menu button (replaces back)
          GestureDetector(
            onTap: _showMenu,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [AppTheme.softShadow],
              ),
              child: const Icon(Icons.more_horiz, size: 22, color: AppTheme.primary),
            ),
          ),
          const SizedBox(width: 8),

          // Level indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [AppTheme.softShadow],
            ),
            child: Text(
              'Level ${engine.currentLevel + 1}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: AppTheme.primary,
              ),
            ),
          ),

          const Spacer(),

          // Progress indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [AppTheme.softShadow],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('📊', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(
                  '${engine.completedCount}/${engine.totalLevels}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Hearts
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [AppTheme.softShadow],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('❤️', style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text(
                  '${engine.lives}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: engine.lives <= 1 ? AppTheme.danger : AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionOverlay() {
    final isHindi = i18n.isHindi;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [AppTheme.strongShadow],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Hint button
              GestureDetector(
                onTap: _useHint,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('💡', style: TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  puzzle.question.get(isHindi ? 'hi' : 'en'),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShakeIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: AlwaysStoppedAnimation(0),
            builder: (context, _) {
              return const Text('📳 Shake the device!',
                style: TextStyle(
                  fontSize: 13,
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackScene() {
    // For puzzles without visual scene (shouldn't happen after redesign)
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (puzzle.type == 'tap')
            GestureDetector(
              onTap: _handleTapSubmit,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.primaryGradient,
                  boxShadow: [AppTheme.strongShadow],
                ),
                child: Center(
                  child: Text(
                    '${engine.currentTapCount}/${engine.neededTapCount}',
                    style: const TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            )
          else
            const Text('🧩', style: TextStyle(fontSize: 80)),
        ],
      ),
    );
  }

  Widget _buildHintBubble() {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFFD93D), width: 2),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('💡', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Hint',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFFB8860B)),
                  ),
                  const SizedBox(height: 4),
                  Text(hintText ?? '',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF8B6914)),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => setState(() => showHint = false),
              child: const Icon(Icons.close, size: 18, color: Color(0xFFB8860B)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCelebrationOverlay() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          color: Colors.black.withOpacity(0.2),
          child: Stack(
            children: [
              // Center celebration
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🎉', style: TextStyle(fontSize: 64)),
                    const SizedBox(height: 8),
                    const Text('Correct!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        shadows: [Shadow(color: Colors.black26, blurRadius: 8)],
                      ),
                    ),
                    if (_celebrationPoints > 0)
                      Text('+$_celebrationPoints',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.accent,
                          shadows: [Shadow(color: Colors.black26, blurRadius: 8)],
                        ),
                      ),
                  ],
                ),
              ),

              // Particles
              ...List.generate(_particles.length, (i) {
                final p = _particles[i];
                return Positioned(
                  left: p.x * MediaQuery.of(context).size.width,
                  top: p.y * MediaQuery.of(context).size.height,
                  child: Container(
                    width: p.size,
                    height: p.size,
                    decoration: BoxDecoration(
                      color: p.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShakeOverlay() {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        final shakeValue = sin(_shakeAnimation.value * 15) * 5;
        return Transform.translate(
          offset: Offset(shakeValue, 0),
          child: Container(color: Colors.transparent),
        );
      },
    );
  }

  Animation<double> get _shakeAnimation {
    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    controller.forward();
    return CurvedAnimation(parent: controller, curve: Curves.easeOut);
  }
}

/// Particle for celebration effect
class _Particle {
  final double x;
  final double y;
  final double speed;
  final double size;
  final Color color;
  final double delay;

  _Particle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.color,
    required this.delay,
  });
}
