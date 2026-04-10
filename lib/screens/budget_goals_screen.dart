import 'package:flutter/material.dart';
import '../services/mock_ml_service.dart';

class BudgetGoalsScreen extends StatefulWidget {
  const BudgetGoalsScreen({super.key});

  @override
  State<BudgetGoalsScreen> createState() => _BudgetGoalsScreenState();
}

class _BudgetGoalsScreenState extends State<BudgetGoalsScreen> {
  final MockMLService _mlService = MockMLService();
  Map<String, dynamic> _budget = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final budget = await _mlService.getBudget();
    setState(() {
      _budget = budget;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    return Scaffold(
      appBar: AppBar(title: const Text('Budget & Goals')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildGoalTile('Thailand Trip', _budget['saved_so_far'], _budget['goal_target'], _budget['goal_progress']),
            const SizedBox(height: 16),
            _buildGoalTile('Vacation Fund', _budget['vacation_fund'], _budget['vacation_target'], _budget['vacation_fund'] / _budget['vacation_target']),
            const SizedBox(height: 16),
            _buildGoalTile('New Laptop', _budget['new_laptop_saved'], _budget['laptop_target'], _budget['new_laptop_saved'] / _budget['laptop_target']),
          ],
        ),
      ),
    );
  }

 Widget _buildGoalTile(String name, dynamic saved, dynamic target, double progress) {
  final savedDouble = (saved is int) ? saved.toDouble() : saved;
  final targetDouble = (target is int) ? target.toDouble() : target;
  final prog = (progress is int) ? progress.toDouble() : progress.clamp(0.0, 1.0);
  return Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          LinearProgressIndicator(value: prog, backgroundColor: Colors.grey.shade200),
          const SizedBox(height: 8),
          Text('₹${savedDouble.toInt()} saved of ₹${targetDouble.toInt()}'),
          Text('${(prog * 100).toInt()}% completed'),
        ],
      ),
    ),
  );
}
}