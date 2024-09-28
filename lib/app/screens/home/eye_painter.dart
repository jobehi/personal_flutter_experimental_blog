import 'package:flutter/material.dart';

class EyePainter extends CustomPainter {
  final Offset mousePositionPercentage;

  EyePainter({required this.mousePositionPercentage});

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
        ..strokeWidth = 4.0
        ..style = PaintingStyle.stroke
        ..shader = withGradient ? gradientShader : null;
    }

    // Define the paint
    var eyelidpaint = getPaint(withGradient: true);

    // Define the path
    var eyelidPath = Path();

    // Starting point for the eyelid path
    eyelidPath.moveTo(0, size.height / 2);

    // Control point and end point
    var controlPoint = Offset(size.width / 2, 0);
    var endPoint = Offset(size.width, size.height / 2);

    // Add the quadratic Bézier curve
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

    // the eyes ball should not leave the lid area
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

    // Define the paint for the Iris
    var irisPaint = getPaint(withGradient: false);
    canvas.drawCircle(
        Offset(irisCenter.dx, irisCenter.dy), eyeballRadius, irisPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant EyePainter oldDelegate) {
    return oldDelegate.mousePositionPercentage != mousePositionPercentage;
  }
}
