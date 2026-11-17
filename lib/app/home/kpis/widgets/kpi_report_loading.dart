import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../kpi_colors.dart';

/// Animación de carga de los informes de KPIs: un documento con barras que
/// crecen y decrecen, un mensaje y, si se conoce, el avance.
class KpiReportLoading extends StatefulWidget {
  final String title;
  final String? message;

  /// Avance entre 0 y 1, o `null` si no se conoce.
  final double? progress;

  const KpiReportLoading({
    Key? key,
    required this.title,
    this.message,
    this.progress,
  }) : super(key: key);

  @override
  State<KpiReportLoading> createState() => _KpiReportLoadingState();
}

class _KpiReportLoadingState extends State<KpiReportLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = widget.progress;
    return Container(
      width: 340,
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: KpiColors.primaryDark.withValues(alpha: 0.12),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => CustomPaint(
              size: const Size(84, 100),
              painter: _DocumentPainter(_controller.value),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            widget.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: KpiColors.primaryDark,
              decoration: TextDecoration.none,
            ),
          ),
          if (widget.message != null) ...[
            const SizedBox(height: 6),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Text(
                widget.message!,
                key: ValueKey(widget.message),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: KpiColors.secondaryText,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ],
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: progress == null
                ? const LinearProgressIndicator(
                    minHeight: 6,
                    color: KpiColors.turquoise,
                    backgroundColor: KpiColors.divider,
                  )
                : TweenAnimationBuilder<double>(
                    tween: Tween(end: progress.clamp(0, 1)),
                    duration: const Duration(milliseconds: 300),
                    builder: (context, value, _) => LinearProgressIndicator(
                      value: value,
                      minHeight: 6,
                      color: KpiColors.turquoise,
                      backgroundColor: KpiColors.divider,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Hoja con la esquina doblada y cuatro barras animadas con desfase.
class _DocumentPainter extends CustomPainter {
  final double t;
  _DocumentPainter(this.t);

  static const _barColors = [
    KpiColors.primaryDark,
    KpiColors.turquoise,
    KpiColors.yellow,
    KpiColors.lightTurquoise,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    const fold = 20.0;

    final sheet = Path()
      ..moveTo(6, 0)
      ..lineTo(w - fold, 0)
      ..lineTo(w, fold)
      ..lineTo(w, h - 6)
      ..quadraticBezierTo(w, h, w - 6, h)
      ..lineTo(6, h)
      ..quadraticBezierTo(0, h, 0, h - 6)
      ..lineTo(0, 6)
      ..quadraticBezierTo(0, 0, 6, 0)
      ..close();
    canvas.drawPath(sheet, Paint()..color = const Color(0xFFF2F7F8));
    canvas.drawPath(
      sheet,
      Paint()
        ..color = KpiColors.borderLight
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w - fold, 0)
        ..lineTo(w - fold, fold - 4)
        ..quadraticBezierTo(w - fold, fold, w - fold + 4, fold)
        ..lineTo(w, fold)
        ..close(),
      Paint()..color = KpiColors.borderLight,
    );

    // Líneas de "texto"
    final line = Paint()
      ..color = KpiColors.borderLight
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(14, 16), Offset(w - fold - 10, 16), line);
    canvas.drawLine(const Offset(14, 27), Offset(w * 0.5, 27), line);

    // Barras de la gráfica
    const left = 14.0;
    final bottom = h - 14;
    const maxBar = 52.0;
    final barW = (w - 2 * left - 3 * 6) / 4;
    for (int i = 0; i < 4; i++) {
      final phase = (t + i * 0.18) * 2 * math.pi;
      final v = 0.35 + 0.65 * (0.5 + 0.5 * math.sin(phase));
      final x = left + i * (barW + 6);
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(x, bottom - maxBar * v, barW, maxBar * v),
          topLeft: const Radius.circular(3),
          topRight: const Radius.circular(3),
        ),
        Paint()..color = _barColors[i],
      );
    }
    canvas.drawLine(
      Offset(left - 4, bottom + 1),
      Offset(w - left + 4, bottom + 1),
      Paint()
        ..color = KpiColors.secondaryText
        ..strokeWidth = 1.5,
    );
  }

  @override
  bool shouldRepaint(_DocumentPainter old) => old.t != t;
}
