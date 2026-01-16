import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:sirana_milka/services/bar_model.dart';

class BarChartWidget extends StatelessWidget {
  const BarChartWidget({super.key});

  static List<BarModel> _createSampleData() {
    return [
      BarModel(category: "U obradi", value: 30),
      BarModel(category: "Otkazano", value: 50),
      BarModel(category: "Poslano", value: 20),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final data = _createSampleData();

    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          gridData: FlGridData(show: false),
          alignment: BarChartAlignment.spaceAround,
          maxY: data.map((e) => e.value.toDouble()).reduce((a, b) => a > b ? a : b) + 10,

          barTouchData: BarTouchData(enabled: true),

          titlesData: FlTitlesData(
            show: true,
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),

            // Donji X-Axis (kategorije)
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (index < 0 || index >= data.length) return const SizedBox();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      data[index].category,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
              ),
            ),

            // Lijevi Y-Axis (brojevi)
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: false,
                reservedSize: 40,
              ),
            ),
          ),

          borderData: FlBorderData(show: false),
          barGroups: List.generate(data.length, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: data[i].value.toDouble(),
                  color: Color(0xffACD6F2),
                  width: 85,
                  borderRadius: BorderRadius.circular(16),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
