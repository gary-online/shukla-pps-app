import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shukla_pps/config/theme.dart';
import 'package:shukla_pps/config/constants.dart';
import 'package:shukla_pps/providers/repository_providers.dart';

class ConfirmationScreen extends ConsumerStatefulWidget {
  const ConfirmationScreen({super.key, required this.submissionData});

  final Map<String, dynamic> submissionData;

  @override
  ConsumerState<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends ConsumerState<ConfirmationScreen> {
  bool _isSubmitting = false;
  String? _error;

  Future<void> _submit() async {
    setState(() { _isSubmitting = true; _error = null; });

    try {
      // Remove display-only fields before submitting
      final data = Map<String, dynamic>.from(widget.submissionData)
        ..removeWhere((key, _) => key.startsWith('_'));

      final submission = await ref.read(submissionRepositoryProvider).create(data);
      if (mounted) {
        context.go('/submission/success', extra: submission.id);
      }
    } catch (e) {
      setState(() { _error = 'Submission failed. Please try again.'; _isSubmitting = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.submissionData;
    final isUrgent = data['priority'] == 'urgent';

    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Submission')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (isUrgent)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: AppTheme.urgentRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.urgentRed),
              ),
              child: const Row(
                children: [
                  Icon(Icons.priority_high, color: AppTheme.urgentRed),
                  SizedBox(width: 8),
                  Text('URGENT', style: TextStyle(color: AppTheme.urgentRed, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

          _ReviewRow(label: 'Request Type', value: data['_request_type_label'] ?? ''),
          if (data['surgeon'] != null) _ReviewRow(label: fieldLabels['surgeon']!, value: data['surgeon']),
          if (data['facility'] != null) _ReviewRow(label: fieldLabels['facility']!, value: data['facility']),
          if (data['tray_type'] != null) _ReviewRow(label: fieldLabels['tray_type']!, value: data['tray_type']),
          if (data['surgery_date'] != null) _ReviewRow(label: fieldLabels['surgery_date']!, value: data['surgery_date']),
          if (data['details'] != null) _ReviewRow(label: fieldLabels['details']!, value: data['details']),
          _ReviewRow(label: 'Priority', value: data['_priority_label'] ?? 'Normal'),

          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(_error!, style: const TextStyle(color: AppTheme.urgentRed), textAlign: TextAlign.center),
            ),

          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isSubmitting ? null : () => context.pop(),
                  child: const Text('Edit'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Submit'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
