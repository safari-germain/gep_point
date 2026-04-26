import 'package:flutter/material.dart';
import 'package:gep_point/constants.dart';

class HolographicCreditCard extends StatefulWidget {
  final String title;
  final String amount;
  final String subtitle;
  final IconData icon;
  final List<Color> baseGradient;
  final VoidCallback? onTap;

  const HolographicCreditCard({
    super.key,
    required this.title,
    required this.amount,
    required this.subtitle,
    required this.icon,
    required this.baseGradient,
    this.onTap,
  });

  @override
  State<HolographicCreditCard> createState() => _HolographicCreditCardState();
}

class _HolographicCreditCardState extends State<HolographicCreditCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _scale = 1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(_) => setState(() => _scale = 0.96);
  void _onTapUp(_) => setState(() => _scale = 1);
  void _onTapCancel() => setState(() => _scale = 1);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 150),
        scale: _scale,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                gradient: LinearGradient(
                  colors: widget.baseGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.baseGradient.last.withOpacity(0.3),
                    blurRadius: 25,
                    offset: const Offset(0, 15),
                  )
                ],
              ),
              child: Stack(
                children: [
                  /// Holographic moving light
                  Positioned.fill(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(26),
                      child: Opacity(
                        opacity: 0.25,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.transparent,
                                Colors.white.withOpacity(0.6),
                                Colors.transparent,
                              ],
                              stops: const [0.3, 0.5, 0.7],
                              begin: Alignment(-1 + 2 * _controller.value, -1),
                              end: Alignment(1 + 2 * _controller.value, 1),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  /// Content
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.title.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Icon(
                            widget.icon,
                            color: Colors.white,
                            size: 28,
                          )
                        ],
                      ),
                      const SizedBox(height: defaultPadding),
                      Text(
                        widget.amount,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: defaultPadding / 2),
                      Text(
                        widget.subtitle,
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
