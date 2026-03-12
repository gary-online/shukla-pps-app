import 'package:flutter/material.dart';
import 'package:shukla_pps/config/theme.dart';

enum SubmissionStatus {
  pending(label: 'Pending', color: AppTheme.statusPending, jsonValue: 'pending'),
  inProgress(label: 'In Progress', color: AppTheme.statusInProgress, jsonValue: 'in_progress'),
  completed(label: 'Completed', color: AppTheme.statusCompleted, jsonValue: 'completed'),
  cancelled(label: 'Cancelled', color: AppTheme.statusCancelled, jsonValue: 'cancelled');

  const SubmissionStatus({
    required this.label,
    required this.color,
    required this.jsonValue,
  });

  final String label;
  final Color color;
  final String jsonValue;

  String toJson() => jsonValue;

  static SubmissionStatus fromJson(String value) {
    return SubmissionStatus.values.firstWhere((e) => e.jsonValue == value);
  }
}
