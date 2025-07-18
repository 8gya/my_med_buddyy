import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  bool _dailyReminders = true;
  bool _isLoading = false;

  // Getters
  bool get isDarkMode => _isDarkMode;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get dailyReminders => _dailyReminders;
  bool get isLoading => _isLoading;

  // Constructor - load preferences on initialization
  ThemeProvider() {
    _loadPreferences();
  }

  // Load preferences from SharedPreferences
  Future<void> _loadPreferences() async {
    try {
      _isLoading = true;
      SharedPreferences prefs = await SharedPreferences.getInstance();

      _isDarkMode = prefs.getBool('dark_mode') ?? false;
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _dailyReminders = prefs.getBool('daily_reminders') ?? true;

      _isLoading = false;
      // Only notify listeners if not during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      print('Error loading theme preferences: $e');
      _isLoading = false;
    }
  }

  // Toggle dark mode safely with immediate UI update
  Future<void> toggleDarkMode() async {
    try {
      final newValue = !_isDarkMode;
      _isDarkMode = newValue;

      // Immediate UI update
      notifyListeners();

      // Save to SharedPreferences in background
      _saveThemePreference('dark_mode', newValue);
    } catch (e) {
      print('Error toggling dark mode: $e');
      // Revert the change if error occurs
      _isDarkMode = !_isDarkMode;
      notifyListeners();
    }
  }

  // Toggle notifications safely with immediate UI update
  Future<void> toggleNotifications() async {
    try {
      final newValue = !_notificationsEnabled;
      _notificationsEnabled = newValue;

      // Immediate UI update
      notifyListeners();

      // Save to SharedPreferences in background
      _saveThemePreference('notifications_enabled', newValue);
    } catch (e) {
      print('Error toggling notifications: $e');
      _notificationsEnabled = !_notificationsEnabled;
      notifyListeners();
    }
  }

  // Toggle daily reminders safely with immediate UI update
  Future<void> toggleDailyReminders() async {
    try {
      final newValue = !_dailyReminders;
      _dailyReminders = newValue;

      // Immediate UI update
      notifyListeners();

      // Save to SharedPreferences in background
      _saveThemePreference('daily_reminders', newValue);
    } catch (e) {
      print('Error toggling daily reminders: $e');
      _dailyReminders = !_dailyReminders;
      notifyListeners();
    }
  }

  // Background save method
  Future<void> _saveThemePreference(String key, bool value) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(key, value);
    } catch (e) {
      print('Error saving theme preference $key: $e');
    }
  }

  // Set dark mode directly
  Future<void> setDarkMode(bool value) async {
    if (_isDarkMode != value) {
      try {
        _isDarkMode = value;

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('dark_mode', _isDarkMode);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
      } catch (e) {
        print('Error setting dark mode: $e');
        _isDarkMode = !value; // Revert on error
      }
    }
  }

  // Set notifications directly
  Future<void> setNotifications(bool value) async {
    if (_notificationsEnabled != value) {
      try {
        _notificationsEnabled = value;

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('notifications_enabled', _notificationsEnabled);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
      } catch (e) {
        print('Error setting notifications: $e');
        _notificationsEnabled = !value;
      }
    }
  }

  // Set daily reminders directly
  Future<void> setDailyReminders(bool value) async {
    if (_dailyReminders != value) {
      try {
        _dailyReminders = value;

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('daily_reminders', _dailyReminders);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          notifyListeners();
        });
      } catch (e) {
        print('Error setting daily reminders: $e');
        _dailyReminders = !value;
      }
    }
  }

  // Reset all preferences to default
  Future<void> resetPreferences() async {
    try {
      _isDarkMode = false;
      _notificationsEnabled = true;
      _dailyReminders = true;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('dark_mode', false);
      await prefs.setBool('notifications_enabled', true);
      await prefs.setBool('daily_reminders', true);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    } catch (e) {
      print('Error resetting preferences: $e');
    }
  }
}
