import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

/// Detects device shake using accelerometer and wraps child widget
class ShakeDetectorWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback onShake;
  final double threshold;
  final Duration cooldown;

  const ShakeDetectorWidget({
    super.key,
    required this.child,
    required this.onShake,
    this.threshold = 25.0,
    this.cooldown = const Duration(milliseconds: 1000),
  });

  @override
  State<ShakeDetectorWidget> createState() => _ShakeDetectorWidgetState();
}

class _ShakeDetectorWidgetState extends State<ShakeDetectorWidget>
    with SingleTickerProviderStateMixin {
  StreamSubscription<AccelerometerEvent>? _subscription;
  DateTime _lastShake = DateTime.now();
  AnimationController? _shakeController;
  Animation<double>? _shakeAnim;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  void _startListening() {
    _subscription = accelerometerEventStream().listen((event) {
      final now = DateTime.now();
      if (now.difference(_lastShake) < widget.cooldown) return;

      final magnitude = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      final force = (magnitude - 9.8).abs();

      if (force > widget.threshold) {
        _lastShake = now;
        _triggerShake();
      }
    });
  }

  void _triggerShake() {
    _shakeController?.dispose();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _shakeController!, curve: Curves.elasticOut),
    );
    _shakeController!.forward();
    setState(() {});
    widget.onShake();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _shakeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_shakeAnim == null || _shakeController == null || !_shakeController!.isAnimating) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _shakeAnim!,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            sin(_shakeAnim!.value * 2 * pi) * 8,
            cos(_shakeAnim!.value * 2 * pi) * 4,
          ),
          child: widget.child,
        );
      },
    );
  }
}
