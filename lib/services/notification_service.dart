import 'package:notification_listener_service/notification_listener_service.dart';
import '../services/rag_service.dart';
import '../services/transaction_service.dart';
import '../models/transaction.dart';
import '../models/categories.dart';

class NotificationService {
  final RagService _ragService = RagService();

  Future<void> startListening() async {
    final bool granted = await NotificationListenerService.requestPermission();

    if (!granted) {
      print("❌ Notification permission not granted");
      return;
    }

    NotificationListenerService.notificationsStream.listen((event) async {
      final String text = "${event.title ?? ""} ${event.content ?? ""}";

      print("🔥 NOTIFICATION: $text");

      if (!_isTransaction(text)) return;

      try {
        final result = await _ragService.analyzeText(text);

        print("🤖 AI RESULT: $result");

        final txn = _buildTransaction(result, text);

        if (txn != null) {
          TransactionService().addTransaction(txn);
          print("✅ Transaction Added");
        }
      } catch (e) {
        print("❌ ERROR: $e");
      }
    });
  }

  bool _isTransaction(String text) {
    final t = text.toLowerCase();
    return t.contains("debited") ||
        t.contains("credited") ||
        t.contains("upi") ||
        t.contains("paid");
  }

  Transaction? _buildTransaction(Map<String, dynamic> data, String raw) {
    final payload = _normalizePayload(data);
    final amount = _toDouble(payload["amount"] ?? payload["transaction_amount"]);
    if (amount <= 0) return null;

    final merchant = _toMerchant(payload);

    return Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      amount: amount,
      merchant: merchant,
      timestamp: DateTime.now(),
      rawDescription: raw,
      category: SpendingCategory.other,
      confidence: 0.9,
      anomalyScore: 0.2,
      isImpulse: false,
    );
  }

  Map<String, dynamic> _normalizePayload(Map<String, dynamic> data) {
    final nestedTransaction = data["transaction"];
    if (nestedTransaction is Map<String, dynamic>) return nestedTransaction;
    return data;
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim()) ?? 0.0;
    return 0.0;
  }

  String _toMerchant(Map<String, dynamic> payload) {
    final rawMerchant = payload["merchant"] ?? payload["vendor"] ?? payload["payee"];
    if (rawMerchant == null) return "Unknown";
    final merchant = rawMerchant.toString().trim();
    return merchant.isEmpty ? "Unknown" : merchant;
  }
}
