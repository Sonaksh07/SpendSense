import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/transaction.dart';
import '../models/impulse_radar.dart';

class MockMLService {
  Future<Map<String, dynamic>> loadMockData() async {
    final jsonString = await rootBundle.loadString('assets/mock_ml_data.json');
    return json.decode(jsonString);
  }

  Future<List<Transaction>> getTransactions() async {
    final data = await loadMockData();
    final List list = data['transactions'];
    return list.map((json) => Transaction.fromMockJson(json)).toList();
  }

  Future<ImpulseRadar> getImpulseRadar() async {
    final data = await loadMockData();
    return ImpulseRadar.fromJson(data['impulse_radar']);
  }

  Future<Map<String, dynamic>> getBehavioralPatterns() async {
    final data = await loadMockData();
    return data['behavioral_patterns'];
  }

  Future<Map<String, dynamic>> getLSTMForecast() async {
    final data = await loadMockData();
    return data['lstm_forecast'];
  }

  Future<Map<String, dynamic>> getBudget() async {
    final data = await loadMockData();
    return data['budget'];
  }

  Future<List<int>> getMonthlyTrend() async {
    final data = await loadMockData();
    return List<int>.from(data['monthly_trend']);
  }
}