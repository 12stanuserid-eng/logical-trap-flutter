import 'package:flutter/material.dart';
import 'package:logical_trap_game/models/puzzle.dart';
import 'package:logical_trap_game/game/game_engine.dart';

/// Renders interactive visual puzzle scenes
class VisualSceneWidget extends StatefulWidget {
  final VisualScene scene;
  final Function(String) onSubmit;

  const VisualSceneWidget({
    super.key,
    required this.scene,
    required this.onSubmit,
  });

  @override
  State<VisualSceneWidget> createState() => _VisualSceneWidgetState();
}

class _VisualSceneWidgetState extends State<VisualSceneWidget>
    with TickerProviderStateMixin {
  final Map<String, AnimationController> _controllers = {};
  final Map<String, Animation<double>> _animations = {};
  String? _wrongElementId;
  bool _submitted = false;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    for (final el in widget.scene.elements) {
      if (el.animate != null) {
        final controller = AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 1500),
        )..repeat(reverse: true);
        _controllers[el.id] = controller;

        switch (el.animate) {
          case 'bounce':
            _animations[el.id] = Tween<double>(begin: 0, end: -8).animate(
              CurvedAnimation(parent: controller, curve: Curves.easeInOut),
            );
            break;
          case 'pulse':
            _animations[el.id] = Tween<double>(begin: 0.9, end: 1.1).animate(
              CurvedAnimation(parent: controller, curve: Curves.easeInOut),
            );
            break;
          case 'glow':
            _animations[el.id] = Tween<double>(begin: 0.7, end: 1.0).animate(
              CurvedAnimation(parent: controller, curve: Curves.easeInOut),
            );
            break;
          case 'wiggle':
            _animations[el.id] = Tween<double>(begin: -3, end: 3).animate(
              CurvedAnimation(parent: controller, curve: Curves.easeInOut),
            );
            break;
          case 'float':
            _animations[el.id] = Tween<double>(begin: 0, end: -5).animate(
              CurvedAnimation(parent: controller, curve: Curves.easeInOut),
            );
            break;
        }
      }
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _handleTap(VisualElement el) {
    if (_submitted) return;

    final engine = GameEngine();
    final puzzle = engine.currentPuzzle;

    if (widget.scene.interaction == InteractionType.tapCorrect) {
      if (el.correct) {
        setState(() => _submitted = true);
        widget.onSubmit(puzzle.answer.get('en'));
      } else {
        setState(() {
          _wrongElementId = el.id;
        });
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) setState(() => _wrongElementId = null);
        });
      }
    } else if (widget.scene.interaction == InteractionType.tapCount && el.correct) {
      engine.incrementTapCount();
      final needed = int.tryParse(puzzle.answer.get('en')) ?? 1;
      if (engine.currentTapCount >= needed) {
        setState(() => _submitted = true);
        widget.onSubmit('$needed');
      } else {
        setState(() {
          // Visual feedback: flash the element
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final sceneWidth = size.width - 32;
    final sceneHeight = sceneWidth * 0.85;

    return Container(
      width: sceneWidth,
      height: sceneHeight,
      decoration: BoxDecoration(
        gradient: _parseGradient(widget.scene.bg),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: widget.scene.elements.map((el) {
          return _buildElement(el, sceneWidth, sceneHeight);
        }).toList(),
      ),
    );
  }

  Widget _buildElement(VisualElement el, double w, double h) {
    final left = (el.x / 100) * w - (el.w ?? 40) / 2;
    final top = (el.y / 100) * h - (el.h ?? 40) / 2;
    final elW = el.w ?? 40;
    final elH = el.h ?? 40;
    final isWrong = _wrongElementId == el.id;

    Widget child;
    switch (el.type) {
      case VisualElementType.emoji:
        child = Text(
          el.content ?? '❓',
          style: TextStyle(fontSize: el.size ?? 28),
          textAlign: TextAlign.center,
        );
        break;
      case VisualElementType.shape:
        child = Container(
          width: elW,
          height: elH,
          decoration: BoxDecoration(
            color: _parseColor(el.color ?? '#888'),
            borderRadius: el.shape == 'circle'
                ? null
                : BorderRadius.circular(12),
            shape: el.shape == 'circle' ? BoxShape.circle : BoxShape.rectangle,
            border: el.border != null ? Border.all(
              color: _parseColor(el.border!.split(' ').last),
              width: 2,
            ) : null,
          ),
        );
        break;
      case VisualElementType.text:
        child = Text(
          el.content ?? '',
          style: TextStyle(
            fontSize: el.size ?? 14,
            color: _parseColor(el.color ?? '#333'),
            fontWeight: el.bold ? FontWeight.bold : FontWeight.normal,
            shadows: el.shadow != null ? [
              Shadow(color: _parseColor(el.shadow!), blurRadius: 4)
            ] : null,
          ),
          textAlign: TextAlign.center,
        );
        break;
      case VisualElementType.button:
        child = Container(
          width: elW,
          height: elH,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _parseColor(el.color ?? '#6C63FF'),
                _parseColor(el.color ?? '#6C63FF').withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: _parseColor(el.color ?? '#6C63FF').withValues(alpha: 0.4),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              el.content ?? '',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
        break;
      case VisualElementType.line:
        child = Container(
          width: elW,
          height: 4,
          decoration: BoxDecoration(
            color: _parseColor(el.color ?? '#333'),
            borderRadius: BorderRadius.circular(2),
          ),
        );
        break;
    }

    // Wrap in animated builder if element has animations
    Widget positioned;
    if (_animations.containsKey(el.id)) {
      positioned = AnimatedBuilder(
        animation: _animations[el.id]!,
        builder: (context, child) {
          double dx = 0, dy = 0, scale = 1;
          final anim = _animations[el.id]!;
          switch (el.animate) {
            case 'bounce':
              dy = anim.value;
              break;
            case 'pulse':
              scale = anim.value;
              break;
            case 'glow':
              break;
            case 'wiggle':
              dx = anim.value;
              break;
            case 'float':
              dy = anim.value;
              break;
          }
          return Transform.translate(
            offset: Offset(dx, dy),
            child: Transform.scale(
              scale: scale,
              child: child,
            ),
          );
        },
        child: child,
      );
    } else {
      positioned = child;
    }

    // Apply rotation
    if (el.rotate != null && el.rotate != 0) {
      positioned = Transform.rotate(
        angle: el.rotate! * 3.14159 / 180,
        child: positioned,
      );
    }

    // Wrap with GestureDetector if interactive
    if (el.interact) {
      positioned = GestureDetector(
        onTap: () => _handleTap(el),
        child: positioned,
      );
    }

    return Positioned(
      left: left,
      top: top,
      width: el.type == VisualElementType.emoji ? null : elW,
      child: positioned,
    );
  }

  Color _parseColor(String color) {
    final buffer = StringBuffer();
    if (color.startsWith('#')) {
      buffer.write('ff');
      buffer.write(color.substring(1));
      return Color(int.parse(buffer.toString(), radix: 16));
    }
    // Handle rgba
    if (color.startsWith('rgba')) {
      final parts = color.replaceAll(RegExp(r'rgba\(|\)|\s'), '').split(',');
      if (parts.length >= 4) {
        return Color.fromRGBO(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
          double.parse(parts[3]),
        );
      }
    }
    // Named colors
    const colors = {
      'white': Colors.white,
      'black': Colors.black,
      'red': Colors.red,
      'green': Colors.green,
      'blue': Colors.blue,
      'yellow': Colors.yellow,
      'orange': Colors.orange,
      'purple': Colors.purple,
      'pink': Colors.pink,
      'brown': Colors.brown,
      'grey': Colors.grey,
      'gray': Colors.grey,
    };
    return colors[color.toLowerCase()] ?? Colors.grey;
  }

  Gradient _parseGradient(String gradient) {
    if (gradient.startsWith('linear-gradient')) {
      final reg = RegExp(r'#[a-fA-F0-9]+');
      final matches = reg.allMatches(gradient).map((m) => m.group(0)!).toList();
      if (matches.length >= 2) {
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: matches.map((c) => _parseColor(c)).toList(),
        );
      }
    }
    return LinearGradient(
      colors: [_parseColor(gradient), _parseColor(gradient)],
    );
  }
}
