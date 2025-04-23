import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../lib/models/study_session.dart';

class ProgressChart extends StatelessWidget {
  final List<StudySession> sessions;
  final int daysToShow;

  const ProgressChart({
    super.key,
    required this.sessions,
    this.daysToShow = 7,
  });

  @override
  Widget build(BuildContext context) {
    final studyData = _prepareChartData();
    final maxY = studyData.values.fold<double>(0, (max, value) => value > max ? value : max);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Study Progress (Last $daysToShow Days)',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxY > 0 ? maxY / 4 : 1,
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= studyData.length) return const Text('');
                          final date = DateTime.now().subtract(Duration(days: daysToShow - value.toInt() - 1));
                          return Text('${date.month}/${date.day}');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text('${value.toInt()}h');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: studyData.entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value);
                      }).toList(),
                      isCurved: true,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildLegend(context),
          ],
        ),
      ),
    );
  }

  Map<int, double> _prepareChartData() {
    final Map<int, double> dailyStudyHours = {};
    final now = DateTime.now();

    // Initialize all days with 0 hours
    for (int i = 0; i < daysToShow; i++) {
      dailyStudyHours[i] = 0;
    }

    // Calculate study hours for each day
    for (final session in sessions) {
      final daysDiff = now.difference(session.startTime).inDays;
      if (daysDiff < daysToShow) {
        final dayIndex = daysToShow - daysDiff - 1;
        dailyStudyHours[dayIndex] = (dailyStudyHours[dayIndex] ?? 0) +
            (session.durationMinutes / 60);
      }
    }

    return dailyStudyHours;
  }

  Widget _buildLegend(BuildContext context) {
    final totalHours = sessions.fold<double>(
      0,
      (sum, session) => sum + (session.durationMinutes ?? 0) / 60,
    );

    final completedSessions = sessions.where((session) => session.isCompleted ?? false).length;
    final completionRate = sessions.isEmpty
        ? 0.0
        : (completedSessions / sessions.length) * 100;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildLegendItem(
          context,
          'Total Hours',
          '${totalHours.toStringAsFixed(1)}h',
          Icons.timer,
        ),
        _buildLegendItem(
          context,
          'Completion Rate',
          '${completionRate.toStringAsFixed(1)}%',
          Icons.check_circle,
        ),
      ],
    );
  }

  Widget _buildLegendItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
} 