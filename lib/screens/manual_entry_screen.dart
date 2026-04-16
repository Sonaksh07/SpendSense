import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../models/categories.dart';
import '../services/transaction_service.dart';
import 'package:flutter/services.dart';

class ManualEntryScreen extends StatefulWidget {
  final Transaction? transaction; // ✅ for edit

  const ManualEntryScreen({super.key, this.transaction});

  @override
  State<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends State<ManualEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _merchantController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  SpendingCategory _selectedCategory = SpendingCategory.food;
  bool _isImpulse = false;

  @override
  void initState() {
    super.initState();

    // ✅ Pre-fill data if editing
    if (widget.transaction != null) {
      _amountController.text = widget.transaction!.amount.toString();
      _merchantController.text = widget.transaction!.merchant;
      _selectedDate = widget.transaction!.timestamp;
      _selectedCategory = widget.transaction!.category;
      _isImpulse = widget.transaction!.isImpulse;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.transaction != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Transaction' : 'Add Transaction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount (₹)'),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),

              TextFormField(
                controller: _merchantController,
                decoration: const InputDecoration(labelText: 'Merchant'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),

              ListTile(
                title: const Text('Date'),
                subtitle: Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                  }
                },
              ),

              DropdownButtonFormField<SpendingCategory>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: SpendingCategory.values.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(cat.displayName),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val!),
              ),

              SwitchListTile(
                title: const Text('Mark as Impulse'),
                value: _isImpulse,
                onChanged: (val) => setState(() => _isImpulse = val),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _saveTransaction,
                child: Text(isEditing ? 'Update Transaction' : 'Save Transaction'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveTransaction() {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountController.text);

    final txn = Transaction(
      id: widget.transaction?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      merchant: _merchantController.text,
      timestamp: _selectedDate,
      rawDescription: 'Manual entry',
      category: _selectedCategory,
      confidence: 0.9,
      anomalyScore: _isImpulse ? 0.8 : 0.2,
      isImpulse: _isImpulse,
    );

    if (widget.transaction == null) {
      // ➕ Add new
      TransactionService().addTransaction(txn);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction added')),
      );
    } else {
      // ✏️ Update existing
      TransactionService().updateTransaction(txn);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction updated')),
      );
    }

    Navigator.pop(context);
  }
}