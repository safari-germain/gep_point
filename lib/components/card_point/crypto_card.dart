import 'dart:math';
import 'package:flutter/material.dart';

class UltraCryptoCard extends StatefulWidget {
  final String holderName;
  final String cardNumber;
  final String expiry;
  final String balance;
  final List<Color> gradientColors;
  final VoidCallback? onTap;

  const UltraCryptoCard({
    super.key,
    required this.holderName,
    required this.cardNumber,
    required this.expiry,
    required this.balance,
    required this.gradientColors,
    this.onTap,
  });

  @override
  State<UltraCryptoCard> createState() => _UltraCryptoCardState();
}

class _UltraCryptoCardState extends State<UltraCryptoCard> with TickerProviderStateMixin {
  late AnimationController _flipController;
  late AnimationController _shineController;

  bool _isFront = true;

  @override
  void initState() {
    super.initState();

    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _flipController.dispose();
    _shineController.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_isFront) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
    _isFront = !_isFront;

    if (widget.onTap != null) widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flipCard,
      child: AnimatedBuilder(
        animation: _flipController,
        builder: (context, child) {
          final angle = _flipController.value * pi;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: angle <= pi / 2
                ? _buildFront()
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(pi),
                    child: _buildBack(),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildFront() {
    return _buildCardContent(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "CRYPTO BANK",
            style: TextStyle(
              color: Colors.white70,
              letterSpacing: 2,
            ),
          ),
          const Spacer(),
          Text(
            widget.cardNumber,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.holderName.toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
              Text(
                widget.expiry,
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBack() {
    return _buildCardContent(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 40,
            color: Colors.black87,
          ),
          const SizedBox(height: 20),
          const Text(
            "Balance",
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 10),
          Text(
            widget.balance,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardContent({required Widget child}) {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: widget.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.gradientColors.last.withOpacity(0.6),
            blurRadius: 30,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: Stack(
        children: [
          /// Holographic shine
          AnimatedBuilder(
            animation: _shineController,
            builder: (context, _) {
              return Positioned.fill(
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
                        begin: Alignment(-1 + 2 * _shineController.value, -1),
                        end: Alignment(1 + 2 * _shineController.value, 1),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          child,
        ],
      ),
    );
  }
}
