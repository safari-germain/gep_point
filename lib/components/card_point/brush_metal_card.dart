import 'package:flutter/material.dart';

class BrushedMetalCard extends StatefulWidget {
  final Widget child;
  final double height;
  final BorderRadius borderRadius;
  final List<Color>? overlayGradient;

  const BrushedMetalCard({
    super.key,
    required this.child,
    this.height = 220,
    this.borderRadius = const BorderRadius.all(Radius.circular(28)),
    this.overlayGradient,
  });

  @override
  State<BrushedMetalCard> createState() => _BrushedMetalCardState();
}

class _BrushedMetalCardState extends State<BrushedMetalCard> with SingleTickerProviderStateMixin {
  late final AnimationController _shineController;

  @override
  void initState() {
    super.initState();
    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _shineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.0),
            blurRadius: 30,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: widget.borderRadius,
        child: Stack(
          children: [
            /// Métal brossé animé
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _shineController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _BrushedMetalPainter(
                      _shineController.value,
                    ),
                  );
                },
              ),
            ),

            /// Overlay couleur optionnel
            if (widget.overlayGradient != null)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: widget.overlayGradient!,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),

            /// Contenu
            Padding(
              padding: const EdgeInsets.all(24),
              child: widget.child,
            ),
          ],
        ),
      ),
    );
  }
}

class _BrushedMetalPainter extends CustomPainter {
  final double shimmerValue;

  _BrushedMetalPainter(this.shimmerValue);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    /// Base métal
    final basePaint = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0xFFB0B0B0),
          Color(0xFF8E8E8E),
          Color(0xFFD6D6D6),
          Color(0xFF9E9E9E),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect);

    canvas.drawRect(rect, basePaint);

    /// Lignes métal brossé
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;

    for (double y = 0; y < size.height; y += 2) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        linePaint,
      );
    }

    /// Reflet animé
    final shimmerPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          Colors.white.withOpacity(0.3),
          Colors.transparent,
        ],
        stops: const [0.4, 0.5, 0.6],
        begin: Alignment(-1 + 2 * shimmerValue, -1),
        end: Alignment(1 + 2 * shimmerValue, 1),
      ).createShader(rect);

    canvas.drawRect(rect, shimmerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
