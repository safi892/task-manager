import 'package:flutter/material.dart';
import 'package:task_manager/core/app_theme.dart';

Color getPriorityColor(BuildContext context, String priority) {
  final colorScheme = Theme.of(context).colorScheme;
  final custom = Theme.of(context).extension<AppCustomColors>()!;

  switch (priority) {
    case 'High':
      return colorScheme.error;
    case 'Medium':
      return custom.warning;
    case 'Low':
      return custom.success;
    default:
      return colorScheme.primary;
  }
}