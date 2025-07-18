import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/health_logs_provider.dart';
import '../services/api_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class MedicationScheduleScreen extends StatefulWidget {
  const MedicationScheduleScreen({super.key});

  @override
  _MedicationScheduleScreenState createState() =>
      _MedicationScheduleScreenState();
}

class _MedicationScheduleScreenState extends State<MedicationScheduleScreen> {
  List<Map<String, dynamic>> _medicationData = [];
  bool _isLoading = false;
  bool _showAddForm = false;
  final _medicationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMedicationData();
  }

  // Load medication data from API
  Future<void> _loadMedicationData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await ApiService.fetchMedicationData();
      setState(() {
        _medicationData = data;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading medication data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medication Schedule'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              setState(() {
                _showAddForm = !_showAddForm;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Add medication form
          if (_showAddForm) _buildAddMedicationForm(),

          // Medication list
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                  )
                : _buildMedicationList(),
          ),
        ],
      ),
    );
  }

  // Add medication form
  Widget _buildAddMedicationForm() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add New Medication',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  controller: _medicationController,
                  labelText: 'Medication Name',
                  hintText: 'e.g., Aspirin 100mg',
                ),
              ),
              SizedBox(width: 12),
              CustomButton(
                text: 'Add',
                onPressed: () {
                  if (_medicationController.text.isNotEmpty) {
                    _addMedication(_medicationController.text);
                  }
                },
                width: 80,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Medication list
  Widget _buildMedicationList() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        // Combine user medications with API data
        List<Widget> medicationWidgets = [];

        // Add user's personal medications
        for (String medication in userProvider.medications) {
          medicationWidgets.add(
            _buildMedicationCard(
              name: medication,
              dosage: 'As prescribed',
              frequency: 'Daily',
              instructions: 'Take as directed',
              isUserMedication: true,
            ),
          );
        }

        // Add API medication data
        for (var medData in _medicationData) {
          medicationWidgets.add(
            _buildMedicationCard(
              name: medData['name'],
              dosage: medData['dosage'],
              frequency: medData['frequency'],
              instructions: medData['instructions'],
              isUserMedication: false,
            ),
          );
        }

        if (medicationWidgets.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.medication, size: 64, color: Colors.grey[400]),
                SizedBox(height: 16),
                Text(
                  'No medications added yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                SizedBox(height: 8),
                Text(
                  'Tap + to add your first medication',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return ListView(
          padding: EdgeInsets.all(16),
          children: medicationWidgets,
        );
      },
    );
  }

  // Medication card widget
  Widget _buildMedicationCard({
    required String name,
    required String dosage,
    required String frequency,
    required String instructions,
    required bool isUserMedication,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with medication name and actions
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: isUserMedication
                                ? Colors.green
                                : Colors.blue,
                          ),
                          SizedBox(width: 4),
                          Text(
                            isUserMedication ? 'Personal' : 'Suggested',
                            style: TextStyle(
                              fontSize: 12,
                              color: isUserMedication
                                  ? Colors.green
                                  : Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isUserMedication)
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      _removeMedication(name);
                    },
                  ),
              ],
            ),
            SizedBox(height: 16),

            // Medication details
            _buildDetailRow('Dosage', dosage, Icons.medical_services),
            SizedBox(height: 8),
            _buildDetailRow('Frequency', frequency, Icons.schedule),
            SizedBox(height: 8),
            _buildDetailRow('Instructions', instructions, Icons.info),
            SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Mark as Taken',
                    onPressed: () {
                      _markAsTaken(name);
                    },
                    height: 36,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: CustomButton(
                    text: 'Set Reminder',
                    onPressed: () {
                      _setReminder(name);
                    },
                    isSecondary: true,
                    height: 36,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Detail row widget
  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }

  // Add medication
  void _addMedication(String medication) {
    Provider.of<UserProvider>(context, listen: false).addMedication(medication);
    _medicationController.clear();
    setState(() {
      _showAddForm = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Medication added successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Remove medication
  void _removeMedication(String medication) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove Medication'),
        content: Text('Are you sure you want to remove $medication?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<UserProvider>(
                context,
                listen: false,
              ).removeMedication(medication);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Medication removed'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: Text('Remove'),
          ),
        ],
      ),
    );
  }

  // Mark medication as taken
  void _markAsTaken(String medication) {
    // Add to health logs
    Provider.of<HealthLogsProvider>(context, listen: false).addHealthLog(
      title: 'Medication Taken',
      description: 'Took $medication',
      type: 'medication',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Marked $medication as taken'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Set reminder for medication
  void _setReminder(String medication) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reminder set for $medication'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  void dispose() {
    _medicationController.dispose();
    super.dispose();
  }
}
