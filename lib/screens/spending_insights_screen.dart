import 'package:flutter/material.dart';
import '../analysis/insight_generator.dart';
import '../models/behavioral_insight.dart';
import '../services/transaction_service.dart';
import '../models/transaction.dart';

class SpendingInsightsScreen extends StatefulWidget {
  const SpendingInsightsScreen({super.key});

  @override
  State<SpendingInsightsScreen> createState() =>
      _SpendingInsightsScreenState();
}

class _SpendingInsightsScreenState extends State<SpendingInsightsScreen> {
  final InsightGenerator _insightGen = InsightGenerator();

  List<BehavioralInsight> _insights = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _generateInsights();
  }

  void _generateInsights() {
    final transactions = TransactionService().transactions;

    if (transactions.isEmpty) {
      setState(() {
        _insights = [];
        _loading = false;
      });
      return;
    }

    // 🔥 Generate simple behavioral patterns from real data
    final patterns = _generateBehavioralPatterns(transactions);

    final insights = _insightGen.generate(
      transactions: transactions,
      behavioralPatterns: patterns,
      lstmForecast: {}, // no mock ML now
    );

    setState(() {
      _insights = insights;
      _loading = false;
    });
  }

  // 🧠 Basic pattern extraction (NO hardcoding now)
  Map<String, dynamic> _generateBehavioralPatterns(
      List<Transaction> transactions) {
    int impulseCount =
        transactions.where((t) => t.isImpulse).length;

    double totalSpent =
        transactions.fold(0.0, (sum, t) => sum + t.amount);

    // Weekend spending
    final weekendTxns = transactions.where((t) {
      return t.timestamp.weekday == DateTime.saturday ||
          t.timestamp.weekday == DateTime.sunday;
    }).toList();

    double weekendSpend =
        weekendTxns.fold(0.0, (sum, t) => sum + t.amount);

    // Late night spending
    final lateNightTxns = transactions.where((t) {
      return t.timestamp.hour >= 23;
    }).toList();

    double lateNightSpend =
        lateNightTxns.fold(0.0, (sum, t) => sum + t.amount);

    return {
      "impulse_count": impulseCount,
      "total_spent": totalSpent,
      "weekend_spend": weekendSpend,
      "late_night_spend": lateNightSpend,
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Spending Insights')),

      body: _insights.isEmpty
          ? const Center(
              child: Text(
                'No insights yet.\nAdd transactions to see patterns 📊',
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _insights.length,
              itemBuilder: (ctx, i) {
                final insight = _insights[i];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: insight.severityColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: insight.severityColor.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        insight.icon,
                        color: insight.severityColor,
                        size: 30,
                      ),
                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              insight.title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: insight.severityColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              insight.description,
                              style:
                                  const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      Chip(
                        label: Text(
                          insight.severity
                              .toString()
                              .split('.')
                              .last,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}