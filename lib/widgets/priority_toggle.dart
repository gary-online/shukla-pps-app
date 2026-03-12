import 'package:flutter/material.dart';
import 'package:shukla_pps/config/theme.dart';
import 'package:shukla_pps/models/priority.dart';

class PriorityToggle extends StatelessWidget {
  const PriorityToggle({super.key, required this.value, required this.onChanged});

  final Priority value;
  final ValueChanged<Priority> onChanged;

  @override
  Widget build(BuildContext context) {
    final isUrgent = value == Priority.urgent;
    return Row(
      children: [
        const Text('Priority:', style: TextStyle(fontSize: 16)),
        const SizedBox(width: 12),
        Text(
          isUrgent ? 'Urgent' : 'Normal',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isUrgent ? AppTheme.urgentRed : AppTheme.textSecondary,
          ),
        ),
        const SizedBox(width: 8),
        Switch(
          value: isUrgent,
          activeTrackColor: AppTheme.urgentRed,
          activeThumbColor: Colors.white,
          onChanged: (val) => onChanged(val ? Priority.urgent : Priority.normal),
        ),
      ],
    );
  }
}
