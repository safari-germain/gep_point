import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gep_point/providers/transaction_provider.dart';
import 'package:gep_point/models/m_transaction.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class PointsChart extends StatefulWidget {
  const PointsChart({super.key});

  @override
  State<PointsChart> createState() => _PointsChartState();
}

class _PointsChartState extends State<PointsChart> {
  String _selectedPointType = 'standard'; // 'standard' or 'notoriete'

  String _selectedTimeFilter = 'week'; // 'week', 'year', 'custom'
  DateTimeRange? _customDateRange;

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

    // Appliquer le filtre de temps
    final now = DateTime.now();
    final startDate = _getStartDateForFilter(now);

    final timeFilteredTransactions = filteredTransactions.where((t) {
      return t.createdAt.isAfter(startDate) && t.createdAt.isBefore(now);
    }).toList();

    final spots = _generateSpots(timeFilteredTransactions, now, startDate);

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
          const SizedBox(height: 12),
          _buildTimeFilter(theme),
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
                      color: _selectedPointType == 'standard' ? theme.colorScheme.primary : theme.colorScheme.tertiary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      belowBarData: BarAreaData(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            (_selectedPointType == 'standard' ? theme.colorScheme.primary : theme.colorScheme.tertiary)
                                .withOpacity(0.3),
                            (_selectedPointType == 'standard' ? theme.colorScheme.primary : theme.colorScheme.tertiary)
                                .withOpacity(0.0),
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
          _buildFilterChip('standard', 'standard', theme),
          _buildFilterChip('notoriete', 'Point N.M', theme),
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

  List<FlSpot> _generateSpots(List<TransactionModel> transactions, DateTime now, DateTime startDate) {
    final Map<String, double> dateSum = {};
    final difference = now.difference(startDate).inDays;

    if (_selectedTimeFilter == 'week') {
      // Derniers 7 jours
      for (int i = 0; i < 7; i++) {
        final date = now.subtract(Duration(days: 6 - i));
        dateSum[date.toIso8601String().split('T')[0]] = 0;
      }
    } else if (_selectedTimeFilter == 'year') {
      // Derniers 12 mois
      for (int i = 0; i < 12; i++) {
        final date = now.subtract(Duration(days: now.day - 1 + (30 * (11 - i))));
        dateSum[date.toIso8601String().split('T')[0]] = 0;
      }
    }

    for (var t in transactions) {
      final key = t.createdAt.toIso8601String().split('T')[0];
      dateSum[key] = (dateSum[key] ?? 0) + t.amount;
    }

    List<FlSpot> spots = [];
    int index = 0;
    dateSum.forEach((date, sum) {
      spots.add(FlSpot(index.toDouble(), sum));
      index++;
    });

    return spots;
  }

  DateTime _getStartDateForFilter(DateTime now) {
    if (_selectedTimeFilter == 'week') {
      return now.subtract(const Duration(days: 6));
    } else if (_selectedTimeFilter == 'year') {
      return now.subtract(const Duration(days: 365));
    } else if (_selectedTimeFilter == 'custom' && _customDateRange != null) {
      return _customDateRange!.start;
    }
    return now.subtract(const Duration(days: 6));
  }

  Widget _buildTimeFilter(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildTimeFilterChip('week', 'Cette semaine', theme),
                _buildTimeFilterChip('year', 'Cette année', theme),
                _buildTimeFilterChip('custom', 'Personnalisé', theme),
              ],
            ),
          ),
        ),
        if (_selectedTimeFilter == 'custom')
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: GestureDetector(
              onTap: () async {
                final DateTimeRange? picked = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  currentDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() {
                    _customDateRange = picked;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.colorScheme.primary),
                ),
                child: Text(
                  _customDateRange != null
                      ? '${DateFormat('dd/MM').format(_customDateRange!.start)} - ${DateFormat('dd/MM').format(_customDateRange!.end)}'
                      : 'Sélectionner',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTimeFilterChip(String filter, String label, ThemeData theme) {
    final isSelected = _selectedTimeFilter == filter;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _selectedTimeFilter = filter;
          if (filter != 'custom') {
            _customDateRange = null;
          }
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
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
