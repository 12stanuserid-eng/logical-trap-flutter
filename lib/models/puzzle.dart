/// Bilingual text pair
class Bilingual {
  final String en;
  final String hi;

  const Bilingual({required this.en, required this.hi});

  factory Bilingual.fromJson(Map<String, dynamic> json) {
    return Bilingual(
      en: json['en'] as String? ?? '',
      hi: json['hi'] as String? ?? json['en'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'en': en, 'hi': hi};

  String get(String lang) => lang == 'hi' ? hi : en;
}

/// Visual element types
enum VisualElementType { emoji, shape, text, button, line }

/// Visual element in a scene
class VisualElement {
  final String id;
  final VisualElementType type;
  final double x; // percentage 0-100
  final double y;
  final double? w; // width
  final double? h; // height
  final String? color;
  final String? shape; // 'circle', 'rounded', 'square'
  final String? border;
  final String? content; // emoji or text content
  final Bilingual? textContent; // for text type elements
  final double? size; // font size
  final int? z;
  final bool interact;
  final bool correct;
  final String? animate;
  final double? rotate;
  final bool bold;
  final String? shadow;

  const VisualElement({
    required this.id,
    this.type = VisualElementType.emoji,
    required this.x,
    required this.y,
    this.w,
    this.h,
    this.color,
    this.shape,
    this.border,
    this.content,
    this.textContent,
    this.size,
    this.z,
    this.interact = false,
    this.correct = false,
    this.animate,
    this.rotate,
    this.bold = false,
    this.shadow,
  });

  factory VisualElement.fromJson(Map<String, dynamic> json) {
    return VisualElement(
      id: json['id'] as String? ?? '',
      type: _parseType(json['type'] as String? ?? 'emoji'),
      x: (json['x'] as num?)?.toDouble() ?? 50,
      y: (json['y'] as num?)?.toDouble() ?? 50,
      w: (json['w'] as num?)?.toDouble(),
      h: (json['h'] as num?)?.toDouble(),
      color: json['color'] as String?,
      shape: json['shape'] as String?,
      border: json['border'] as String?,
      content: json['content'] as String?,
      textContent: json['content'] is Map
          ? Bilingual.fromJson(json['content'] as Map<String, dynamic>)
          : null,
      size: (json['size'] as num?)?.toDouble(),
      z: json['z'] as int?,
      interact: json['interact'] == 'tap' || json['interact'] == true,
      correct: json['correct'] == true,
      animate: json['animate'] as String?,
      rotate: (json['rotate'] as num?)?.toDouble(),
      bold: json['bold'] == true,
      shadow: json['shadow'] as String?,
    );
  }

  static VisualElementType _parseType(String t) {
    switch (t) {
      case 'shape': return VisualElementType.shape;
      case 'text': return VisualElementType.text;
      case 'button': return VisualElementType.button;
      case 'line': return VisualElementType.line;
      default: return VisualElementType.emoji;
    }
  }
}

/// Interaction type for visual puzzles
enum InteractionType { tapCorrect, tapCount, tapAny }

/// Visual scene definition
class VisualScene {
  final String bg;
  final InteractionType interaction;
  final List<VisualElement> elements;

  const VisualScene({
    required this.bg,
    required this.interaction,
    required this.elements,
  });

  factory VisualScene.fromJson(Map<String, dynamic> json) {
    return VisualScene(
      bg: json['bg'] as String? ?? '#FFFFFF',
      interaction: _parseInteraction(json['interaction']?['type'] as String? ?? 'tap-correct'),
      elements: (json['elements'] as List<dynamic>?)
              ?.map((e) => VisualElement.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  static InteractionType _parseInteraction(String t) {
    switch (t) {
      case 'tap-count': return InteractionType.tapCount;
      case 'tap-any': return InteractionType.tapAny;
      default: return InteractionType.tapCorrect;
    }
  }
}

/// Puzzle categories
enum PuzzleCategory { logic, trick, math, observation, word, memory, speed, lateral }

/// Complete puzzle model
class Puzzle {
  final String id;
  final PuzzleCategory category;
  final String title;
  final String type; // 'visual', 'choice', 'text', 'math'
  final int difficulty;
  final Bilingual question;
  final Bilingual answer;
  final Bilingual? hint;
  final List<Bilingual>? options;
  final VisualScene? visual;

  const Puzzle({
    required this.id,
    required this.category,
    required this.title,
    required this.type,
    this.difficulty = 1,
    required this.question,
    required this.answer,
    this.hint,
    this.options,
    this.visual,
  });

  factory Puzzle.fromJson(Map<String, dynamic> json) {
    return Puzzle(
      id: json['id'] as String? ?? '',
      category: _parseCategory(json['category'] as String? ?? 'logic'),
      title: json['title'] as String? ?? '',
      type: json['type'] as String? ?? 'text',
      difficulty: (json['difficulty'] as num?)?.toInt() ?? 1,
      question: Bilingual.fromJson(json['question'] as Map<String, dynamic>),
      answer: Bilingual.fromJson(json['answer'] as Map<String, dynamic>),
      hint: json['hint'] != null
          ? Bilingual.fromJson(json['hint'] as Map<String, dynamic>)
          : null,
      options: (json['options'] as List<dynamic>?)
          ?.map((o) => Bilingual.fromJson(o as Map<String, dynamic>))
          .toList(),
      visual: json['visual'] != null
          ? VisualScene.fromJson(json['visual'] as Map<String, dynamic>)
          : null,
    );
  }

  static PuzzleCategory _parseCategory(String c) {
    switch (c) {
      case 'trick': return PuzzleCategory.trick;
      case 'math': return PuzzleCategory.math;
      case 'observation': return PuzzleCategory.observation;
      case 'word': return PuzzleCategory.word;
      case 'memory': return PuzzleCategory.memory;
      case 'speed': return PuzzleCategory.speed;
      case 'lateral': return PuzzleCategory.lateral;
      default: return PuzzleCategory.logic;
    }
  }
}
