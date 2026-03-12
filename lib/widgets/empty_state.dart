import 'package:flutter/material.dart';
import 'package:shukla_pps/config/theme.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.message, this.actionLabel, this.onAction, this.icon});

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon ?? Icons.inbox_outlined, size: 64, color: AppTheme.textSecondary),
            const SizedBox(height: 16),
            Text(message, style: const TextStyle(fontSize: 16, color: AppTheme.textSecondary), textAlign: TextAlign.center),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
