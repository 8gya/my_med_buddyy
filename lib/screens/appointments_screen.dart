import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/health_logs_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class Appointment {
  final String id;
  final String title;
  final String doctor;
  final DateTime date;
  final String notes;

  Appointment({
    required this.id,
    required this.title,
    required this.doctor,
    required this.date,
    required this.notes,
  });
}

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  _AppointmentsScreenState createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  List<Appointment> _appointments = [];
  bool _showAddForm = false;
  final _titleController = TextEditingController();
  final _doctorController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadMockAppointments();
  }

  // Load mock appointments for demonstration
  void _loadMockAppointments() {
    setState(() {
      _appointments = [
        Appointment(
          id: '1',
          title: 'Regular Checkup',
          doctor: 'Dr. Smith',
          date: DateTime.now().add(Duration(days: 7)),
          notes: 'Annual physical examination',
        ),
        Appointment(
          id: '2',
          title: 'Dental Cleaning',
          doctor: 'Dr. Johnson',
          date: DateTime.now().add(Duration(days: 14)),
          notes: 'Routine dental cleaning and checkup',
        ),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F5F5),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          'Appointments',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16, top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              icon: Icon(Icons.add, color: Colors.white),
              onPressed: () {
                setState(() {
                  _showAddForm = !_showAddForm;
                });
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Add appointment form
          if (_showAddForm) _buildAddAppointmentForm(),

          // Appointments list
          Expanded(child: _buildAppointmentsList()),
        ],
      ),
    );
  }

  // Enhanced add appointment form with scrollable content
  Widget _buildAddAppointmentForm() {
    return Container(
      constraints: BoxConstraints(maxHeight: 400), // Limit height
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16), // Reduced padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.event_note,
                  color: Theme.of(context).primaryColor,
                  size: 20, // Smaller icon
                ),
                SizedBox(width: 8),
                Text(
                  'Add New Appointment',
                  style: TextStyle(
                    fontSize: 18, // Smaller font
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Form fields with reduced spacing
            CustomTextField(
              controller: _titleController,
              labelText: 'Appointment Title',
              hintText: 'e.g., Regular Checkup',
            ),
            SizedBox(height: 12),

            CustomTextField(
              controller: _doctorController,
              labelText: 'Doctor/Provider',
              hintText: 'e.g., Dr. Smith',
            ),
            SizedBox(height: 12),

            // Compact date picker
            GestureDetector(
              onTap: _selectDate,
              child: Container(
                padding: EdgeInsets.all(12), // Reduced padding
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  border: Border.all(color: Colors.grey[400]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: Theme.of(context).primaryColor,
                      size: 18, // Smaller icon
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date & Time',
                            style: TextStyle(
                              fontSize: 11, // Smaller font
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            _formatDate(_selectedDate),
                            style: TextStyle(
                              fontSize: 14, // Smaller font
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12),

            CustomTextField(
              controller: _notesController,
              labelText: 'Notes (Optional)',
              hintText: 'Additional notes',
              maxLines: 2, // Reduced from 3 to 2
            ),
            SizedBox(height: 16),

            // Compact action buttons
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Cancel',
                    onPressed: () {
                      setState(() {
                        _showAddForm = false;
                        _titleController.clear();
                        _doctorController.clear();
                        _notesController.clear();
                      });
                    },
                    isSecondary: true,
                    height: 40, // Reduced height
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: 'Add',
                    onPressed: _addAppointment,
                    height: 40, // Reduced height
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Enhanced appointments list
  Widget _buildAppointmentsList() {
    if (_appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.calendar_today,
                size: 48,
                color: Colors.grey[400],
              ),
            ),
            SizedBox(height: 24),
            Text(
              'No appointments scheduled',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Tap + to add your first appointment',
              style: TextStyle(fontSize: 16, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    // Sort appointments by date
    _appointments.sort((a, b) => a.date.compareTo(b.date));

    return ListView.builder(
      padding: EdgeInsets.all(20),
      itemCount: _appointments.length,
      itemBuilder: (context, index) {
        final appointment = _appointments[index];
        return Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: _buildEnhancedAppointmentCard(appointment),
        );
      },
    );
  }

  // Enhanced appointment card widget
  Widget _buildEnhancedAppointmentCard(Appointment appointment) {
    final isUpcoming = appointment.date.isAfter(DateTime.now());
    final daysDifference = appointment.date.difference(DateTime.now()).inDays;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            Row(
              children: [
                // Appointment icon
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isUpcoming
                        ? Colors.blue.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.medical_services,
                    color: isUpcoming ? Colors.blue : Colors.grey,
                    size: 24,
                  ),
                ),
                SizedBox(width: 16),

                // Appointment details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        appointment.doctor,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Status badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isUpcoming
                        ? Colors.green.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isUpcoming ? 'UPCOMING' : 'PAST',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isUpcoming ? Colors.green : Colors.grey,
                    ),
                  ),
                ),

                // More options
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _editAppointment(appointment);
                    } else if (value == 'delete') {
                      _deleteAppointment(appointment);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18, color: Colors.blue),
                          SizedBox(width: 12),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          SizedBox(width: 12),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),

            // Date and time info
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.schedule, size: 20, color: Colors.grey[600]),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatDetailedDate(appointment.date),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        if (isUpcoming && daysDifference <= 7)
                          Text(
                            daysDifference == 0
                                ? 'Today'
                                : '$daysDifference days from now',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Notes section
            if (appointment.notes.isNotEmpty) ...[
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.notes, size: 20, color: Colors.blue),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        appointment.notes,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: 20),

            // Action buttons with fixed layout
            Column(
              children: [
                // First button - full width
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: 'Add to Calendar',
                    onPressed: () {
                      _addToCalendar(appointment);
                    },
                    height: 44,
                    icon: Icons.calendar_today,
                  ),
                ),
                SizedBox(height: 12),
                // Second button - full width
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: 'Mark Complete',
                    onPressed: () {
                      _markAsComplete(appointment);
                    },
                    isSecondary: true,
                    height: 44,
                    icon: Icons.check_circle_outline,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Format date for display
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  // Format detailed date
  String _formatDetailedDate(DateTime date) {
    final weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${weekdays[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  // Select date
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(
                primary: Theme.of(context).primaryColor,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Colors.black,
              ),
            ),
            child: child!,
          );
        },
      );

      if (time != null) {
        setState(() {
          _selectedDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  // Add appointment
  void _addAppointment() {
    if (_titleController.text.isNotEmpty && _doctorController.text.isNotEmpty) {
      final newAppointment = Appointment(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        doctor: _doctorController.text,
        date: _selectedDate,
        notes: _notesController.text,
      );

      setState(() {
        _appointments.add(newAppointment);
        _showAddForm = false;
      });

      // Clear form
      _titleController.clear();
      _doctorController.clear();
      _notesController.clear();
      _selectedDate = DateTime.now();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Appointment added successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  // Edit appointment
  void _editAppointment(Appointment appointment) {
    _titleController.text = appointment.title;
    _doctorController.text = appointment.doctor;
    _notesController.text = appointment.notes;
    _selectedDate = appointment.date;

    setState(() {
      _showAddForm = true;
    });
  }

  // Delete appointment
  void _deleteAppointment(Appointment appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Appointment'),
        content: Text(
          'Are you sure you want to delete "${appointment.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _appointments.removeWhere((a) => a.id == appointment.id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Appointment deleted'),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Add to calendar
  void _addToCalendar(Appointment appointment) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added to calendar: ${appointment.title}'),
        backgroundColor: Colors.blue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // Mark as complete
  void _markAsComplete(Appointment appointment) {
    // Add to health logs
    Provider.of<HealthLogsProvider>(context, listen: false).addHealthLog(
      title: 'Appointment Completed',
      description: '${appointment.title} with ${appointment.doctor}',
      type: 'appointment',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Appointment marked as complete'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _doctorController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
