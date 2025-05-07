import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class PieChartWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 70,
        startDegreeOffset: 180,
        sections: [
          PieChartSectionData(value: 60, color: Color(0xFFFFA07A), showTitle: false, radius: 50),
          PieChartSectionData(value: 15, color: Color(0xFFFFD700), showTitle: false, radius: 50),
          PieChartSectionData(value: 10, color: Color(0xFFFFB347), showTitle: false, radius: 50),
          PieChartSectionData(value: 8,  color: Color(0xFFF0E68C), showTitle: false, radius: 50),
          PieChartSectionData(value: 5,  color: Color(0xFFFF7F50), showTitle: false, radius: 50),
          PieChartSectionData(value: 2,  color: Color(0xFFFF6347), showTitle: false, radius: 50),
        ],
      ),
    );
  }
}
