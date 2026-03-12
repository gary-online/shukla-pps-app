import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shukla_pps/config/theme.dart';
import 'package:shukla_pps/config/constants.dart';
import 'package:shukla_pps/models/submission_status.dart';
import 'package:shukla_pps/providers/submission_providers.dart';
import 'package:shukla_pps/providers/auth_providers.dart';
import 'package:shukla_pps/providers/repository_providers.dart';
import 'package:shukla_pps/widgets/status_badge.dart';
import 'package:shukla_pps/widgets/error_state.dart';
import 'package:shukla_pps/widgets/section_header.dart';
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
        error: (err, _) => ErrorState(
          message: 'Could not load submission',
          onRetry: () => ref.invalidate(submissionDetailProvider(submissionId)),
        ),
        data: (submission) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Header card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(submission.requestType.icon, color: AppTheme.primaryBlue, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              submission.requestType.label,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          StatusBadge(status: submission.status),
                        ],
                      ),
                      if (submission.source == 'phone')
                        Padding(
                          padding: const EdgeInsets.only(top: 8, left: 52),
                          child: Row(
                            children: [
                              Icon(Icons.phone, size: 14, color: AppTheme.textSecondary),
                              const SizedBox(width: 4),
                              Text('Submitted via phone', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Fields card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(title: 'Details'),
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
              const SizedBox(height: 20),

              // Status timeline
              const SectionHeader(title: 'Status Timeline'),
              historyAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (err, _) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text('Error loading history', style: TextStyle(color: AppTheme.textSecondary)),
                  ),
                ),
                data: (history) {
                  if (history.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: submission.status.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text('Created as ${submission.status.label}'),
                          ],
                        ),
                      ),
                    );
                  }
                  return Card(
                    child: Column(
                      children: history.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        final ts = DateTime.tryParse(item.createdAt);
                        final isLast = index == history.length - 1;
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 10,
                                    height: 10,
                                    margin: const EdgeInsets.only(top: 4),
                                    decoration: BoxDecoration(
                                      color: item.status.color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(item.status.label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                        if (item.changedByName != null)
                                          Text('by ${item.changedByName}', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                                        if (item.note != null)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 4),
                                            child: Text(item.note!, style: const TextStyle(fontSize: 14)),
                                          ),
                                        if (ts != null)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 2),
                                            child: Text(timeago.format(ts), style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!isLast) const Divider(height: 1, indent: 36),
                          ],
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 80), // space for bottom button
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
                  Text('Update Status', style: Theme.of(ctx).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
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
          SizedBox(
            width: 100,
            child: Text(label, style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
