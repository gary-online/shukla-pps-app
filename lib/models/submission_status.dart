import 'package:flutter/material.dart';

enum SubmissionStatus {
  pending(label: 'Pending', color: Colors.grey, jsonValue: 'pending'),
  inProgress(label: 'In Progress', color: Colors.blue, jsonValue: 'in_progress'),
  completed(label: 'Completed', color: Colors.green, jsonValue: 'completed'),
  cancelled(label: 'Cancelled', color: Colors.red, jsonValue: 'cancelled');

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
