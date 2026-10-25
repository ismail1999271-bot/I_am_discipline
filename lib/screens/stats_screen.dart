import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:i_am_disiplin/models/app_models.dart';
import 'package:i_am_disiplin/services/store.dart';
import 'package:i_am_disiplin/services/xp_engine.dart';
import 'package:i_am_disiplin/widgets/common.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: AppStore.I,
      builder: (context, _) {
        final week = _week();
        final month = _month();
        final spots = _xp();
        var maxY = 10.0;
        for (final s in spots) {
          if (s.y > maxY) maxY = s.y;
        }
        return Scaffold(
          appBar: AppBar(title: const Text('GRAFİK')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SectionTitle('HAFTALIK'),
              const SizedBox(height: 8),
              SizedBox(height: 180, child: _bars(context, week, const ['', '', '', '', '', '', ''])),
              const SizedBox(height: 6),
              const Text('Son 7 gün. Tamamlama yüzdesi.', style: TextStyle(color: Colors.white54)),
              const SizedBox(height: 22),
              const SectionTitle('AYLIK'),
              const SizedBox(height: 8),
              SizedBox(height: 180, child: _bars(context, month, const ['3 hf', '2 hf', '1 hf', 'Bu'])),
              const SizedBox(height: 22),
              const SectionTitle('XP'),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    minY: 0,
                    maxY: maxY * 1.15,
                    minX: 0,
                    maxX: 13,
                    gridData: const FlGridData(show: false),
                    borderData: FlBorderData(show: false),
                    lineTouchData: const LineTouchData(enabled: false),
                    titlesData: const FlTitlesData(
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: false,
                        color: gold(context),
                        barWidth: 2,
                        dotData: const FlDotData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
              const Text('Son 14 günün XP toplamı.', style: TextStyle(color: Colors.white54)),
            ],
          ),
        );
      },
    );
  }

  Widget _bars(BuildContext context, List<double> values, List<String> labels) {
    return BarChart(
      BarChartData(
        maxY: 100,
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, _) {
                final i = v.toInt();
                if (i < 0 || i >= labels.length || labels[i].isEmpty) {
                  if (values.length == 7 && i >= 0 && i < 7) {
                    final day = dateOnly(DateTime.now()).subtract(Duration(days: 6 - i));
                    return Text(dayLabels[day.weekday - 1], style: const TextStyle(color: Colors.white54, fontSize: 10));
                  }
                  return const SizedBox.shrink();
                }
                return Text(labels[i], style: const TextStyle(color: Colors.white54, fontSize: 10));
              },
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < values.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: values[i],
                  width: 14,
                  color: gold(context),
                  borderRadius: BorderRadius.zero,
                ),
              ],
            ),
        ],
      ),
    );
  }

  List<double> _week() {
    final now = dateOnly(DateTime.now());
    return [for (var i = 6; i >= 0; i--) _percent(now.subtract(Duration(days: i)))];
  }

  List<double> _month() {
    final now = dateOnly(DateTime.now());
    final out = <double>[];
    for (var w = 3; w >= 0; w--) {
      var sum = 0.0;
      var n = 0;
      for (var d = 6; d >= 0; d--) {
        final day = now.subtract(Duration(days: w * 7 + d));
        final scheduled = AppStore.I.habitsOn(day);
        if (scheduled.isEmpty) continue;
        n += 1;
        sum += _percent(day);
      }
      out.add(n == 0 ? 0 : sum / n);
    }
    return out;
  }

  double _percent(DateTime day) {
    final scheduled = AppStore.I.habitsOn(day);
    if (scheduled.isEmpty) return 0;
    final done = scheduled.where((h) => AppStore.I.isChecked(h.id, day)).length;
    return done / scheduled.length * 100;
  }

  List<FlSpot> _xp() {
    final now = dateOnly(DateTime.now());
    final spots = <FlSpot>[];
    for (var i = 0; i < 14; i++) {
      final day = now.subtract(Duration(days: 13 - i));
      spots.add(FlSpot(i.toDouble(), AppStore.I.xpAt(day).xp.toDouble()));
    }
    if (spots.length < 2) {
      return const [FlSpot(0, 0), FlSpot(1, 0)];
    }
    return spots;
  }
}
