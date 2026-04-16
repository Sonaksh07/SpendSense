import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/transaction.dart';

class SpendingPieChart extends StatelessWidget {
  final List<Transaction> transactions;

  const SpendingPieChart({super.key, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final Map<String, double> categoryTotals = {};

    // 🔹 Calculate totals
    for (var t in transactions) {
      final key = t.category.displayName;
      categoryTotals[key] = (categoryTotals[key] ?? 0) + t.amount;
    }

    final entries = categoryTotals.entries.toList();

    // 🔹 Total amount
    final totalAmount =
    categoryTotals.values.fold(0.0, (a, b) => a + b);

    // 🔹 Gradient-style color pairs
    final baseColors = [
      [Colors.blue.shade300, Colors.blue.shade700],
      [Colors.orange.shade300, Colors.orange.shade700],
      [Colors.green.shade300, Colors.green.shade700],
      [Colors.red.shade300, Colors.red.shade700],
      [Colors.purple.shade300, Colors.purple.shade700],
      [Colors.teal.shade300, Colors.teal.shade700],
    ];

    // 🔥 Pie sections
    final sections = List.generate(entries.length, (index) {
      final entry = entries[index];
      final gradient = baseColors[index % baseColors.length];

      return PieChartSectionData(
        value: entry.value,
        title: '',
        radius: 65,
        color: gradient[1], // main color
        borderSide: BorderSide(
          color: gradient[0], // lighter border = gradient feel
          width: 2,
        ),
      );
    });

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
          )
        ],
      ),
      child: Column(
        children: [
          // 🔥 DONUT CHART WITH CENTER TEXT
          SizedBox(
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sections: sections,
                    sectionsSpace: 6,
                    centerSpaceRadius: 55,
                    startDegreeOffset: -90,
                  ),
                ),

                // 🔥 CENTER TEXT
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Total",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      "₹${totalAmount.toInt()}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 🔥 LEGEND (CLEAN)
          Column(
            children: List.generate(entries.length, (index) {
              final entry = entries[index];
              final gradient = baseColors[index % baseColors.length];

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: gradient[1],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        entry.key,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    Text(
                      '₹${entry.value.toInt()}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}