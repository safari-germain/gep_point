import 'package:flutter/material.dart';
import 'package:gep_point/constants.dart';

class PointBadget extends StatelessWidget {
  final double points;

  const PointBadget({super.key, required this.points});

  String getLevel(double points) {
  if (points >= 100001) return "Master";
  if (points >= 10001) return "Diamond";
  if (points >= 1001) return "Gold";
  if (points >= 101) return "Silver";
  return "Bronze";
}

int getStars(double points) {
  if (points >= 100001) return 5;
  if (points >= 10001) return 4;
  if (points >= 1001) return 3;
  if (points >= 101) return 2;
  return 1;
}

  @override
  Widget build(BuildContext context) {
    final level = getLevel(points);
    final stars = getStars(points);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient:const LinearGradient(
        colors: [
      Color(0xFFFFC371),
      Color(0xFFFF5F6D),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.6 : 0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Niveau
            Icon(Icons.rectangle,color: primaryColor, size: 40,),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,

              children: [
                
                Text(
                  ' Niveau: $level',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
      
            const SizedBox(height: 6),
      
            // 🔹 Étoiles
            Row(
              children: List.generate(
                stars,
                (index) =>  Icon(
                  Icons.star_rounded,
                  color: primaryColor,
                  size: 20+((index+1)*5),
                ),
              ),
            ),
      
            const SizedBox(height: 12),
      
            // 🔹 Points
            Row(
              children: [
                const Icon(Icons.stars_rounded, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  "${points.toStringAsFixed(0)} PTS",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}