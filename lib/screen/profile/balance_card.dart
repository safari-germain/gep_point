import 'package:flutter/material.dart';
import 'package:gep_point/constants.dart';

enum PointType {
  standard,
  cash,
  notoriete,
}

class VBalanceCard extends StatefulWidget {
  final PointType pointType;
  final String balance;
  final String estimation;
  final VoidCallback? onTap;
  final List<Color>? customGradient;

  const VBalanceCard({
    super.key,
    required this.pointType,
    required this.balance,
    required this.estimation,
    this.onTap,
    this.customGradient,
  });

  @override
  State<VBalanceCard> createState() => _VBalanceCardState();
}

class _VBalanceCardState extends State<VBalanceCard> {
  double _scale = 1;

  void _onTapDown(_) => setState(() => _scale = 0.97);
  void _onTapUp(_) => setState(() => _scale = 1);
  void _onTapCancel() => setState(() => _scale = 1);

  @override
  Widget build(BuildContext context) {
    final gradient = widget.customGradient ?? _getGradient(widget.pointType);
    final icon = _getIcon(widget.pointType);
    final title = _getTitle(widget.pointType);

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
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: gradient.last.withOpacity(0.5),
                blurRadius: 25,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Icon(icon, color: Colors.white, size: 26),
                ],
              ),

              /// BALANCE
              const Text(
                "Balance actuelle",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),

              Text(
                widget.balance,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),

              /// ESTIMATION
              const Text(
                "Estimation du prix",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                widget.estimation,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Color> _getGradient(PointType type) {
    switch (type) {
      case PointType.standard:
        return [
          const Color(0xFF6E4DFF),
          const Color(0xFF896CFE),
          const Color(0xFF5F3DFF),
        ];
      case PointType.cash:
        return [
          const Color(0xFF11998E),
          const Color(0xFF38EF7D),
        ];
      case PointType.notoriete:
        return [
          const Color(0xFFFF512F),
          const Color(0xFFDD2476),
        ];
    }
  }

  IconData _getIcon(PointType type) {
    switch (type) {
      case PointType.standard:
        return Icons.stars_rounded;
      case PointType.cash:
        return Icons.account_balance_wallet_rounded;
      case PointType.notoriete:
        return Icons.emoji_events_rounded;
    }
  }

  String _getTitle(PointType type) {
    switch (type) {
      case PointType.standard:
        return "Point Standard";
      case PointType.cash:
        return "Point Cash";
      case PointType.notoriete:
        return "Point Notoriété";
    }
  }
}
