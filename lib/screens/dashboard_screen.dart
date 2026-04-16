import 'package:flutter/material.dart';
import '../services/mock_ml_service.dart';
import '../services/transaction_service.dart';
import '../models/transaction.dart';
import '../models/impulse_radar.dart';
import '../models/behavioral_insight.dart';
import '../analysis/insight_generator.dart';
import '../widgets/positive_friction_dialog.dart';
import '../screens/budget_goals_screen.dart';
import 'manual_entry_screen.dart';
import 'upload_passbook_screen.dart';
import '../widgets/spending_pie_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final MockMLService _mlService = MockMLService();

  List<Transaction> _transactions = [];
  ImpulseRadar? _radar;
  Map<String, dynamic> _patterns = {};
  Map<String, dynamic> _budget = {};
  List<int> _monthlyTrend = [];
  List<BehavioralInsight> _insights = [];

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final mockTxns = await _mlService.getTransactions();
    TransactionService().init(mockTxns);

    final transactions = TransactionService().transactions;

    final radar = await _mlService.getImpulseRadar();
    final patterns = await _mlService.getBehavioralPatterns();
    final budget = await _mlService.getBudget();
    final trend = await _mlService.getMonthlyTrend();

    final insights = InsightGenerator().generate(
      transactions: transactions,
      behavioralPatterns: patterns,
      lstmForecast: {},
    );

    setState(() {
      _transactions = transactions;
      _radar = radar;
      _patterns = patterns;
      _budget = budget;
      _monthlyTrend = trend;
      _insights = insights;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final transactions = TransactionService().transactions;
    final now = DateTime.now();

// Start of week = Monday 00:00
    final startOfWeek = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));

    final thisWeekTransactions = transactions
        .where((t) {
      final txnDate = DateTime(
        t.timestamp.year,
        t.timestamp.month,
        t.timestamp.day,
      );
      return txnDate.isAtSameMomentAs(startOfWeek) ||
          txnDate.isAfter(startOfWeek);
    })
        .toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final totalSpent =
    transactions.fold(0.0, (sum, t) => sum + t.amount);
    final impulseCount =
        transactions.where((t) => t.isImpulse).length;

    final weekendSpike = _patterns['weekend_spike'];
    final lateNight = _patterns['late_night_impulse'];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      // ✅ FAB
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (ctx) => SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.add),
                    title: const Text('Manual Entry'),
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ManualEntryScreen(),
                        ),
                      ).then((_) => setState(() {}));
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.upload_file),
                    title: const Text('Upload Passbook'),
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                          const UploadPassbookScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              const Text(
                'Hello!',
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const Text(
                'Here\'s your financial snapshot',
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 16),

              // STATS
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Total Spent',
                      '₹${totalSpent.toInt()}',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Impulse Alerts',
                      '$impulseCount',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // TRANSACTIONS
              const Text(
                'This Week\'s Spend',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              ...thisWeekTransactions
                  .take(3)
                  .map((txn) => _buildSpendingItem(txn)),

              const SizedBox(height: 16),

              // PIE CHART
              const Text(
                'Spending by Category',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              SpendingPieChart(transactions: transactions),

              const SizedBox(height: 16),

              // ALERTS
              if (weekendSpike != null)
                _buildAlertCard(
                  Icons.weekend,
                  'Weekend Spending Spike',
                  '${weekendSpike['percentage_increase']}% More Spent on Weekends',
                  Colors.orange,
                ),

              if (lateNight != null)
                _buildAlertCard(
                  Icons.nightlight_round,
                  'Late-Night Cravings',
                  '₹${lateNight['total_last_week']} Spent After 11PM',
                  Colors.deepPurple,
                ),

              const SizedBox(height: 16),

              // 🔥 IMPULSE RADAR
              if (_radar != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.red.withOpacity(0.15),
                        Colors.orange.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Impulse Radar',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Risk Score: ${_radar!.currentRiskScore}',
                        style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Level: ${_radar!.riskLevel}',
                        style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Top trigger: ${_radar!.topTrigger}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              // MONTHLY TREND
              const Text(
                'Monthly Trend',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceEvenly,
                  children:
                  List.generate(_monthlyTrend.length, (index) {
                    final value = _monthlyTrend[index];
                    final height = (value / 30000) * 100;

                    return Container(
                      width: 30,
                      height: height.clamp(10.0, 150.0),
                      color: Colors.blue,
                    );
                  }),
                ),
              ),

              const SizedBox(height: 16),

              // SMART INSIGHTS
              const Text(
                'Smart Insights',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              ..._insights.map((insight) {
                Color color;

                switch (insight.severity) {
                  case Severity.high:
                    color = Colors.red;
                    break;
                  case Severity.medium:
                    color = Colors.orange;
                    break;
                  case Severity.critical:
                    color = Colors.deepPurple;
                    break;
                  default:
                    color = Colors.blue;
                }

                return Container(
                  margin:
                  const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.08),
                    borderRadius:
                    BorderRadius.circular(14),
                    border: Border.all(
                        color: color.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.insights, color: color),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              insight.title,
                              style: TextStyle(
                                  fontWeight:
                                  FontWeight.bold,
                                  color: color),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              insight.description,
                              style: const TextStyle(
                                  fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const SizedBox(height: 80), // space for FAB
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(title),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSpendingItem(Transaction txn) {
    return ListTile(
      title: Text(txn.merchant),
      subtitle: Text(txn.category.displayName),
      trailing: Text(txn.formattedAmount),
    );
  }

  Widget _buildAlertCard(
      IconData icon, String title, String desc, Color color) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      subtitle: Text(desc),
    );
  }
}