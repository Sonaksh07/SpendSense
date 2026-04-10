import '../models/transaction.dart';
import '../models/behavioral_insight.dart';
import '../models/categories.dart'; // needed for enum

class InsightGenerator {
  List<BehavioralInsight> generate({
    required List<Transaction> transactions,
    required Map<String, dynamic> behavioralPatterns,
    required Map<String, dynamic> lstmForecast,
  }) {
    List<BehavioralInsight> insights = [];

    final weekend = behavioralPatterns['weekend_spike'];
    if (weekend != null) {
      insights.add(BehavioralInsight(
        type: InsightType.weekendSpike,
        title: 'Weekend spending spike',
        description: 'You spend ${weekend['percentage_increase']}% more on weekends, especially on ${weekend['category']}.',
        severity: Severity.medium,
        category: weekend['category'],
      ));
    }

    final lateNight = behavioralPatterns['late_night_impulse'];
    if (lateNight != null) {
      insights.add(BehavioralInsight(
        type: InsightType.lateNightImpulse,
        title: 'Late-night impulse detected',
        description: 'You spend ₹${lateNight['avg_amount']} on average during late-night food orders, ${lateNight['frequency_per_week']} times per week.',
        severity: Severity.high,
        category: 'FOOD',
      ));
    }

    final velocityInsight = _checkVelocity(transactions);
    if (velocityInsight != null) insights.add(velocityInsight);

    final overspendProb = lstmForecast['overspend_probability'];
    if (overspendProb != null && overspendProb > 0.6) {
      insights.add(BehavioralInsight(
        type: InsightType.forecastAlert,
        title: 'Overspending risk tomorrow',
        description: 'Based on your pattern, there is a ${(overspendProb * 100).toInt()}% chance of exceeding your budget tomorrow.',
        severity: Severity.high,
        category: 'ALL',
      ));
    }

    return insights;
  }

  BehavioralInsight? _checkVelocity(List<Transaction> transactions) {
    final now = DateTime.now();
    // Use the SpendingCategory enum to check for FOOD category
    final lastHour = transactions.where((t) =>
        t.timestamp.isAfter(now.subtract(const Duration(hours: 1))) &&
        t.category == SpendingCategory.food).toList();

    if (lastHour.length >= 2) {
      double total = lastHour.fold(0, (sum, t) => sum + t.amount);
      return BehavioralInsight(
        type: InsightType.velocityAlert,
        title: 'High spending velocity',
        description: 'You made ${lastHour.length} food purchases in the last hour totaling ₹${total.toInt()}. Consider pausing.',
        severity: Severity.critical,
        category: 'FOOD',
      );
    }
    return null;
  }
}