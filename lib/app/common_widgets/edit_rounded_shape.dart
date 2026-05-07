import 'dart:math';
import 'package:enreda_empresas/app/values/values.dart';
import 'package:flutter/material.dart';

class RoundedEditShape extends StatelessWidget {
  RoundedEditShape({
    this.padding = const EdgeInsets.all(4.0),
    this.strokeWidth = 1.2,
    this.circleColor,
    this.iconColor,
  });

  final EdgeInsetsGeometry? padding;
  final double strokeWidth;
  final Color? circleColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      padding: padding,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.infinite,
            painter: DashedCirclePainter(
              color: circleColor ?? AppColors.greyLight,
              strokeWidth: strokeWidth,
              dashLength: 3,
              dashGap: 2,
            ),
          ),
          Icon(
            Icons.edit_outlined,
            color: iconColor ?? AppColors.turquoiseBlue,
            size: 18,
          ),
        ],
      ),
    );
  }
}

class DashedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double dashGap;

  DashedCirclePainter({
    required this.color,
    this.strokeWidth = 1.2,
    this.dashLength = 3,
    this.dashGap = 2,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final radius = min(size.width, size.height) / 2;
    final center = Offset(size.width / 2, size.height / 2);
    
    final circumference = 2 * pi * radius;
    final dashCount = (circumference / (dashLength + dashGap)).floor();
    if (dashCount <= 0) return;
    
    final anglePerDash = (2 * pi) / dashCount;
    final dashAngle = (dashLength / circumference) * (2 * pi);

    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * anglePerDash;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        dashAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
