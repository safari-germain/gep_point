import 'package:flutter/material.dart';
import 'package:gep_point/components/emv_chip.dart';
import 'package:gep_point/constants.dart';

class VIndicationCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final String typepoint;
  final String rate;
  final VoidCallback onTap;
  final List<Color> gradientColors;

  const VIndicationCard({
    super.key,
    required this.icon,
    required this.label,
    required this.typepoint,
    required this.rate,
    required this.onTap,
    required this.gradientColors,
  });

  @override
  State<VIndicationCard> createState() => _VIndicationCardState();
}

class _VIndicationCardState extends State<VIndicationCard> {
  double _scale = 1;

  void _onTapDown(_) => setState(() => _scale = 0.97);
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
        scale: _scale,
        duration: const Duration(milliseconds: 150),
        child: Container(
          padding: const EdgeInsets.all(defaultPadding),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(defaultBorderRadious),
            boxShadow: [
              BoxShadow(
                color: widget.gradientColors.last.withOpacity(0.5),
                blurRadius: 25,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Top Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.typepoint.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Icon(widget.icon, color: Colors.white, size: 26),
                ],
              ),

              const SizedBox(height: 20),

              /// EMV Chip
              const EmvChip(size: 50),

              const SizedBox(height: 20),

              /// Rate
              Text(
                widget.rate,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),

              const SizedBox(height: 6),

              /// Label
              Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
