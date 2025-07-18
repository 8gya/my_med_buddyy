import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/health_logs_provider.dart';
import '../services/api_service.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/health_tip_card.dart';
import '../widgets/notification_icon.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<HealthTip> _healthTips = [];
  bool _isLoadingTips = false;
  int _notificationCount = 3;
  String _selectedMood = ''; // Track selected mood

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadHealthTips();
  }

  void _loadUserData() {
    Provider.of<UserProvider>(context, listen: false).loadUserData();
    Provider.of<HealthLogsProvider>(context, listen: false).loadHealthLogs();
  }

  Future<void> _loadHealthTips() async {
    setState(() {
      _isLoadingTips = true;
    });

    try {
      final tips = await ApiService.fetchAlternativeHealthTips();
      setState(() {
        _healthTips = tips;
      });
    } catch (e) {
      print('Error loading health tips: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load health tips'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoadingTips = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(
        context,
      ).scaffoldBackgroundColor, // Use theme color
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
        title: Text(
          'MyMedBuddy',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 8),
            child: NotificationIcon(
              notificationCount: _notificationCount,
              color: Colors.white,
              size: 26,
              onTap: () {
                _showNotificationsDialog();
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: IconButton(
              icon: Icon(Icons.person, color: Colors.white, size: 26),
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadHealthTips,
        color: Theme.of(context).primaryColor,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              // Welcome section with improved design
              _buildWelcomeSection(),

              // Main content with better spacing
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dashboard section
                    _buildDashboardSection(),
                    SizedBox(height: 32),

                    // Quick actions section
                    _buildQuickActionsSection(),
                    SizedBox(height: 32),

                    // Health tips section
                    _buildHealthTipsSection(),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.85),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, 20, 24, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting text
                Text(
                  'Welcome back,',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 8),

                // User name
                Text(
                  userProvider.name.isNotEmpty ? userProvider.name : 'User',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),

                // Health status question
                Text(
                  'How are you feeling today?',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 24),

                // Health status indicators
                Row(
                  children: [
                    _buildHealthStatusChip('😊', 'Good', Colors.green, 'good'),
                    SizedBox(width: 12),
                    _buildHealthStatusChip('😐', 'Okay', Colors.orange, 'okay'),
                    SizedBox(width: 12),
                    _buildHealthStatusChip(
                      '😷',
                      'Unwell',
                      Colors.red,
                      'unwell',
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHealthStatusChip(
    String emoji,
    String label,
    Color color,
    String mood,
  ) {
    bool isSelected = _selectedMood == mood;

    return GestureDetector(
      onTap: () => _selectMood(mood, label),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withOpacity(0.9)
              : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? color.withOpacity(0.6)
                : Colors.white.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: TextStyle(fontSize: isSelected ? 18 : 16)),
            SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.white,
                fontSize: isSelected ? 15 : 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Handle mood selection
  void _selectMood(String mood, String label) {
    setState(() {
      _selectedMood = mood;
    });

    // Defer actions until after build is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Log mood to health logs
      Provider.of<HealthLogsProvider>(context, listen: false).addHealthLog(
        title: 'Daily Mood Check',
        description: 'Feeling $label today',
        type: 'general',
      );

      // Show feedback to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Text(_getMoodEmoji(mood)),
                SizedBox(width: 8),
                Text('Mood logged: $label'),
              ],
            ),
            backgroundColor: _getMoodColor(mood),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            duration: Duration(seconds: 2),
          ),
        );

        // Show mood-specific tips or actions
        _showMoodSpecificDialog(mood, label);
      }
    });
  }

  // Get mood emoji for feedback
  String _getMoodEmoji(String mood) {
    switch (mood) {
      case 'good':
        return '😊';
      case 'okay':
        return '😐';
      case 'unwell':
        return '😷';
      default:
        return '😊';
    }
  }

  // Get mood color for feedback
  Color _getMoodColor(String mood) {
    switch (mood) {
      case 'good':
        return Colors.green;
      case 'okay':
        return Colors.orange;
      case 'unwell':
        return Colors.red;
      default:
        return Colors.green;
    }
  }

  // Show mood-specific dialog with suggestions
  void _showMoodSpecificDialog(String mood, String label) {
    String title;
    String message;
    List<String> suggestions;

    switch (mood) {
      case 'good':
        title = '😊 Great to hear!';
        message = 'It\'s wonderful that you\'re feeling good today!';
        suggestions = [
          'Keep up your healthy habits',
          'Consider sharing your positive energy',
          'Take a moment to appreciate what\'s going well',
        ];
        break;
      case 'okay':
        title = '😐 That\'s okay';
        message = 'Some days are just okay, and that\'s perfectly normal.';
        suggestions = [
          'Try some light exercise or stretching',
          'Consider what might help you feel better',
          'Remember to stay hydrated',
        ];
        break;
      case 'unwell':
        title = '😷 Take care of yourself';
        message =
            'Sorry to hear you\'re not feeling well. Here are some suggestions:';
        suggestions = [
          'Consider contacting your healthcare provider',
          'Get plenty of rest and fluids',
          'Log your symptoms in Health Logs',
        ];
        break;
      default:
        title = 'How are you feeling?';
        message = 'Your wellbeing matters to us.';
        suggestions = ['Take care of yourself'];
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            SizedBox(height: 16),
            Text(
              'Suggestions:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: 8),
            ...suggestions.map(
              (suggestion) => Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• ', style: TextStyle(color: _getMoodColor(mood))),
                    Expanded(child: Text(suggestion)),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          if (mood == 'unwell')
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/health-logs');
              },
              child: Text('Log Symptoms'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Thanks'),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardSection() {
    return Consumer2<UserProvider, HealthLogsProvider>(
      builder: (context, userProvider, healthLogsProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Row(
              children: [
                Icon(
                  Icons.dashboard,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  'Overview',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Improved dashboard cards using flexible layout
            Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildEnhancedDashboardCard(
                        'Medications',
                        userProvider.medications.length.toString(),
                        Icons.medication,
                        Colors.blue,
                        () => Navigator.pushNamed(
                          context,
                          '/medication-schedule',
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildEnhancedDashboardCard(
                        'Health Logs',
                        healthLogsProvider.healthLogs.length.toString(),
                        Icons.assignment,
                        Colors.green,
                        () => Navigator.pushNamed(context, '/health-logs'),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildEnhancedDashboardCard(
                        'Appointments',
                        '2',
                        Icons.calendar_today,
                        Colors.orange,
                        () => Navigator.pushNamed(context, '/appointments'),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _buildEnhancedDashboardCard(
                        'Reminders',
                        _notificationCount.toString(),
                        Icons.notifications,
                        Colors.purple,
                        () => _showNotificationsDialog(),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildEnhancedDashboardCard(
    String title,
    String value,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120, // Fixed height to prevent overflow
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor, // Use theme card color
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with background
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              SizedBox(height: 8),

              // Value
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              SizedBox(height: 4),

              // Title
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[300]
                      : Colors.grey[600], // Adapt to theme
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Icon(
              Icons.flash_on,
              color: Theme.of(context).primaryColor,
              size: 24,
            ),
            SizedBox(width: 8),
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
        SizedBox(height: 20),

        // Enhanced action buttons
        Row(
          children: [
            Expanded(
              child: _buildEnhancedActionButton(
                'Log Health\nData',
                Icons.add_circle_outline,
                Colors.green,
                () => _showAddHealthLogDialog(),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildEnhancedActionButton(
                'View\nSchedule',
                Icons.schedule,
                Colors.blue,
                () => Navigator.pushNamed(context, '/medication-schedule'),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: _buildEnhancedActionButton(
                'Add\nAppointment',
                Icons.event_note,
                Colors.orange,
                () => Navigator.pushNamed(context, '/appointments'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEnhancedActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor, // Use theme card color
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[300]
                    : Colors.grey[700], // Adapt to theme
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthTipsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Icon(
              Icons.lightbulb_outline,
              color: Theme.of(context).primaryColor,
              size: 24,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Health Tips',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor, // Use theme card color
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  Icons.refresh,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: _loadHealthTips,
              ),
            ),
          ],
        ),
        SizedBox(height: 20),

        // Health tips content
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor, // Use theme card color
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: _isLoadingTips
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  )
                : _healthTips.isEmpty
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'No health tips available',
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[300]
                              : Colors.grey[600], // Adapt to theme
                          fontSize: 16,
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _healthTips.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: HealthTipCard(
                          healthTip: _healthTips[index],
                          onTap: () {
                            _showHealthTipDialog(_healthTips[index]);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  // Show notifications dialog
  void _showNotificationsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.notifications, color: Theme.of(context).primaryColor),
            SizedBox(width: 8),
            Text(
              'Reminders',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          height: 300,
          child: ListView(
            children: [
              NotificationListItem(
                title: 'Medication Reminder',
                subtitle: 'Take your morning Aspirin',
                time: DateTime.now().subtract(Duration(minutes: 30)),
                icon: Icons.medication,
                color: Colors.blue,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/medication-schedule');
                },
                onDismiss: () {
                  setState(() {
                    _notificationCount = _notificationCount > 0
                        ? _notificationCount - 1
                        : 0;
                  });
                },
              ),
              NotificationListItem(
                title: 'Appointment Reminder',
                subtitle: 'Dental checkup tomorrow at 2 PM',
                time: DateTime.now().subtract(Duration(hours: 2)),
                icon: Icons.calendar_today,
                color: Colors.green,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/appointments');
                },
                onDismiss: () {
                  setState(() {
                    _notificationCount = _notificationCount > 0
                        ? _notificationCount - 1
                        : 0;
                  });
                },
              ),
              NotificationListItem(
                title: 'Health Check',
                subtitle: 'Log your daily symptoms',
                time: DateTime.now().subtract(Duration(hours: 4)),
                icon: Icons.health_and_safety,
                color: Colors.orange,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/health-logs');
                },
                onDismiss: () {
                  setState(() {
                    _notificationCount = _notificationCount > 0
                        ? _notificationCount - 1
                        : 0;
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _notificationCount = 0;
              });
              Navigator.pop(context);
            },
            child: Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _showAddHealthLogDialog() {
    showDialog(context: context, builder: (context) => AddHealthLogDialog());
  }

  void _showHealthTipDialog(HealthTip tip) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(tip.title),
        content: Text(tip.description),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}

// Add Health Log Dialog Widget
class AddHealthLogDialog extends StatefulWidget {
  const AddHealthLogDialog({super.key});

  @override
  _AddHealthLogDialogState createState() => _AddHealthLogDialogState();
}

class _AddHealthLogDialogState extends State<AddHealthLogDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedType = 'general';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Add Health Log'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Title',
              hintText: 'Enter log title',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: 'Description',
              hintText: 'Enter details',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            maxLines: 3,
          ),
          SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: _selectedType,
            decoration: InputDecoration(
              labelText: 'Type',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items: [
              DropdownMenuItem(value: 'general', child: Text('General')),
              DropdownMenuItem(value: 'medication', child: Text('Medication')),
              DropdownMenuItem(value: 'symptom', child: Text('Symptom')),
              DropdownMenuItem(
                value: 'appointment',
                child: Text('Appointment'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _selectedType = value!;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_titleController.text.isNotEmpty) {
              Provider.of<HealthLogsProvider>(
                context,
                listen: false,
              ).addHealthLog(
                title: _titleController.text,
                description: _descriptionController.text,
                type: _selectedType,
              );
              Navigator.pop(context);
            }
          },
          child: Text('Add'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
