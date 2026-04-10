class ImpulseRadar {
  final int currentRiskScore;
  final String riskLevel;
  final String topTrigger;
  final List<String> recentAnomalyIds;

  ImpulseRadar({
    required this.currentRiskScore,
    required this.riskLevel,
    required this.topTrigger,
    required this.recentAnomalyIds,
  });

  factory ImpulseRadar.fromJson(Map<String, dynamic> json) {
    return ImpulseRadar(
      currentRiskScore: json['current_risk_score'],
      riskLevel: json['risk_level'],
      topTrigger: json['top_trigger'],
      recentAnomalyIds: List<String>.from(json['recent_anomalies']),
    );
  }
}