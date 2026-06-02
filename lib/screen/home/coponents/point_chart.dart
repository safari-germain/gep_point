import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gep_point/providers/transaction_provider.dart';
import 'package:gep_point/models/m_transaction.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class PointsChart extends StatefulWidget {
  const PointsChart({super.key});

  @override
  State<PointsChart> createState() => _PointsChartState();
}

class _PointsChartState extends State<PointsChart> {
  String _selectedPointType = 'marchand'; // 'marchand' or 'notoriete'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TransactionProvider>(context, listen: false).fetchTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final transactionProvider = context.watch<TransactionProvider>();
    
    final filteredTransactions = transactionProvider.transactions.where((t) {
      return t.pointType.toLowerCase() == _selectedPointType;
    }).toList();

    final spots = _generateSpots(filteredTransactions);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Activité des Points",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildTypeFilter(theme),
            ],
          ),
          const SizedBox(height: 24),
          if (transactionProvider.isLoading)
            const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()))
          else if (spots.isEmpty)
            const SizedBox(height: 200, child: Center(child: Text("Aucune donnée disponible")))
          else
            AspectRatio(
              aspectRatio: 2.2,
              child: LineChart(
                LineChartData(
                  lineTouchData: LineTouchData(
                    handleBuiltInTouches: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          return LineTooltipItem(
                            '${spot.y.toInt()} pts',
                            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: _calculateInterval(spots),
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                        strokeWidth: 1,
                        dashArray: [5, 5],
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        interval: 1,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          final date = DateTime.now().subtract(Duration(days: 6 - value.toInt()));
                          return SideTitleWidget(
                            space: 10,
                            meta: meta,
                            child: Text(
                              DateFormat('E', 'fr').format(date),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 10,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: _calculateInterval(spots),
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      curveSmoothness: 0.35,
                      color: _selectedPointType == 'marchand' ? theme.colorScheme.primary : theme.colorScheme.tertiary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      belowBarData: BarAreaData(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            (_selectedPointType == 'marchand' ? theme.colorScheme.primary : theme.colorScheme.tertiary).withOpacity(0.3),
                            (_selectedPointType == 'marchand' ? theme.colorScheme.primary : theme.colorScheme.tertiary).withOpacity(0.0),
                          ],
                        ),
                        show: true,
                      ),
                      dotData: const FlDotData(show: false),
                      spots: spots,
                    )
                  ],
                  minX: 0,
                  maxX: 6,
                  minY: 0,
                  maxY: _calculateMaxY(spots),
                ),
                duration: const Duration(milliseconds: 250),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTypeFilter(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildFilterChip('marchand', 'Marchand', theme),
          _buildFilterChip('notoriete', 'Notoriété', theme),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String type, String label, ThemeData theme) {
    final isSelected = _selectedPointType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedPointType = type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  List<FlSpot> _generateSpots(List<TransactionModel> transactions) {
    final now = DateTime.now();
    final Map<int, double> dailySum = {};

    // Initialize with 0 for the last 7 days
    for (int i = 0; i < 7; i++) {
      dailySum[i] = 0;
    }

    for (var t in transactions) {
      final diff = now.difference(t.createdAt).inDays;
      if (diff >= 0 && diff < 7) {
        final index = 6 - diff;
        dailySum[index] = (dailySum[index] ?? 0) + t.amount;
      }
    }

    return dailySum.entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList()
      ..sort((a, b) => a.x.compareTo(b.x));
  }

  double _calculateMaxY(List<FlSpot> spots) {
    if (spots.isEmpty) return 100;
    double max = 0;
    for (var spot in spots) {
      if (spot.y > max) max = spot.y;
    }
    return max == 0 ? 100 : max * 1.2;
  }

  double _calculateInterval(List<FlSpot> spots) {
    double max = _calculateMaxY(spots);
    return max / 5;
  }
}
