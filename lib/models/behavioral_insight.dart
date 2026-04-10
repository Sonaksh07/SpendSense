import 'package:flutter/material.dart';

enum InsightType { weekendSpike, lateNightImpulse, velocityAlert, forecastAlert }
enum Severity { low, medium, high, critical }

class BehavioralInsight {
  final InsightType type;
  final String title;
  final String description;
  final Severity severity;
  final String category;

  BehavioralInsight({
    required this.type,
    required this.title,
    required this.description,
    required this.severity,
    required this.category,
  });

  Color get severityColor {
    switch (severity) {
      case Severity.low:
        return Colors.green;
      case Severity.medium:
        return Colors.orange;
      case Severity.high:
        return Colors.redAccent;
      case Severity.critical:
        return Colors.red;
    }
  }

  IconData get icon {
    switch (type) {
      case InsightType.weekendSpike:
        return Icons.weekend;
      case InsightType.lateNightImpulse:
        return Icons.nightlight_round;
      case InsightType.velocityAlert:
        return Icons.speed;
      case InsightType.forecastAlert:
        return Icons.warning;
    }
  }
}