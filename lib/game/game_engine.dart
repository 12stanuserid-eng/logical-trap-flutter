import 'dart:math';
import 'package:flutter/material.dart';
import 'package:logical_trap_game/models/puzzle.dart';
import 'package:logical_trap_game/data/puzzles.dart';

/// Core game state manager
class GameEngine extends ChangeNotifier {
  static final GameEngine _instance = GameEngine._();
  factory GameEngine() => _instance;
  GameEngine._();

  // State
  int score = 0;
  int lives = 3;
  int hintsRemaining = 3;
  int streak = 0;
  int currentLevel = 0;
  final Set<int> completedLevels = {};
  List<Puzzle>? _shuffledPuzzles;
  int _currentTapCount = 0;

  List<Puzzle> get shuffledPuzzles {
    if (_shuffledPuzzles == null) {
      _shuffledPuzzles = List.from(puzzles)..shuffle(Random());
    }
    return _shuffledPuzzles!;
  }

  Puzzle get currentPuzzle => shuffledPuzzles[currentLevel];

  int get totalLevels => shuffledPuzzles.length;
  int get completedCount => completedLevels.length;
  bool get isGameOver => lives <= 0;
  bool get isAllCompleted => completedLevels.length >= totalLevels;

  /// Initialize/reset game
  void init() {
    score = 0;
    lives = 3;
    hintsRemaining = 3;
    streak = 0;
    currentLevel = 0;
    completedLevels.clear();
    _currentTapCount = 0;
    _shuffledPuzzles = List.from(puzzles)..shuffle(Random());
    notifyListeners();
  }

  /// Load a specific level
  void loadLevel(int index) {
    if (index < shuffledPuzzles.length) {
      currentLevel = index;
      _currentTapCount = 0;
      notifyListeners();
    }
  }

  /// Check answer and return result
  AnswerResult checkAnswer(String userAnswer) {
    final puzzle = currentPuzzle;
    if (puzzle.type == 'visual' && puzzle.visual != null) {
      final interaction = puzzle.visual!.interaction;
      if (interaction == InteractionType.tapCount) {
        final needed = int.tryParse(puzzle.answer.get('en')) ?? 1;
        final given = int.tryParse(userAnswer) ?? 0;
        if (given >= needed) {
          return _handleCorrect();
        }
        return AnswerResult(false, 'Keep tapping!', score);
      }
    }

    final correct = puzzle.answer.get('en');
    final user = userAnswer.trim().toLowerCase();
    final expected = correct.trim().toLowerCase();

    if (user == expected) {
      return _handleCorrect();
    }
    return _handleWrong();
  }

  AnswerResult _handleCorrect() {
    final puzzle = currentPuzzle;
    streak++;
    final bonus = streak > 3 ? 50 : 0;
    final pts = (puzzle.difficulty * 100) + bonus;
    score += pts;

    if (!completedLevels.contains(currentLevel)) {
      completedLevels.add(currentLevel);
    }

    _currentTapCount = 0;

    final msg = streak > 3 ? '🔥 ${streak}x streak! +$pts' : '+$pts points!';
    notifyListeners();
    return AnswerResult(true, msg, score, streak);
  }

  AnswerResult _handleWrong() {
    streak = 0;
    lives--;
    _currentTapCount = 0;
    notifyListeners();
    return AnswerResult(false, 'Wrong! Try again', score);
  }

  /// Use a hint
  String? useHint() {
    if (hintsRemaining <= 0) return null;
    hintsRemaining--;
    final hint = currentPuzzle.hint?.get('en');
    notifyListeners();
    return hint;
  }

  /// For visual tap-count
  void incrementTapCount() {
    _currentTapCount++;
  }

  int get currentTapCount => _currentTapCount;

  /// Get the next incomplete level
  int get nextLevel {
    for (int i = 0; i < shuffledPuzzles.length; i++) {
      if (!completedLevels.contains(i)) return i;
    }
    return 0; // all completed
  }

  /// Move to next puzzle
  void nextPuzzle() {
    final next = currentLevel + 1;
    if (next < shuffledPuzzles.length) {
      currentLevel = next;
    } else {
      // Find first incomplete
      for (int i = 0; i < shuffledPuzzles.length; i++) {
        if (!completedLevels.contains(i)) {
          currentLevel = i;
          return;
        }
      }
      currentLevel = 0; // all done, restart
    }
    _currentTapCount = 0;
    notifyListeners();
  }

  /// Normalize string for comparison
  static String normalize(String s) {
    return s.toLowerCase().trim().replaceAll(RegExp(r'[^\w\s]'), '');
  }
}

/// Result of an answer check
class AnswerResult {
  final bool correct;
  final String message;
  final int score;
  final int streak;

  AnswerResult(this.correct, this.message, this.score, [this.streak = 0]);
}
