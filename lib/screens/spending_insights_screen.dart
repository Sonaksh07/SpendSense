import 'package:flutter/material.dart';
import '../services/mock_ml_service.dart';
import '../analysis/insight_generator.dart';
import '../models/behavioral_insight.dart';

class SpendingInsightsScreen extends StatefulWidget {
  const SpendingInsightsScreen({super.key});

  @override
  State<SpendingInsightsScreen> createState() => _SpendingInsightsScreenState();
}

class _SpendingInsightsScreenState extends State<SpendingInsightsScreen> {
  final MockMLService _mlService = MockMLService();
  final InsightGenerator _insightGen = InsightGenerator();
  List<BehavioralInsight> _insights = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final transactions = await _mlService.getTransactions();
    final patterns = await _mlService.getBehavioralPatterns();
    final forecast = await _mlService.getLSTMForecast();
    final insights = _insightGen.generate(
      transactions: transactions,
      behavioralPatterns: patterns,
      lstmForecast: forecast,
    );
    setState(() {
      _insights = insights;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Scaffold(
      appBar: AppBar(title: const Text('Spending Insights')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _insights.length,
        itemBuilder: (ctx, i) {
          final insight = _insights[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Icon(insight.icon, color: insight.severityColor, size: 32),
              title: Text(insight.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(insight.description),
              trailing: Chip(label: Text(insight.severity.toString().split('.').last)),
            ),
          );
        },
      ),
    );
  }
}