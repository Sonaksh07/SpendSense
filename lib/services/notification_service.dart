import 'dart:async';
import 'package:flutter_notification_listener_plus/flutter_notification_listener_plus.dart';
import '../models/transaction.dart';
import '../models/categories.dart';
import 'transaction_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  bool _isListening = false;

  Future<void> initializeAndStart() async {
    // Initialize the plugin (must be called once)
    NotificationsListener.initialize();

    // Set up the event handler
    NotificationsListener.receivePort?.listen((dynamic event) {
      if (event is NotificationEvent) {
        _processNotification(event);
      }
    });

    // Check permission
    final bool? hasPermissionNullable = await NotificationsListener.hasPermission;
    bool hasPermission = hasPermissionNullable ?? false;
    if (!hasPermission) {
      print("No notification permission, opening settings...");
      NotificationsListener.openPermissionSettings();
      return;
    }

    // Start the service (using startService, not start)
    final bool? isRunningNullable = await NotificationsListener.isRunning;
    bool isRunning = isRunningNullable ?? false;
    if (!isRunning) {
      await NotificationsListener.startService();
      _isListening = true;
      print("Notification listener started successfully.");
    } else {
      _isListening = true;
      print("Notification listener already running.");
    }
  }

  void _processNotification(NotificationEvent event) {
    final String? appName = event.packageName;
    final String? title = event.title;
    final String? message = event.message;   // ✅ Use 'message', not 'content'

    const upiApps = [
      "com.google.android.apps.nbu.pay",
      "com.phonepe.app",
      "net.one97.paytm",
      "com.amazon.mShop.android.shopping",
      "in.amazon.mShop.android.shopping",
    ];

    if (appName != null && upiApps.contains(appName)) {
      final transaction = _parseUPINotification(title, message);
      if (transaction != null) {
        print("✅ Transaction captured: ${transaction.merchant} - ${transaction.formattedAmount}");
        TransactionService().addTransaction(transaction);
      }
    }
  }

  Transaction? _parseUPINotification(String? title, String? message) {
    final String text = "$title $message".toLowerCase();

    final amountRegex = RegExp(r'(?:rs\.?|inr|₹)\s*(\d+(?:\.\d{2})?)', caseSensitive: false);
    final match = amountRegex.firstMatch(text);
    if (match == null) return null;

    final amount = double.tryParse(match.group(1)!) ?? 0.0;
    if (amount <= 0) return null;

    final isDebit = text.contains('debited') || text.contains('paid') || text.contains('sent');
    final isCredit = text.contains('credited') || text.contains('received');
    if (!isDebit && !isCredit) return null;
    if (isCredit) return null;

    String merchant = "Unknown Merchant";
    final toRegex = RegExp(r'to\s+([a-z0-9\s]+?)(?:\s+on|\s+ref|\s+via|$)', caseSensitive: false);
    final toMatch = toRegex.firstMatch(text);
    if (toMatch != null) {
      merchant = toMatch.group(1)!.trim().toUpperCase();
    } else {
      final upiRegex = RegExp(r'([a-z0-9.-]+@[a-z]+)', caseSensitive: false);
      final upiMatch = upiRegex.firstMatch(text);
      if (upiMatch != null) {
        merchant = upiMatch.group(1)!.split('@').first.toUpperCase();
      }
    }

    SpendingCategory category = SpendingCategory.other;
    final lowerMerchant = merchant.toLowerCase();
    if (lowerMerchant.contains('swiggy') || lowerMerchant.contains('zomato') ||
        lowerMerchant.contains('food') || lowerMerchant.contains('restaurant')) {
      category = SpendingCategory.food;
    } else if (lowerMerchant.contains('uber') || lowerMerchant.contains('ola') ||
               lowerMerchant.contains('rapido')) {
      category = SpendingCategory.transport;
    } else if (lowerMerchant.contains('amazon') || lowerMerchant.contains('flipkart') ||
               lowerMerchant.contains('myntra')) {
      category = SpendingCategory.shopping;
    } else if (lowerMerchant.contains('netflix') || lowerMerchant.contains('prime') ||
               lowerMerchant.contains('hotstar')) {
      category = SpendingCategory.entertainment;
    }

    return Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      merchant: merchant.length > 20 ? merchant.substring(0, 20) : merchant,
      timestamp: DateTime.now(),
      rawDescription: text,
      category: category,
      confidence: 0.9,
      anomalyScore: 0.3,
      isImpulse: false,
    );
  }

  void stopListening() async {
    if (_isListening) {
      await NotificationsListener.stopService();   // ✅ Use stopService, not stop
      _isListening = false;
      print("Notification listener stopped.");
    }
  }
}