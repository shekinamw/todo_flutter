import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onEdit,
    required this.onDelete,
  });

  /// Converts hex color string to Flutter Color
  Color _hexToColor(String hexColor) {
    hexColor = hexColor.replaceAll('#', 'FF');
    return Color(int.parse(hexColor, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = _hexToColor(task.color);
    // Determine text color for readability based on card background
    final textColor = cardColor.computeLuminance() > 0.5 ? Colors.black87 : Colors.white;

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      color: cardColor.withOpacity(0.95),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        onTap: onEdit, // Edit task on tap

        leading: CircleAvatar(
          backgroundColor: textColor.withOpacity(0.1),
          child: Icon(Icons.task_alt, color: textColor),
        ),

        title: Text(
          task.title,
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
        ),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Text(task.description, style: TextStyle(color: textColor.withOpacity(0.9), fontSize: 13)),
              ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: textColor.withOpacity(0.8)),
                const SizedBox(width: 4),
                Text('Due: ${task.deadline}', style: TextStyle(color: textColor, fontStyle: FontStyle.italic, fontWeight: FontWeight.w500)),
              ],
            ),
            const SizedBox(height: 4),
          ],
        ),

        // Trailing delete button
        trailing: IconButton(
          icon: Icon(Icons.delete, color: textColor),
          onPressed: onDelete, // Triggers confirmation dialog in TaskListScreen
        ),
      ),
    );
  }
}