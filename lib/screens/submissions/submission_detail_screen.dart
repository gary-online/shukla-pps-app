import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shukla_pps/config/theme.dart';
import 'package:shukla_pps/config/constants.dart';
import 'package:shukla_pps/models/submission_status.dart';
import 'package:shukla_pps/providers/submission_providers.dart';
import 'package:shukla_pps/providers/auth_providers.dart';
import 'package:shukla_pps/providers/repository_providers.dart';
import 'package:shukla_pps/widgets/status_badge.dart';
import 'package:timeago/timeago.dart' as timeago;

class SubmissionDetailScreen extends ConsumerWidget {
  const SubmissionDetailScreen({super.key, required this.submissionId});

  final String submissionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subAsync = ref.watch(submissionDetailProvider(submissionId));
    final historyAsync = ref.watch(statusHistoryProvider(submissionId));
    final isAdmin = ref.watch(isAdminProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Submission Detail')),
      body: subAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (submission) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header
              Row(
                children: [
                  Icon(submission.requestType.icon, color: AppTheme.primaryBlue, size: 28),
                  const SizedBox(width: 8),
                  Text(submission.requestType.label, style: Theme.of(context).textTheme.titleLarge),
                  const Spacer(),
                  StatusBadge(status: submission.status),
                ],
              ),
              if (submission.source == 'phone')
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('Submitted via phone', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                ),
              const SizedBox(height: 16),

              // Fields card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      if (submission.repName != null)
                        _DetailRow(label: 'Rep', value: submission.repName!),
                      if (submission.surgeon != null)
                        _DetailRow(label: fieldLabels['surgeon']!, value: submission.surgeon!),
                      if (submission.facility != null)
                        _DetailRow(label: fieldLabels['facility']!, value: submission.facility!),
                      if (submission.trayType != null)
                        _DetailRow(label: fieldLabels['tray_type']!, value: submission.trayType!),
                      if (submission.surgeryDate != null)
                        _DetailRow(label: fieldLabels['surgery_date']!, value: submission.surgeryDate!),
                      if (submission.details != null)
                        _DetailRow(label: fieldLabels['details']!, value: submission.details!),
                      _DetailRow(label: 'Priority', value: submission.priority.label),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Status timeline
              Text('Status Timeline', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              historyAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Text('Error loading history: $err'),
                data: (history) {
                  if (history.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.circle, size: 12, color: submission.status.color),
                            const SizedBox(width: 12),
                            Text('Created as ${submission.status.label}'),
                          ],
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: history.map((entry) {
                      final ts = DateTime.tryParse(entry.createdAt);
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.circle, size: 12, color: entry.status.color),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(entry.status.label, style: const TextStyle(fontWeight: FontWeight.w600)),
                                    if (entry.changedByName != null)
                                      Text('by ${entry.changedByName}', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                                    if (entry.note != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(entry.note!, style: const TextStyle(fontSize: 14)),
                                      ),
                                    if (ts != null)
                                      Text(timeago.format(ts), style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          );
        },
      ),

      // Admin: Update Status button
      bottomNavigationBar: isAdmin
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () => _showUpdateStatusSheet(context, ref),
                  child: const Text('Update Status'),
                ),
              ),
            )
          : null,
    );
  }

  void _showUpdateStatusSheet(BuildContext context, WidgetRef ref) {
    SubmissionStatus? selected;
    final noteController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16, right: 16, top: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Update Status', style: Theme.of(ctx).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  RadioGroup<SubmissionStatus>(
                    groupValue: selected,
                    onChanged: (val) => setSheetState(() => selected = val),
                    child: Column(
                      children: SubmissionStatus.values.map((s) => RadioListTile<SubmissionStatus>(
                        title: Text(s.label),
                        value: s,
                        activeColor: s.color,
                      )).toList(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: noteController,
                    decoration: const InputDecoration(labelText: 'Note (optional)', hintText: 'Add a note...'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: selected == null ? null : () async {
                        await ref.read(submissionRepositoryProvider).updateStatus(
                          submissionId: submissionId,
                          newStatus: selected!,
                          note: noteController.text.isNotEmpty ? noteController.text : null,
                        );
                        if (ctx.mounted) Navigator.pop(ctx);
                        ref.invalidate(submissionDetailProvider(submissionId));
                        ref.invalidate(statusHistoryProvider(submissionId));
                      },
                      child: const Text('Update'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label, style: TextStyle(color: AppTheme.textSecondary))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }
}
