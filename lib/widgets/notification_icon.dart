import 'package:flutter/material.dart';

class NotificationIcon extends StatelessWidget {
  final int notificationCount;
  final VoidCallback? onTap;
  final double size;
  final Color? color;
  final bool showBadge;

  const NotificationIcon({
    Key? key,
    this.notificationCount = 0,
    this.onTap,
    this.size = 24.0,
    this.color,
    this.showBadge = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          // Notification bell icon
          Icon(
            Icons.notifications,
            size: size,
            color: color ?? Theme.of(context).primaryColor,
          ),

          // Badge with notification count
          if (showBadge && notificationCount > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                constraints: BoxConstraints(minWidth: 16, minHeight: 16),
                child: Text(
                  notificationCount > 99 ? '99+' : notificationCount.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Reminder notification widget for medication reminders
class MedicationReminderIcon extends StatelessWidget {
  final String medicationName;
  final TimeOfDay reminderTime;
  final VoidCallback? onTap;
  final bool isOverdue;

  const MedicationReminderIcon({
    Key? key,
    required this.medicationName,
    required this.reminderTime,
    this.onTap,
    this.isOverdue = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12),
        margin: EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isOverdue
              ? Colors.red.withOpacity(0.1)
              : Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isOverdue ? Colors.red : Colors.blue,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Medication icon
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isOverdue ? Colors.red : Colors.blue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(Icons.medication, color: Colors.white, size: 20),
            ),
            SizedBox(width: 12),

            // Medication details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medicationName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isOverdue ? Colors.red : Colors.blue,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${reminderTime.format(context)} - ${isOverdue ? 'Overdue' : 'Reminder'}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),

            // Status indicator
            Icon(
              isOverdue ? Icons.warning : Icons.access_time,
              color: isOverdue ? Colors.red : Colors.blue,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// Floating notification badge for app-wide notifications
class FloatingNotificationBadge extends StatelessWidget {
  final int count;
  final VoidCallback? onTap;

  const FloatingNotificationBadge({Key? key, required this.count, this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return SizedBox.shrink();

    return Positioned(
      top: 50,
      right: 16,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.notifications, color: Colors.white, size: 16),
              SizedBox(width: 4),
              Text(
                count.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Notification list item for displaying reminders
class NotificationListItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final DateTime time;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final VoidCallback? onDismiss;

  const NotificationListItem({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.color,
    this.onTap,
    this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(title + time.toString()),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 16),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        if (onDismiss != null) onDismiss!();
      },
      child: Card(
        margin: EdgeInsets.only(bottom: 8),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: 20),
          ),
          title: Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subtitle,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              SizedBox(height: 4),
              Text(
                _formatTime(time),
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
          trailing: Icon(Icons.arrow_forward_ios, size: 16),
          onTap: onTap,
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
