import 'dart:convert';
import 'package:http/http.dart' as http;

class HealthTip {
  final String id;
  final String title;
  final String description;
  final String category;

  HealthTip({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
  });

  factory HealthTip.fromJson(Map<String, dynamic> json) {
    return HealthTip(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? json['name'] ?? 'Health Tip',
      description:
          json['description'] ?? json['content'] ?? 'No description available',
      category: json['category'] ?? 'general',
    );
  }
}

class ApiService {
  static const String _baseUrl =
      'https://api.quotable.io'; // Using quotable API as health API alternative

  // Fetch health tips (using quotes API as alternative)
  static Future<List<HealthTip>> fetchHealthTips() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/quotes?tags=health,wellness&limit=10'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> results = data['results'] ?? [];

        return results
            .map(
              (item) => HealthTip(
                id:
                    item['_id'] ??
                    DateTime.now().millisecondsSinceEpoch.toString(),
                title: 'Health Tip',
                description: item['content'] ?? 'Stay healthy!',
                category: 'wellness',
              ),
            )
            .toList();
      } else {
        throw Exception('Failed to fetch health tips: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching health tips: $e');
      // Return fallback tips if API fails
      return _getFallbackTips();
    }
  }

  // Mock medication data for demonstration
  static Future<List<Map<String, dynamic>>> fetchMedicationData() async {
    try {
      // Simulate API delay
      await Future.delayed(Duration(seconds: 2));

      // Mock data since we don't have a real medication API
      return [
        {
          'id': '1',
          'name': 'Aspirin',
          'dosage': '100mg',
          'frequency': 'Once daily',
          'instructions': 'Take with food',
        },
        {
          'id': '2',
          'name': 'Vitamin D',
          'dosage': '1000 IU',
          'frequency': 'Once daily',
          'instructions': 'Take in the morning',
        },
        {
          'id': '3',
          'name': 'Omega-3',
          'dosage': '500mg',
          'frequency': 'Twice daily',
          'instructions': 'Take with meals',
        },
      ];
    } catch (e) {
      print('Error fetching medication data: $e');
      throw Exception('Failed to fetch medication data');
    }
  }

  // Alternative health tips API call (using a different endpoint)
  static Future<List<HealthTip>> fetchAlternativeHealthTips() async {
    try {
      // Using a different approach - mock API response
      await Future.delayed(Duration(seconds: 1));

      return [
        HealthTip(
          id: '1',
          title: 'Stay Hydrated',
          description:
              'Drink at least 8 glasses of water daily to maintain good health.',
          category: 'hydration',
        ),
        HealthTip(
          id: '2',
          title: 'Exercise Regularly',
          description:
              'Aim for 30 minutes of moderate exercise most days of the week.',
          category: 'fitness',
        ),
        HealthTip(
          id: '3',
          title: 'Get Enough Sleep',
          description:
              'Adults should aim for 7-9 hours of quality sleep per night.',
          category: 'sleep',
        ),
        HealthTip(
          id: '4',
          title: 'Eat Balanced Meals',
          description:
              'Include fruits, vegetables, whole grains, and lean proteins in your diet.',
          category: 'nutrition',
        ),
      ];
    } catch (e) {
      print('Error fetching alternative health tips: $e');
      return _getFallbackTips();
    }
  }

  // Fallback tips when API fails
  static List<HealthTip> _getFallbackTips() {
    return [
      HealthTip(
        id: 'fallback_1',
        title: 'Take Your Medications',
        description:
            'Remember to take your prescribed medications as directed by your doctor.',
        category: 'medication',
      ),
      HealthTip(
        id: 'fallback_2',
        title: 'Regular Check-ups',
        description:
            'Schedule regular check-ups with your healthcare provider.',
        category: 'health',
      ),
      HealthTip(
        id: 'fallback_3',
        title: 'Stay Active',
        description:
            'Regular physical activity is important for overall health.',
        category: 'fitness',
      ),
    ];
  }
}
