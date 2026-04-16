import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';
import 'screens/transaction_history_screen.dart';
import 'screens/spending_insights_screen.dart';
import 'screens/budget_goals_screen.dart';
import 'services/notification_service.dart';// add this
import 'package:hive_flutter/hive_flutter.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  await Hive.openBox('transactions'); // ✅ open storage box

  await NotificationService().startListening();

  runApp(const SpendSenseApp());
}

class SpendSenseApp extends StatefulWidget {
  const SpendSenseApp({super.key});

  @override
  State<SpendSenseApp> createState() => _SpendSenseAppState();
}

class _SpendSenseAppState extends State<SpendSenseApp> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    TransactionHistoryScreen(),
    SpendingInsightsScreen(),
    BudgetGoalsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpendSense',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Transactions'),
            BottomNavigationBarItem(icon: Icon(Icons.insights), label: 'Insights'),
            BottomNavigationBarItem(icon: Icon(Icons.flag), label: 'Budget'),
          ],
        ),
      ),
    );
  }
}