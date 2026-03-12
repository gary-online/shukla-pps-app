import 'package:flutter/material.dart';
import 'package:shukla_pps/models/submission_status.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final SubmissionStatus status;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Status: ${status.label}',
      child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: status.color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      ),
    );
  }
}
