import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:youssef_el_behi/app/screens/home/eye_painter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;

  // Current and target eye positions, normalized between 0 and 1
  Offset _currentEyePosition = const Offset(0.5, 0.5);
  Offset _targetEyePosition = const Offset(0.5, 0.5);

  // Smoothing factor for movement interpolation
  static const double _smoothingFactor = 0.05;

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
                child: SizedBox(
                  width: 200,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: CustomPaint(
                      painter: EyePainter(
                          mousePositionPercentage: _currentEyePosition),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
