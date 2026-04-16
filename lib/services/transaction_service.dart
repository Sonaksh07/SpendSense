import '../models/transaction.dart';
import 'package:hive/hive.dart';

class TransactionService {
  static final TransactionService _instance = TransactionService._internal();
  factory TransactionService() => _instance;
  TransactionService._internal();

  final Box box = Hive.box('transactions');

  List<Transaction> _transactions = [];

  // ✅ Initialize with mock OR load from Hive
  void init(List<Transaction> mockTransactions) {
    if (_transactions.isEmpty) {
      if (box.isEmpty) {
        // First time → load mock data
        _transactions = List.from(mockTransactions);
        _saveToHive();
      } else {
        // App reopened → load saved data
        _loadFromHive();
      }
    }
  }

  // ✅ Getter
  List<Transaction> get transactions => _transactions;

  // ✅ Add new transaction
  void addTransaction(Transaction txn) {
    _transactions.add(txn);
    _saveToHive(); // 🔥 Save immediately
  }

  // Delete Transactions
  void deleteTransaction(String id) {
    _transactions.removeWhere((t) => t.id == id);
    _saveToHive(); // important
  }
  //remove
  void removeTransaction(String id) {
    _transactions.removeWhere((txn) => txn.id == id);
  }
  //Edit Transactions
  void updateTransaction(Transaction updatedTxn) {
    final index = _transactions.indexWhere((t) => t.id == updatedTxn.id);

    if (index != -1) {
      _transactions[index] = updatedTxn;
      _saveToHive();
    }
  }

  // ✅ Add multiple transactions
  void addMultipleTransactions(List<Transaction> txns) {
    _transactions.addAll(txns);
    _saveToHive();
  }

  // ✅ Save to Hive
  void _saveToHive() {
    box.put(
      'data',
      _transactions.map((t) => t.toJson()).toList(),
    );
  }

  // ✅ Load from Hive
  void _loadFromHive() {
    final data = box.get('data', defaultValue: []);

    _transactions = (data as List)
        .map((e) => Transaction.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  // Optional: clear all data
  void clearAll() {
    _transactions.clear();
    box.clear();
  }
}