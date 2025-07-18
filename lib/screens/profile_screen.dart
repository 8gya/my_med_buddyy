import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/health_logs_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _conditionController = TextEditingController();

  // Add loading states for debugging
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _initializeProviders();
  }

  // Initialize all providers with error handling
  Future<void> _initializeProviders() async {
    try {
      // Use addPostFrameCallback to ensure widget is mounted
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (mounted) {
          await _loadAllData();
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading data: $e';
          _isLoading = false;
        });
      }
    }
  }

  // Load all provider data
  Future<void> _loadAllData() async {
    try {
      // Load user data
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.loadUserData();

      // Load health logs
      final healthLogsProvider = Provider.of<HealthLogsProvider>(
        context,
        listen: false,
      );
      await healthLogsProvider.loadHealthLogs();

      // Update text controllers
      _nameController.text = userProvider.name;
      _ageController.text = userProvider.age > 0
          ? userProvider.age.toString()
          : '';
      _conditionController.text = userProvider.condition;

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading data: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit),
            onPressed: () {
              if (_isEditing) {
                _saveProfile();
              } else {
                setState(() {
                  _isEditing = true;
                });
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text('Loading profile...'),
                ],
              ),
            )
          : _errorMessage.isNotEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: Colors.red, size: 48),
                  SizedBox(height: 16),
                  Text(
                    _errorMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                        _errorMessage = '';
                      });
                      _loadAllData();
                    },
                    child: Text('Retry'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile header
                  _buildProfileHeader(),
                  SizedBox(height: 24),

                  // Profile information
                  _buildProfileInfo(),
                  SizedBox(height: 24),

                  // Settings section
                  _buildSettingsSection(),
                  SizedBox(height: 24),

                  // Statistics section
                  _buildStatisticsSection(),
                  SizedBox(height: 24),

                  // Actions section
                  _buildActionsSection(),
                ],
              ),
            ),
    );
  }

  // Profile header with avatar
  Widget _buildProfileHeader() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              // Avatar
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Icon(Icons.person, size: 40, color: Colors.white),
              ),
              SizedBox(height: 16),

              // Name and basic info
              Text(
                userProvider.name.isNotEmpty ? userProvider.name : 'User',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                userProvider.age > 0
                    ? '${userProvider.age} years old'
                    : 'Age not specified',
                style: TextStyle(fontSize: 16, color: Colors.white70),
              ),
              if (userProvider.condition.isNotEmpty) ...[
                SizedBox(height: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    userProvider.condition,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // Profile information section
  Widget _buildProfileInfo() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: 16),

            // Name field
            CustomTextField(
              controller: _nameController,
              labelText: 'Full Name',
              hintText: 'Enter your full name',
              enabled: _isEditing,
            ),
            SizedBox(height: 16),

            // Age field
            CustomTextField(
              controller: _ageController,
              labelText: 'Age',
              hintText: 'Enter your age',
              keyboardType: TextInputType.number,
              enabled: _isEditing,
            ),
            SizedBox(height: 16),

            // Condition field
            CustomTextField(
              controller: _conditionController,
              labelText: 'Medical Condition',
              hintText: 'Enter your medical condition',
              maxLines: 2,
              enabled: _isEditing,
            ),

            if (_isEditing) ...[
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Cancel',
                      onPressed: () {
                        setState(() {
                          _isEditing = false;
                        });
                        _loadAllData(); // Reset to original data
                      },
                      isSecondary: true,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: CustomButton(
                      text: 'Save Changes',
                      onPressed: _saveProfile,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Settings section - FIXED: No more async/await
  Widget _buildSettingsSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: 16),

            // Theme settings with fixed error handling
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, child) {
                return Column(
                  children: [
                    // Dark mode toggle - FIXED: No async/await
                    ListTile(
                      leading: Icon(
                        themeProvider.isDarkMode
                            ? Icons.dark_mode
                            : Icons.light_mode,
                        color: Theme.of(context).primaryColor,
                      ),
                      title: Text('Dark Mode'),
                      trailing: Switch(
                        value: themeProvider.isDarkMode,
                        onChanged: (value) {
                          try {
                            themeProvider.toggleDarkMode(); // Now synchronous
                          } catch (e) {
                            _showErrorSnackBar('Error toggling dark mode: $e');
                          }
                        },
                        activeColor: Theme.of(context).primaryColor,
                      ),
                    ),

                    // Notifications toggle - FIXED: No async/await
                    ListTile(
                      leading: Icon(
                        Icons.notifications,
                        color: Theme.of(context).primaryColor,
                      ),
                      title: Text('Notifications'),
                      trailing: Switch(
                        value: themeProvider.notificationsEnabled,
                        onChanged: (value) {
                          try {
                            themeProvider
                                .toggleNotifications(); // Now synchronous
                          } catch (e) {
                            _showErrorSnackBar(
                              'Error toggling notifications: $e',
                            );
                          }
                        },
                        activeColor: Theme.of(context).primaryColor,
                      ),
                    ),

                    // Daily reminders toggle - FIXED: No async/await
                    ListTile(
                      leading: Icon(
                        Icons.alarm,
                        color: Theme.of(context).primaryColor,
                      ),
                      title: Text('Daily Reminders'),
                      trailing: Switch(
                        value: themeProvider.dailyReminders,
                        onChanged: (value) {
                          try {
                            themeProvider
                                .toggleDailyReminders(); // Now synchronous
                          } catch (e) {
                            _showErrorSnackBar(
                              'Error toggling daily reminders: $e',
                            );
                          }
                        },
                        activeColor: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Statistics section
  Widget _buildStatisticsSection() {
    return Consumer2<UserProvider, HealthLogsProvider>(
      builder: (context, userProvider, healthLogsProvider, child) {
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Health Statistics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                SizedBox(height: 16),

                // Statistics grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 2,
                  children: [
                    _buildStatCard(
                      'Medications',
                      userProvider.medications.length.toString(),
                      Icons.medication,
                      Colors.blue,
                    ),
                    _buildStatCard(
                      'Health Logs',
                      healthLogsProvider.healthLogs.length.toString(),
                      Icons.assignment,
                      Colors.green,
                    ),
                    _buildStatCard(
                      'This Week',
                      healthLogsProvider.getRecentLogs().length.toString(),
                      Icons.date_range,
                      Colors.orange,
                    ),
                    _buildStatCard(
                      'Symptoms',
                      healthLogsProvider
                          .getLogsCountByType('symptom')
                          .toString(),
                      Icons.warning,
                      Colors.red,
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

  // Statistics card
  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Actions section
  Widget _buildActionsSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: 16),

            // Export data button
            ListTile(
              leading: Icon(Icons.file_download, color: Colors.blue),
              title: Text('Export Health Data'),
              subtitle: Text('Export your health logs as PDF'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _exportHealthData,
            ),

            // Backup data button
            ListTile(
              leading: Icon(Icons.backup, color: Colors.green),
              title: Text('Backup Data'),
              subtitle: Text('Backup your data to cloud'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _backupData,
            ),

            // Clear all data button
            ListTile(
              leading: Icon(Icons.clear_all, color: Colors.orange),
              title: Text('Clear All Data'),
              subtitle: Text('Remove all health logs'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _clearAllData,
            ),

            // Logout button
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text('Logout'),
              subtitle: Text('Sign out of your account'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }

  // Helper method for error messages
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  // Save profile changes
  Future<void> _saveProfile() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      await userProvider.updateProfile(
        name: _nameController.text,
        age: int.tryParse(_ageController.text) ?? 0,
        condition: _conditionController.text,
      );

      setState(() {
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      _showErrorSnackBar('Error updating profile: $e');
    }
  }

  // Export health data
  void _exportHealthData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Export Health Data'),
        content: Text(
          'This feature would export your health logs as a PDF file.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Health data exported successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text('Export'),
          ),
        ],
      ),
    );
  }

  // Backup data
  void _backupData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Backup Data'),
        content: Text('This feature would backup your data to cloud storage.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Data backed up successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text('Backup'),
          ),
        ],
      ),
    );
  }

  // Clear all data
  void _clearAllData() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Clear All Data'),
        content: Text(
          'Are you sure you want to clear all health logs? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final healthLogsProvider = Provider.of<HealthLogsProvider>(
                  context,
                  listen: false,
                );
                await healthLogsProvider.clearAllLogs();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('All health logs cleared'),
                    backgroundColor: Colors.red,
                  ),
                );
              } catch (e) {
                Navigator.pop(context);
                _showErrorSnackBar('Error clearing data: $e');
              }
            },
            child: Text('Clear All'),
          ),
        ],
      ),
    );
  }

  // Logout
  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text(
          'Are you sure you want to logout? You will need to complete onboarding again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final userProvider = Provider.of<UserProvider>(
                  context,
                  listen: false,
                );
                await userProvider.logout();
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/onboarding');
              } catch (e) {
                Navigator.pop(context);
                _showErrorSnackBar('Error logging out: $e');
              }
            },
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _conditionController.dispose();
    super.dispose();
  }
}
