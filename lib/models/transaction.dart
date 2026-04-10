import 'package:flutter/material.dart';
import 'categories.dart';

class Transaction {
  final String id;
  final double amount;
  final String merchant;
  final DateTime timestamp;
  final String rawDescription;
  final SpendingCategory category;
  final double confidence;
  final double anomalyScore;
  final bool isImpulse;

  Transaction({
    required this.id,
    required this.amount,
    required this.merchant,
    required this.timestamp,
    required this.rawDescription,
    required this.category,
    required this.confidence,
    required this.anomalyScore,
    required this.isImpulse,
  });

  // ✅ For MOCK ML DATA
  factory Transaction.fromMockJson(Map<String, dynamic> json) {
    final catStr = json['ml_category'] as String;
    SpendingCategory cat;

    switch (catStr) {
      case 'FOOD':
        cat = SpendingCategory.food;
        break;
      case 'SHOPPING':
        cat = SpendingCategory.shopping;
        break;
      case 'TRANSPORT':
        cat = SpendingCategory.transport;
        break;
      case 'ENTERTAINMENT':
        cat = SpendingCategory.entertainment;
        break;
      default:
        cat = SpendingCategory.other;
    }

    return Transaction(
      id: json['id'],
      amount: (json['amount'] as num).toDouble(),
      merchant: json['merchant'],
      timestamp: DateTime.parse(json['timestamp']),
      rawDescription: json['raw_description'],
      category: cat,
      confidence: (json['confidence'] as num).toDouble(),
      anomalyScore: (json['anomaly_score'] as num).toDouble(),
      isImpulse: json['is_impulse'],
    );
  }

  // ✅ For HIVE SAVE
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'merchant': merchant,
      'timestamp': timestamp.toIso8601String(),
      'rawDescription': rawDescription,
      'category': category.index,
      'confidence': confidence,
      'anomalyScore': anomalyScore,
      'isImpulse': isImpulse,
    };
  }

  // ✅ For HIVE LOAD
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      amount: (json['amount'] as num).toDouble(),
      merchant: json['merchant'],
      timestamp: DateTime.parse(json['timestamp']),
      rawDescription: json['rawDescription'],
      category: SpendingCategory.values[json['category']],
      confidence: (json['confidence'] as num).toDouble(),
      anomalyScore: (json['anomalyScore'] as num).toDouble(),
      isImpulse: json['isImpulse'],
    );
  }

  // ✅ UI HELPERS
  String get formattedAmount => '₹${amount.toStringAsFixed(0)}';

  String get formattedTime =>
      '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';

  String get formattedDate => '${timestamp.day}/${timestamp.month}';
}