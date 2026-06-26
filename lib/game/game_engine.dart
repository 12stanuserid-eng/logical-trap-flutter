import 'dart:math';
import 'package:flutter/material.dart';
import 'package:logical_trap_game/models/puzzle.dart';
import 'package:logical_trap_game/data/puzzles.dart';

/// Core game state manager — simplified for visual-only interaction
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
  bool _levelJustCompleted = false;

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
  bool get levelJustCompleted => _levelJustCompleted;
  int get currentTapCount => _currentTapCount;

  /// Initialize/reset game
  void init() {
    score = 0;
    lives = 3;
    hintsRemaining = 3;
    streak = 0;
    currentLevel = 0;
    completedLevels.clear();
    _currentTapCount = 0;
    _levelJustCompleted = false;
    _shuffledPuzzles = List.from(puzzles)..shuffle(Random());
    notifyListeners();
  }

  /// Start a fresh game without shuffling (for level select)
  void startFromLevel(int level) {
    if (_shuffledPuzzles == null) {
      _shuffledPuzzles = List.from(puzzles)..shuffle(Random());
    }
    score = 0;
    lives = 3;
    hintsRemaining = 3;
    streak = 0;
    currentLevel = level;
    _currentTapCount = 0;
    _levelJustCompleted = false;
    notifyListeners();
  }

  /// Load a specific level (for level select)
  void loadLevel(int index) {
    if (index < shuffledPuzzles.length) {
      currentLevel = index;
      _currentTapCount = 0;
      _levelJustCompleted = false;
      notifyListeners();
    }
  }

  /// Handle tapping the correct element
  AnswerResult handleCorrectTap() {
    final puzzle = currentPuzzle;
    streak++;
    final bonus = streak > 3 ? 50 : 0;
    final pts = (puzzle.difficulty * 100) + bonus;
    score += pts;

    if (!completedLevels.contains(currentLevel)) {
      completedLevels.add(currentLevel);
    }

    _currentTapCount = 0;
    _levelJustCompleted = true;

    final msg = streak > 3 ? '🔥 ${streak}x Streak!' : '✓ Correct!';
    notifyListeners();
    return AnswerResult(true, msg, score, streak, pts);
  }

  /// Handle tapping a wrong element
  AnswerResult handleWrongTap() {
    streak = 0;
    lives--;
    _currentTapCount = 0;
    notifyListeners();
    return AnswerResult(false, '✗ Oops!', score);
  }

  /// Handle shake detection for shake-type puzzles
  AnswerResult handleShake() {
    return handleCorrectTap();
  }

  /// Increment tap count for tapCount puzzles
  void incrementTapCount() {
    _currentTapCount++;
    notifyListeners();
  }

  /// Get the needed tap count for the current tapCount puzzle
  int get neededTapCount {
    final answer = currentPuzzle.answer.get('en');
    return int.tryParse(answer) ?? 1;
  }

  /// Use a hint
  String? useHint() {
    if (hintsRemaining <= 0) return null;
    hintsRemaining--;
    final hint = currentPuzzle.hint?.get('en');
    notifyListeners();
    return hint;
  }

  /// Get the next incomplete level
  int get nextLevel {
    for (int i = 0; i < shuffledPuzzles.length; i++) {
      if (!completedLevels.contains(i)) return i;
    }
    return 0;
  }

  /// Move to next puzzle
  void nextPuzzle() {
    _levelJustCompleted = false;
    final next = currentLevel + 1;
    if (next < shuffledPuzzles.length) {
      currentLevel = next;
    } else {
      // Find first incomplete
      for (int i = 0; i < shuffledPuzzles.length; i++) {
        if (!completedLevels.contains(i)) {
          currentLevel = i;
          _currentTapCount = 0;
          notifyListeners();
          return;
        }
      }
      currentLevel = 0; // all done, restart
    }
    _currentTapCount = 0;
    notifyListeners();
  }

  /// Clear just completed flag (after animation)
  void clearLevelJustCompleted() {
    _levelJustCompleted = false;
  }
}

/// Result of an answer check
class AnswerResult {
  final bool correct;
  final String message;
  final int score;
  final int streak;
  final int points;

  AnswerResult(this.correct, this.message, this.score, [this.streak = 0, this.points = 0]);
}
