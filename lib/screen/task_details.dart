import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:task_manager/core/app_theme.dart';
import 'package:task_manager/helpers/date_extensions.dart';
import 'package:task_manager/helpers/task_helpers.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/screen/edit_task.dart';



class TaskDetails extends StatelessWidget {
  TaskDetails({super.key, required this.task});
  Task task;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final custom = Theme.of(context).extension<AppCustomColors>()!;

    final statusColor = task.isCompleted ? custom.success : custom.warning;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text('Task Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.task, size: 100.0, color: colorScheme.primary),

                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 50.0,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  if (task.dueDate != null)
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: "${DateFormat('MMMM dd, yyyy').format(task.dueDate!)} • ${task.dueDate!.toRelativeDateString()}",
                            style: TextStyle(fontSize: 16.0, color: colorScheme.onSurfaceVariant),
                          ),
                          if (task.priority != null)
                            TextSpan(
                              text: '  •   ${task.priority}',
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                                color: getPriorityColor(context, task.priority!),
                              ),
                            ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 24.0),
                ],
              ),
            ),

            Text(
              'Description:',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
            ),
            const SizedBox(height: 8.0),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Text(
                task.description,
                style: TextStyle(fontSize: 16.0, color: colorScheme.onSurface),
              ),
            ),
            const SizedBox(height: 16.0),

            Text(
              'Status:',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: colorScheme.onSurface),
            ),
            const SizedBox(height: 8.0),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Text(
                task.isCompleted ? 'Completed' : 'Pending',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                  color: statusColor,
                ),
              ),
            ),

            const SizedBox(height: 24.0),

            FilledButton.icon(
              onPressed: () {
                task.isCompleted = !task.isCompleted;
                Navigator.pop(context, task);
              },
              icon: Icon(task.isCompleted ? Icons.undo : Icons.check_circle),
              label: Text(task.isCompleted ? 'Mark as Pending' : 'Mark as Completed'),
            ),
            const SizedBox(height: 12.0),

            OutlinedButton.icon(
              onPressed: () async {
                final updatedTask = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EditTaskScreen(task: task)),
                );

                if (updatedTask == "delete" && context.mounted) {
                  Navigator.pop(context, "delete");
                  return;
                }

                if (updatedTask != null && context.mounted) {
                  task.title = updatedTask.title;
                  task.description = updatedTask.description;
                  task.dueDate = updatedTask.dueDate;
                  task.priority = updatedTask.priority;
                  task.isCompleted = updatedTask.isCompleted;
                  task.isFavourite = updatedTask.isFavourite;
                  Navigator.pop(context, task);
                }
              },
              icon: const Icon(Icons.edit),
              label: const Text('Edit Task'),
            ),
            const SizedBox(height: 24.0),
          ],
        ),
      ),
    );
  }
}
