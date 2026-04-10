import 'package:flutter/material.dart';

enum SpendingCategory {
  food,
  shopping,
  transport,
  entertainment,
  bills,
  health,
  other;

  String get displayName {
    switch (this) {
      case SpendingCategory.food:
        return 'Food & Dining';
      case SpendingCategory.shopping:
        return 'Shopping';
      case SpendingCategory.transport:
        return 'Transport';
      case SpendingCategory.entertainment:
        return 'Entertainment';
      case SpendingCategory.bills:
        return 'Bills & Utilities';
      case SpendingCategory.health:
        return 'Health';
      case SpendingCategory.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case SpendingCategory.food:
        return Icons.restaurant;
      case SpendingCategory.shopping:
        return Icons.shopping_bag;
      case SpendingCategory.transport:
        return Icons.directions_car;
      case SpendingCategory.entertainment:
        return Icons.movie;
      case SpendingCategory.bills:
        return Icons.receipt;
      case SpendingCategory.health:
        return Icons.favorite;
      default:
        return Icons.category;
    }
  }
}