import 'package:flutter/material.dart';

class EmvChip extends StatelessWidget {
  final double size;

  const EmvChip({super.key, this.size = 50});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size * 0.75,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: const LinearGradient(
          colors: [
            Color(0xFFE0B56A),
            Color(0xFFB98A3F),
            Color(0xFFF2D28B),
            Color(0xFFB98A3F),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 6,
            offset: const Offset(2, 3),
          ),
        ],
      ),
      child: CustomPaint(
        painter: _ChipPainter(),
      ),
    );
  }
}

class _ChipPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = Colors.brown.shade700
      ..strokeWidth = 1.2;

    final w = size.width;
    final h = size.height;

    // Bordures internes
    canvas.drawRect(
      Rect.fromLTWH(w * 0.1, h * 0.15, w * 0.8, h * 0.7),
      paintLine,
    );

    // Lignes verticales
    canvas.drawLine(Offset(w * 0.4, h * 0.15), Offset(w * 0.4, h * 0.85), paintLine);

    canvas.drawLine(Offset(w * 0.6, h * 0.15), Offset(w * 0.6, h * 0.85), paintLine);

    // Lignes horizontales
    canvas.drawLine(Offset(w * 0.1, h * 0.4), Offset(w * 0.9, h * 0.4), paintLine);

    canvas.drawLine(Offset(w * 0.1, h * 0.6), Offset(w * 0.9, h * 0.6), paintLine);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
