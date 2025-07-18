import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lostu/services/analytics_service.dart';

class DashboardPage extends StatelessWidget {
  DashboardPage({super.key});
  final AnalyticsService _analyticsService = AnalyticsService();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Dashboard",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: "Merriweather",
            ),
          ),
          const SizedBox(height: 24),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: StreamBuilder<int>(
                    stream: _analyticsService.totalNumberOfLostItemsStream(),
                    builder: (context, snapshot) => _DashboardCard(
                      title: "Lost Items",
                      value: snapshot.data?.toString() ?? '-',
                      icon: Icons.report_gmailerrorred,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StreamBuilder<int>(
                    stream: _analyticsService.totalNumberOfFoundItemsStream(),
                    builder: (context, snapshot) => _DashboardCard(
                      title: "Found Items",
                      value: snapshot.data?.toString() ?? '-',
                      icon: Icons.check_circle,
                      color: Colors.blue,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: StreamBuilder<double>(
                    stream: _analyticsService.successRateOfClaimsStream(),
                    builder: (context, snapshot) => _DashboardCard(
                      title: "Claim Success",
                      value: snapshot.hasData
                          ? "${(snapshot.data! * 100).toStringAsFixed(1)}%"
                          : '-',
                      icon: Icons.verified,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            "Most Frequently Lost Item Categories",
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                height: 275,
                child: StreamBuilder<Map<String, int>>(
                  stream: _analyticsService
                      .mostFrequentlyLostItemCategoriesStream(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final sorted = snapshot.data!.entries.toList()
                      ..sort((a, b) => b.value.compareTo(a.value));
                    final top5 = sorted.take(5).toList();
                    return BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: top5.isNotEmpty
                            ? (top5.first.value + 2).toDouble()
                            : 10,
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            tooltipBorderRadius: BorderRadius.circular(8),
                            tooltipPadding: const EdgeInsets.all(8),
                            tooltipMargin: 8,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              return BarTooltipItem(
                                '${top5[groupIndex].key}\n${rod.toY.toInt()} items',
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ),
                        gridData: FlGridData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(fontSize: 12),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 50,
                              interval: 1.0,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                final idx = value.toInt();
                                if (idx < 0 || idx >= top5.length) {
                                  return const SizedBox();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    top5[idx].key,
                                    style: const TextStyle(fontSize: 10),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              },
                            ),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: List.generate(top5.length, (i) {
                          return BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: top5[i].value.toDouble(),
                                color: Colors.redAccent,
                                width: 30,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(5),
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            "Most Frequently Lost Item Locations",
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                height: 275,
                child: StreamBuilder<Map<String, int>>(
                  stream: _analyticsService
                      .mostFrequentlyLostItemLocationsStream(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final sorted = snapshot.data!.entries.toList()
                      ..sort((a, b) => b.value.compareTo(a.value));
                    final top5 = sorted.take(5).toList();
                    return BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: top5.isNotEmpty ? (top5.first.value + 2) : 10,
                        barTouchData: BarTouchData(
                          enabled: true,
                          touchTooltipData: BarTouchTooltipData(
                            tooltipBorderRadius: BorderRadius.circular(8),
                            tooltipPadding: const EdgeInsets.all(8),
                            tooltipMargin: 8,
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              return BarTooltipItem(
                                '${top5[groupIndex].key}\n${rod.toY.toInt()} items',
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                        ),
                        gridData: FlGridData(show: false),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                return Text(
                                  value.toInt().toString(),
                                  style: const TextStyle(fontSize: 12),
                                );
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 50,
                              interval: 1.0,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                final idx = value.toInt();
                                if (idx < 0 || idx >= top5.length) {
                                  return const SizedBox();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    top5[idx].key,
                                    style: const TextStyle(fontSize: 10),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              },
                            ),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: List.generate(top5.length, (i) {
                          return BarChartGroupData(
                            x: i,
                            barRods: [
                              BarChartRodData(
                                toY: top5[i].value.toDouble(),
                                color: Colors.blueAccent,
                                width: 30,
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(5),
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _DashboardCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 36),
              const SizedBox(height: 12),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
