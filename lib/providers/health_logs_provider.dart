import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class HealthLog {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String type; // 'medication', 'symptom', 'appointment', 'general'

  HealthLog({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.type,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.millisecondsSinceEpoch,
      'type': type,
    };
  }

  // Create from JSON
  factory HealthLog.fromJson(Map<String, dynamic> json) {
    return HealthLog(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      date: DateTime.fromMillisecondsSinceEpoch(json['date']),
      type: json['type'],
    );
  }
}

class HealthLogsProvider extends ChangeNotifier {
  List<HealthLog> _healthLogs = [];
  bool _isLoading = false;

  // Getters
  List<HealthLog> get healthLogs => _healthLogs;
  bool get isLoading => _isLoading;

  // Get logs filtered by type
  List<HealthLog> getLogsByType(String type) {
    return _healthLogs.where((log) => log.type == type).toList();
  }

  // Get recent logs (last 7 days)
  List<HealthLog> getRecentLogs() {
    final DateTime weekAgo = DateTime.now().subtract(Duration(days: 7));
    return _healthLogs.where((log) => log.date.isAfter(weekAgo)).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  // Load health logs from SharedPreferences
  Future<void> loadHealthLogs() async {
    _isLoading = true;
    notifyListeners();

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String>? logsJson = prefs.getStringList('health_logs');

      if (logsJson != null) {
        _healthLogs = logsJson
            .map((json) => HealthLog.fromJson(jsonDecode(json)))
            .toList();

        // Sort by date (newest first)
        _healthLogs.sort((a, b) => b.date.compareTo(a.date));
      }
    } catch (e) {
      print('Error loading health logs: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Save health logs to SharedPreferences
  Future<void> _saveHealthLogs() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> logsJson = _healthLogs
          .map((log) => jsonEncode(log.toJson()))
          .toList();

      await prefs.setStringList('health_logs', logsJson);
    } catch (e) {
      print('Error saving health logs: $e');
    }
  }

  // Add new health log
  Future<void> addHealthLog({
    required String title,
    required String description,
    required String type,
  }) async {
    final newLog = HealthLog(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      date: DateTime.now(),
      type: type,
    );

    _healthLogs.insert(0, newLog); // Add to beginning of list
    await _saveHealthLogs();
    notifyListeners();
  }

  // Update existing health log
  Future<void> updateHealthLog({
    required String id,
    String? title,
    String? description,
    String? type,
  }) async {
    final index = _healthLogs.indexWhere((log) => log.id == id);

    if (index != -1) {
      final oldLog = _healthLogs[index];
      _healthLogs[index] = HealthLog(
        id: id,
        title: title ?? oldLog.title,
        description: description ?? oldLog.description,
        date: oldLog.date,
        type: type ?? oldLog.type,
      );

      await _saveHealthLogs();
      notifyListeners();
    }
  }

  // Delete health log
  Future<void> deleteHealthLog(String id) async {
    _healthLogs.removeWhere((log) => log.id == id);
    await _saveHealthLogs();
    notifyListeners();
  }

  // Get logs count by type
  int getLogsCountByType(String type) {
    return _healthLogs.where((log) => log.type == type).length;
  }

  // Clear all logs
  Future<void> clearAllLogs() async {
    _healthLogs.clear();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('health_logs');
    notifyListeners();
  }
}
