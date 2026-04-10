import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/transaction.dart';

class SpendingPieChart extends StatelessWidget {
  final List<Transaction> transactions;

  const SpendingPieChart({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final Map<String, double> categoryTotals = {};

    for (var t in transactions) {
      final key = t.category.displayName;
      categoryTotals[key] = (categoryTotals[key] ?? 0) + t.amount;
    }

    final colors = [
      Colors.blue,
      Colors.orange,
      Colors.green,
      Colors.red,
      Colors.purple,
      Colors.teal,
    ];

    final entries = categoryTotals.entries.toList();

    final sections = List.generate(entries.length, (index) {
      final entry = entries[index];

      return PieChartSectionData(
        color: colors[index % colors.length], // 🎨 different colors
        value: entry.value,
        title: entry.value > 1500
            ? '${entry.key}\n₹${entry.value.toInt()}'
            : '',
        radius: 70,
      );
    });

    return AspectRatio(
      aspectRatio: 1.3,
      child: PieChart(
        PieChartData(
          sections: sections,
          sectionsSpace: 2,
          centerSpaceRadius: 30,
        ),
      ),
    );
  }
}