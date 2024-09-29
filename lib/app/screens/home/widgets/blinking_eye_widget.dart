import 'package:flutter/material.dart';
import 'package:youssef_el_behi/app/screens/home/painter/eye_painter.dart';
import 'dart:math' as math;

class BlinkingEyeAnimation extends StatefulWidget {
  const BlinkingEyeAnimation(
      {super.key, required this.mousePositionPercentage});

  final Offset mousePositionPercentage;

  @override
  BlinkingEyeAnimationState createState() => BlinkingEyeAnimationState();
}

class BlinkingEyeAnimationState extends State<BlinkingEyeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _eyelidAnimation;
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration:
          const Duration(milliseconds: 100), // Duration for a single blink
    );

    _eyelidAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _startBlinking();
  }

  Future<void> _startBlinking() async {
    while (mounted) {
      // Perform the blink animation
      await _controller.forward();
      await _controller.reverse();

      // Wait for a random duration between 2 to 8 seconds
      final nextBlinkInterval =
          2000 + _random.nextInt(6000); // 2000ms to 6000ms
      await Future.delayed(Duration(milliseconds: nextBlinkInterval));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _eyelidAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: EyePainter(
            mousePositionPercentage: widget.mousePositionPercentage,
            eyelidPosition: _eyelidAnimation.value,
          ),
          child: Container(),
        );
      },
    );
  }
}
