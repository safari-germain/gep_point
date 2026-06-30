import 'package:flutter/material.dart';

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
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 150),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: gradient.last.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              /// HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 24),

              /// BALANCE
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Solde Disponible",
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.balance,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),

              /// ESTIMATION
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.estimation,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
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
          const Color(0xFF1877F2), // Bleu Facebook principal
          const Color(0xFF0E5AD6),
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
        return "Point non marchand";
    }
  }
}
