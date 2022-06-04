import 'package:flutter/material.dart';

class OutlinePainter extends CustomPainter {
  final Gradient gradient;
  final Radius? radius;
  final double strokeWidth;

  OutlinePainter(this.gradient, this.radius, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Rect.fromLTWH(strokeWidth / 2, strokeWidth / 2,
        size.width - strokeWidth, size.height - strokeWidth);
    final RRect rRect = RRect.fromRectAndRadius(rect, radius ?? Radius.zero);
    final Paint paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = gradient.createShader(rect);
    canvas.drawRRect(rRect, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => oldDelegate != this;
}
