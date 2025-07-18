import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/health_logs_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class HealthLogsScreen extends StatefulWidget {
  const HealthLogsScreen({super.key});

  @override
  _HealthLogsScreenState createState() => _HealthLogsScreenState();
}

class _HealthLogsScreenState extends State<HealthLogsScreen> {
  String _selectedFilter = 'all';
  bool _showAddForm = false;
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedType = 'general';

  @override
  void initState() {
    super.initState();
    // Load health logs when screen initializes
    Provider.of<HealthLogsProvider>(context, listen: false).loadHealthLogs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Health Logs'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              setState(() {
                _showAddForm = !_showAddForm;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Add log form
          if (_showAddForm) _buildAddLogForm(),

          // Filter chips
          _buildFilterChips(),

          // Logs list
          Expanded(child: _buildLogsList()),
        ],
      ),
    );
  }

  // Add log form
  Widget _buildAddLogForm() {
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
            'Add Health Log',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(height: 16),

          // Title field
          CustomTextField(
            controller: _titleController,
            labelText: 'Title',
            hintText: 'Enter log title',
          ),
          SizedBox(height: 12),

          // Description field
          CustomTextField(
            controller: _descriptionController,
            labelText: 'Description',
            hintText: 'Enter details',
            maxLines: 3,
          ),
          SizedBox(height: 12),

          // Type selection
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: [
                    DropdownMenuItem(value: 'general', child: Text('General')),
                    DropdownMenuItem(
                      value: 'medication',
                      child: Text('Medication'),
                    ),
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
              ),
              SizedBox(width: 12),
              CustomButton(text: 'Add', onPressed: _addHealthLog, width: 80),
            ],
          ),
        ],
      ),
    );
  }

  // Filter chips
  Widget _buildFilterChips() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('All', 'all'),
          _buildFilterChip('General', 'general'),
          _buildFilterChip('Medication', 'medication'),
          _buildFilterChip('Symptoms', 'symptom'),
          _buildFilterChip('Appointments', 'appointment'),
        ],
      ),
    );
  }

  // Filter chip widget
  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return Padding(
      padding: EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = value;
          });
        },
        selectedColor: Theme.of(context).primaryColor.withOpacity(0.3),
        backgroundColor: Theme.of(context).cardColor,
        labelStyle: TextStyle(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[700],
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  // Logs list
  Widget _buildLogsList() {
    return Consumer<HealthLogsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          );
        }

        // Filter logs based on selected filter
        List<HealthLog> filteredLogs = _selectedFilter == 'all'
            ? provider.healthLogs
            : provider.getLogsByType(_selectedFilter);

        if (filteredLogs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.assignment, size: 64, color: Colors.grey[400]),
                SizedBox(height: 16),
                Text(
                  'No health logs found',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                SizedBox(height: 8),
                Text(
                  'Tap + to add your first log',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: filteredLogs.length,
          itemBuilder: (context, index) {
            final log = filteredLogs[index];
            return _buildLogCard(log);
          },
        );
      },
    );
  }

  // Log card widget
  Widget _buildLogCard(HealthLog log) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with title and date
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        log.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: 4),
                          Text(
                            _formatDate(log.date),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Type badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getTypeColor(log.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    log.type.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _getTypeColor(log.type),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                // More options
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      _editLog(log);
                    } else if (value == 'delete') {
                      _deleteLog(log);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 16),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 16, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),

            // Description
            if (log.description.isNotEmpty)
              Text(
                log.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Get type color
  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'medication':
        return Colors.blue;
      case 'symptom':
        return Colors.red;
      case 'appointment':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // Format date
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today ${_formatTime(date)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday ${_formatTime(date)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  // Format time
  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  // Add health log
  void _addHealthLog() {
    if (_titleController.text.isNotEmpty) {
      Provider.of<HealthLogsProvider>(context, listen: false).addHealthLog(
        title: _titleController.text,
        description: _descriptionController.text,
        type: _selectedType,
      );

      // Clear form
      _titleController.clear();
      _descriptionController.clear();
      _selectedType = 'general';

      setState(() {
        _showAddForm = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Health log added successfully'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // Edit log
  void _editLog(HealthLog log) {
    _titleController.text = log.title;
    _descriptionController.text = log.description;
    _selectedType = log.type;

    setState(() {
      _showAddForm = true;
    });
  }

  // Delete log
  void _deleteLog(HealthLog log) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Log'),
        content: Text('Are you sure you want to delete "${log.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<HealthLogsProvider>(
                context,
                listen: false,
              ).deleteHealthLog(log.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Log deleted'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Show filter dialog
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Filter Logs'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('All'),
              leading: Radio(
                value: 'all',
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: Text('General'),
              leading: Radio(
                value: 'general',
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: Text('Medication'),
              leading: Radio(
                value: 'medication',
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: Text('Symptoms'),
              leading: Radio(
                value: 'symptom',
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: Text('Appointments'),
              leading: Radio(
                value: 'appointment',
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
