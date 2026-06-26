import 'dart:async';
import 'package:flutter/material.dart';
import 'package:logical_trap_game/models/puzzle.dart';
import 'package:logical_trap_game/game/game_engine.dart';
import 'package:logical_trap_game/utils/i18n.dart';
import 'package:logical_trap_game/screens/result_screen.dart';
import 'package:logical_trap_game/widgets/visual_scene.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  final engine = GameEngine();
  final textController = TextEditingController();
  final i18n = I18n();
  String? hintText;
  bool showHint = false;
  String? toastMsg;
  bool toastIsError = false;

  @override
  void initState() {
    super.initState();
    i18n.addListener(_onLangChange);
  }

  @override
  void dispose() {
    i18n.removeListener(_onLangChange);
    textController.dispose();
    super.dispose();
  }

  void _onLangChange() {
    if (mounted) setState(() {});
  }

  Puzzle get puzzle => engine.currentPuzzle;

  void _showToast(String msg, {bool isError = false}) {
    setState(() {
      toastMsg = msg;
      toastIsError = isError;
    });
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted && toastMsg == msg) {
        setState(() => toastMsg = null);
      }
    });
  }

  void _handleSubmit(String answer) {
    if (answer.trim().isEmpty) return;

    final result = engine.checkAnswer(answer);
    if (result.correct) {
      _showToast('✅ ${result.message}');
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ResultScreen(
                score: result.score,
                streak: result.streak,
                isLastLevel: engine.isAllCompleted,
              ),
            ),
          );
        }
      });
    } else {
      _showToast('❌ ${result.message}', isError: true);
      if (engine.isGameOver) {
        _showGameOver();
      }
    }
  }

  void _showGameOver() {
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: Text(AppStrings.get('gameOver')),
            content: Text('Score: ${engine.score}'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  engine.init();
                  setState(() {
                    hintText = null;
                    showHint = false;
                  });
                },
                child: Text(AppStrings.get('newGame')),
              ),
            ],
          ),
        );
      }
    });
  }

  void _useHint() {
    final hint = engine.useHint();
    if (hint != null) {
      setState(() {
        hintText = hint;
        showHint = true;
      });
    } else {
      _showToast('💡 ${AppStrings.get('noHint')}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final puzzle = engine.currentPuzzle;
    final isHindi = i18n.isHindi;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8F9FF), Color(0xFFE8ECFF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top HUD
              _buildHUD(),

              // Toast messages
              if (toastMsg != null) _buildToast(),

              // Question area
              _buildQuestionArea(puzzle, isHindi),

              // Visual scene or answer area
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      if (puzzle.type == 'visual' && puzzle.visual != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: VisualSceneWidget(
                            scene: puzzle.visual!,
                            onSubmit: _handleSubmit,
                          ),
                        ),

                      // Answer area for non-visual
                      if (puzzle.type != 'visual') ...[
                        const SizedBox(height: 20),
                        if (puzzle.options != null)
                          _buildOptions(puzzle.options!, isHindi)
                        else
                          _buildTextInput(isHindi),
                      ],

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHUD() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back_ios_new, size: 18, color: Color(0xFF6C63FF)),
            ),
          ),

          const SizedBox(width: 12),

          // Level
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Text(
              '${AppStrings.get('level')} ${engine.currentLevel + 1}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Color(0xFF6C63FF),
              ),
            ),
          ),

          const Spacer(),

          // Lives
          _hudItem(
            '❤️',
            '${engine.lives}',
            engine.lives <= 1 ? Colors.red : null,
          ),
          const SizedBox(width: 8),

          // Hints
          GestureDetector(
            onTap: _useHint,
            child: _hudItem(
              '💡',
              '${engine.hintsRemaining}',
              null,
            ),
          ),
          const SizedBox(width: 8),

          // Score
          _hudItem('⭐', '${engine.score}', null),
        ],
      ),
    );
  }

  Widget _hudItem(String emoji, String text, Color? color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: color ?? const Color(0xFF2D3436),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToast() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: toastIsError
            ? const Color(0xFFFFE5E5)
            : const Color(0xFFE5FFE5),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
          ),
        ],
      ),
      child: Text(
        toastMsg ?? '',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: toastIsError ? Colors.red[700] : Colors.green[700],
        ),
      ),
    );
  }

  Widget _buildQuestionArea(Puzzle puzzle, bool isHindi) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Difficulty badges
          Row(
            children: [
              _difficultyBadge(puzzle),
              const SizedBox(width: 8),
              _categoryBadge(puzzle.category, isHindi),
            ],
          ),
          const SizedBox(height: 12),

          // Question text
          Text(
            puzzle.question.get(isHindi ? 'hi' : 'en'),
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3436),
              height: 1.4,
            ),
          ),

          // Hint
          if (showHint && hintText != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3CD),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Text('💡', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      hintText!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.brown[700],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _difficultyBadge(Puzzle p) {
    final colors = [Colors.green, Colors.lime, Colors.orange, Colors.deepOrange, Colors.red];
    final color = colors[p.difficulty - 1].withValues(alpha: 0.2);
    final textColor = colors[p.difficulty - 1];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${'⭐' * p.difficulty}',
        style: TextStyle(fontSize: 11, color: textColor),
      ),
    );
  }

  Widget _categoryBadge(PuzzleCategory cat, bool isHindi) {
    final names = {
      PuzzleCategory.logic: '🧠 Logic',
      PuzzleCategory.trick: '🎯 Trick',
      PuzzleCategory.math: '🔢 Math',
      PuzzleCategory.observation: '👁️ Observation',
      PuzzleCategory.word: '📝 Word',
      PuzzleCategory.memory: '🧩 Memory',
      PuzzleCategory.speed: '⚡ Speed',
      PuzzleCategory.lateral: '💡 Lateral',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        names[cat] ?? '🧠',
        style: const TextStyle(fontSize: 11, color: Color(0xFF6C63FF)),
      ),
    );
  }

  Widget _buildOptions(List<Bilingual> options, bool isHindi) {
    return Column(
      children: options.map((opt) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GestureDetector(
            onTap: () => _handleSubmit(opt.get(isHindi ? 'hi' : 'en')),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE0E0E0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                opt.get(isHindi ? 'hi' : 'en'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2D3436),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextInput(bool isHindi) {
    return Column(
      children: [
        TextField(
          controller: textController,
          decoration: InputDecoration(
            hintText: AppStrings.get('typeAnswer'),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
          style: const TextStyle(fontSize: 16),
          onSubmitted: (v) => _handleSubmit(v),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _handleSubmit(textController.text),
          child: Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C63FF), Color(0xFF5A52E0)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                '✓  SUBMIT',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
