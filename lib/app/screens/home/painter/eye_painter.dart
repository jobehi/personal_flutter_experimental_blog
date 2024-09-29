import 'package:flutter/material.dart';

class EyePainter extends CustomPainter {
  static const strokeScalingFactor = 70;

  final Offset mousePositionPercentage;

  /// the eyelid position is a value between 0 and 1
  /// - 0 means the eye is fully open
  /// - 1 means the eye is fully closed
  final double eyelidPosition;
  EyePainter(
      {required this.mousePositionPercentage, this.eyelidPosition = 0.0});

  @override
  void paint(Canvas canvas, Size size) {
    Paint getPaint({required bool withGradient}) {
      final gradientShader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [0.0, 0.5, 0.7],
        colors: [Colors.white, Colors.white, Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

      return Paint()
        ..color = Colors.white
        ..strokeWidth = size.width / strokeScalingFactor
        ..style = PaintingStyle.stroke
        ..shader = withGradient ? gradientShader : null;
    }

    // Draw eyebrow
    final eyebrowPaint = getPaint(withGradient: false);
    eyebrowPaint.strokeWidth = size.width / (strokeScalingFactor * 0.7);
    final eyebrowPath = Path();

    final eyeBrowCurveMouse = mousePositionPercentage.dy * size.height / 4;

    eyebrowPath.moveTo(0, size.height / 4);
    eyebrowPath.quadraticBezierTo(
      size.width / 2,
      eyeBrowCurveMouse,
      size.width,
      size.height / 4,
    );

    canvas.drawPath(eyebrowPath, eyebrowPaint);

    // Define the paint for the eyelid
    var eyelidpaint = getPaint(withGradient: true);

    // Define the path for the eyelid
    var eyelidPath = Path();

    // Starting point for the eyelid path
    eyelidPath.moveTo(0, size.height / 2);

    // Control point and end point for the eyelid animation
    var controlPoint = Offset(size.width / 2, size.height * eyelidPosition);
    var endPoint = Offset(size.width, size.height / 2);

    // Add the quadratic Bézier curve to create the blinking effect
    eyelidPath.quadraticBezierTo(
      controlPoint.dx,
      controlPoint.dy,
      endPoint.dx,
      endPoint.dy,
    );

    eyelidPath.quadraticBezierTo(
      controlPoint.dx,
      size.height,
      0,
      endPoint.dy,
    );

    // Draw the path
    canvas.drawPath(eyelidPath, eyelidpaint);

    canvas.save();
    canvas.clipPath(eyelidPath);

    // The eyeball should not leave the lid area
    final eyeballRadius = size.width / 6;
    final eyeBallLimit = eyeballRadius;

    // Calculate the iris center based on the mouse position
    final irisCenterOffsetX = (mousePositionPercentage.dx * size.width)
        .clamp(eyeBallLimit, size.width - eyeBallLimit);

    final irisCenterOffsetY = (mousePositionPercentage.dy * size.height)
        .clamp(size.height / 2 - eyeBallLimit, size.height / 2 + eyeBallLimit);

    var irisCenter = Offset(
      irisCenterOffsetX,
      irisCenterOffsetY,
    );

    // Define the paint for the iris
    var irisPaint = getPaint(withGradient: false);
    irisPaint.strokeWidth = size.width / (strokeScalingFactor * 0.75);

    canvas.drawCircle(
        Offset(irisCenter.dx, irisCenter.dy), eyeballRadius, irisPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant EyePainter oldDelegate) {
    return oldDelegate.mousePositionPercentage != mousePositionPercentage ||
        oldDelegate.eyelidPosition != eyelidPosition;
  }
}
