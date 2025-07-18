import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider extends ChangeNotifier {
  // User data variables
  String _name = '';
  int _age = 0;
  String _condition = '';
  List<String> _medications = [];
  bool _isLoggedIn = false;

  // Getters for user data
  String get name => _name;
  int get age => _age;
  String get condition => _condition;
  List<String> get medications => _medications;
  bool get isLoggedIn => _isLoggedIn;

  // Load user data from SharedPreferences
  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    _name = prefs.getString('user_name') ?? '';
    _age = prefs.getInt('user_age') ?? 0;
    _condition = prefs.getString('user_condition') ?? '';
    _medications = prefs.getStringList('user_medications') ?? [];
    _isLoggedIn = prefs.getBool('user_logged_in') ?? false;

    // Notify listeners about data changes
    notifyListeners();
  }

  // Save user data to SharedPreferences
  Future<void> saveUserData({
    required String name,
    required int age,
    required String condition,
    required List<String> medications,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Store user data
    await prefs.setString('user_name', name);
    await prefs.setInt('user_age', age);
    await prefs.setString('user_condition', condition);
    await prefs.setStringList('user_medications', medications);
    await prefs.setBool('user_logged_in', true);
    await prefs.setBool('onboarding_completed', true);

    // Update local variables
    _name = name;
    _age = age;
    _condition = condition;
    _medications = medications;
    _isLoggedIn = true;

    // Notify listeners about changes
    notifyListeners();
  }

  // Update user profile
  Future<void> updateProfile({
    String? name,
    int? age,
    String? condition,
    List<String>? medications,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (name != null) {
      _name = name;
      await prefs.setString('user_name', name);
    }
    if (age != null) {
      _age = age;
      await prefs.setInt('user_age', age);
    }
    if (condition != null) {
      _condition = condition;
      await prefs.setString('user_condition', condition);
    }
    if (medications != null) {
      _medications = medications;
      await prefs.setStringList('user_medications', medications);
    }

    notifyListeners();
  }

  // Add new medication
  Future<void> addMedication(String medication) async {
    _medications.add(medication);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('user_medications', _medications);
    notifyListeners();
  }

  // Remove medication
  Future<void> removeMedication(String medication) async {
    _medications.remove(medication);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('user_medications', _medications);
    notifyListeners();
  }

  // Logout user
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Reset user data
    _name = '';
    _age = 0;
    _condition = '';
    _medications = [];
    _isLoggedIn = false;

    notifyListeners();
  }
}
