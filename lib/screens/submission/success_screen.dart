import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shukla_pps/config/theme.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key, required this.submissionId});

  final String submissionId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, size: 80, color: AppTheme.statusCompleted),
                const SizedBox(height: 16),
                Text('Submission Sent!', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('ID: ${submissionId.substring(0, 8)}...', style: const TextStyle(color: AppTheme.textSecondary)),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.go('/submissions/$submissionId'),
                    child: const Text('View Submission'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => context.go('/submission/new'),
                    child: const Text('Submit Another'),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => context.go('/'),
                  child: const Text('Back to Home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
