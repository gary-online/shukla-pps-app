import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shukla_pps/config/theme.dart';
import 'package:shukla_pps/models/submission_status.dart';
import 'package:shukla_pps/providers/submission_providers.dart';
import 'package:shukla_pps/widgets/submission_card.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  int _selectedRange = 0; // 0=Today, 1=This Week, 2=This Month

  DateRange? get _dateRange {
    return switch (_selectedRange) {
      0 => DateRange.today(),
      1 => DateRange.thisWeek(),
      2 => DateRange.thisMonth(),
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final countsAsync = ref.watch(statusCountsProvider(_dateRange));
    final recentAsync = ref.watch(recentSubmissionsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(statusCountsProvider(_dateRange));
        ref.invalidate(recentSubmissionsProvider);
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Time range toggle
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('Today')),
              ButtonSegment(value: 1, label: Text('This Week')),
              ButtonSegment(value: 2, label: Text('This Month')),
            ],
            selected: {_selectedRange},
            onSelectionChanged: (val) => setState(() => _selectedRange = val.first),
          ),
          const SizedBox(height: 16),

          // Status count cards
          countsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Text('Error: $err'),
            data: (counts) {
              return Row(
                children: [
                  _CountCard(label: 'Pending', count: counts[SubmissionStatus.pending] ?? 0, color: AppTheme.statusPending),
                  const SizedBox(width: 8),
                  _CountCard(label: 'In Progress', count: counts[SubmissionStatus.inProgress] ?? 0, color: AppTheme.statusInProgress),
                  const SizedBox(width: 8),
                  _CountCard(label: 'Completed', count: counts[SubmissionStatus.completed] ?? 0, color: AppTheme.statusCompleted),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Recent activity
          Text('Recent Activity', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          recentAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Text('Error: $err'),
            data: (submissions) {
              if (submissions.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('No recent submissions', textAlign: TextAlign.center),
                );
              }
              return Column(
                children: submissions.map((sub) => SubmissionCard(
                  submission: sub,
                  showRepName: true,
                  onTap: () => context.push('/submissions/${sub.id}'),
                )).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CountCard extends StatelessWidget {
  const _CountCard({required this.label, required this.count, required this.color});

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text('$count', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
              const SizedBox(height: 4),
              Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}
