import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../services/transaction_service.dart';
import 'manual_entry_screen.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {

  @override
  Widget build(BuildContext context) {
    final transactions = TransactionService().transactions;

    return Scaffold(
      appBar: AppBar(title: const Text('Transaction History')),

      body: transactions.isEmpty
          ? const Center(child: Text('No transactions yet'))
          : ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: transactions.length,
        itemBuilder: (ctx, i) {
          final t = transactions[i];

          return Dismissible(
            key: Key(t.id),
            direction: DismissDirection.endToStart,

            // 🔴 Delete background
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              color: Colors.red,
              child: const Icon(Icons.delete, color: Colors.white),
            ),

            // 🔥 Delete logic
            onDismissed: (direction) {
              TransactionService().deleteTransaction(t.id);

              setState(() {}); // refresh UI

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Transaction deleted')),
              );
            },

            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: ListTile(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ManualEntryScreen(transaction: t),
                    ),
                  ).then((_) => setState(() {}));
                },

                leading: CircleAvatar(
                  backgroundColor: t.isImpulse
                      ? Colors.red.shade100
                      : Colors.grey.shade200,
                  child: Icon(
                    t.category.icon,
                    color: t.isImpulse ? Colors.red : Colors.grey,
                  ),
                ),

                title: Text(t.merchant),

                subtitle: Text(
                  '${t.category.displayName} • ${t.formattedDate}',
                ),

                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      t.formattedAmount,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (t.isImpulse)
                      const Icon(
                        Icons.warning_amber,
                        size: 16,
                        color: Colors.orange,
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),

      // ➕ ADD BUTTON
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ManualEntryScreen()),
          ).then((_) => setState(() {})); // refresh after add
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}