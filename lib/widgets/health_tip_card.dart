import 'package:flutter/material.dart';
import '../services/api_service.dart';

class HealthTipCard extends StatelessWidget {
  final HealthTip healthTip;
  final VoidCallback? onTap;

  const HealthTipCard({super.key, required this.healthTip, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: EdgeInsets.only(bottom: 12),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon based on category
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _getCategoryColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getCategoryIcon(),
                  color: _getCategoryColor(),
                  size: 20,
                ),
              ),
              SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      healthTip.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    SizedBox(height: 8),

                    // Description (truncated)
                    Text(
                      healthTip.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),

                    // Category tag
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getCategoryColor().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        healthTip.category.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _getCategoryColor(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow icon
              Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  // Get color based on category
  Color _getCategoryColor() {
    switch (healthTip.category.toLowerCase()) {
      case 'nutrition':
        return Colors.green;
      case 'fitness':
        return Colors.blue;
      case 'sleep':
        return Colors.purple;
      case 'hydration':
        return Colors.cyan;
      case 'medication':
        return Colors.orange;
      case 'mental':
        return Colors.teal;
      default:
        return Colors.brown;
    }
  }

  // Get icon based on category
  IconData _getCategoryIcon() {
    switch (healthTip.category.toLowerCase()) {
      case 'nutrition':
        return Icons.restaurant;
      case 'fitness':
        return Icons.fitness_center;
      case 'sleep':
        return Icons.bedtime;
      case 'hydration':
        return Icons.water_drop;
      case 'medication':
        return Icons.medication;
      case 'mental':
        return Icons.psychology;
      default:
        return Icons.health_and_safety;
    }
  }
}
