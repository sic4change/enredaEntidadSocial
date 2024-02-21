
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';

class RoundedPlusShape extends StatelessWidget {
  RoundedPlusShape({
    this.padding = const EdgeInsets.all(11.0),
    this.strokeWidth = 6,
  });

  final EdgeInsetsGeometry? padding;
  final double? strokeWidth;


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding!,
      child: CustomPaint(
        size: Size(5, 5),
        painter: RoundedPlusPainter(
          strokeColor: AppColors.turquoiseBlue,
          strokeWidth: strokeWidth!,
          radius: 5,
        ),
      ),
    );
  }
}

class RoundedPlusPainter extends CustomPainter {
  final Color strokeColor;
  final PaintingStyle paintingStyle;
  final double strokeWidth;
  final double radius;

  RoundedPlusPainter({
    this.strokeColor = Colors.black,
    this.paintingStyle = PaintingStyle.stroke,
    this.strokeWidth = 3,
    this.radius = 10,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = strokeColor
      ..style = paintingStyle
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round; // Set the strokeCap to round

    // Horizontal line
    Path horizontalLine = Path()
      ..moveTo(radius, size.height / 2)
      ..lineTo(size.width - radius, size.height / 2);

    // Vertical line
    Path verticalLine = Path()
      ..moveTo(size.width / 2, radius)
      ..lineTo(size.width / 2, size.height - radius);

    canvas.drawPath(horizontalLine, paint);
    canvas.drawPath(verticalLine, paint);
  }

  @override
  bool shouldRepaint(RoundedPlusPainter oldDelegate) {
    return oldDelegate.strokeColor != strokeColor ||
        oldDelegate.paintingStyle != paintingStyle ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.radius != radius;
  }
}

