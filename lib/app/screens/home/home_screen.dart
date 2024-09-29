import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'widgets/blinking_eye_widget.dart';
import 'widgets/leaving_text.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  bool isInDangerZone = false;

  // Current and target eye positions, normalized between 0 and 1
  Offset _currentEyePosition = const Offset(0.5, 0.5);
  Offset _targetEyePosition = const Offset(0.5, 0.5);

  // Smoothing factor for movement interpolation
  final _smoothingFactor = 0.05;
  final eyeSize = 200.0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  /// Ticker callback to update the eye's position smoothly
  void _onTick(Duration elapsed) {
    final newPosition = Offset.lerp(
      _currentEyePosition,
      _targetEyePosition,
      _smoothingFactor,
    );

    if (newPosition != null && newPosition != _currentEyePosition) {
      setState(() {
        _currentEyePosition = newPosition;
      });
    }
  }

  /// Updates the target eye position with clamped values
  void _updateTargetPosition(Offset normalizedPosition) {
    if (!isInDangerZone) {
      _detectsMouseLeaving(normalizedPosition);
    }

    final clampedPosition = Offset(
      normalizedPosition.dx.clamp(0.0, 1.0),
      normalizedPosition.dy.clamp(0.0, 1.0),
    );

    if (clampedPosition != _targetEyePosition) {
      _targetEyePosition = clampedPosition;
    }
  }

  /// Normalizes the position based on the provided size
  Offset _normalizePosition(Offset position, Size size) {
    return Offset(
      position.dx / size.width,
      position.dy / size.height,
    );
  }

  void _detectsMouseLeaving(Offset position) {
    /// checks for 5 seconds if the mouse is in the danger zone
    final dangerZoneRect = Rect.fromCircle(
      center: position,
      radius: 0.2,
    );

    /// exist zone
    const topLeftCorner = Offset(0, 0);

    final isLeaving = dangerZoneRect.contains(topLeftCorner);

    if (isLeaving) {
      setState(() {
        isInDangerZone = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return MouseRegion(
          onHover: (event) {
            final normalized =
                _normalizePosition(event.localPosition, constraints.biggest);
            _updateTargetPosition(normalized);
          },
          child: GestureDetector(
            onPanUpdate: (details) {
              final normalized = _normalizePosition(
                  details.localPosition, constraints.biggest);
              _updateTargetPosition(normalized);
            },
            child: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: eyeSize,
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: BlinkingEyeAnimation(
                          mousePositionPercentage: _currentEyePosition,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (isInDangerZone) const LeavingText(),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
