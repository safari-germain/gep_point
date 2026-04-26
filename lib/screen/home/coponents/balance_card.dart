import 'package:flutter/material.dart';
import 'package:gep_point/constants.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text('Valeur estimée des points', style: TextStyle(color: primaryColor)),
          SizedBox(height: 8),
          Text('\$ 1,250.00', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text('+5.4% cette semaine', style: TextStyle(color: primaryColor)),
        ],
      ),
    );
  }
}
