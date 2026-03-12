import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shukla_pps/config/theme.dart';
import 'package:shukla_pps/models/submission_status.dart';
import 'package:shukla_pps/providers/submission_providers.dart';
import 'package:shukla_pps/widgets/submission_card.dart';
import 'package:shukla_pps/widgets/skeleton_card.dart';
import 'package:shukla_pps/widgets/error_state.dart';
import 'package:shukla_pps/widgets/section_header.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  int _selectedRange = 1; // 0=Today, 1=This Week, 2=This Month
  late DateRange? _dateRange = DateRange.thisWeek();

  void _setRange(int index) {
    setState(() {
      _selectedRange = index;
      _dateRange = switch (index) {
        0 => DateRange.today(),
        1 => DateRange.thisWeek(),
        2 => DateRange.thisMonth(),
        _ => null,
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    final countsAsync = ref.watch(statusCountsProvider(_dateRange));
    final recentAsync = ref.watch(recentSubmissionsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        _setRange(_selectedRange);
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
            onSelectionChanged: (val) => _setRange(val.first),
            style: SegmentedButton.styleFrom(
              textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 16),

          // Status count cards
          countsAsync.when(
            loading: () => const SizedBox(
              height: 120,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, _) => ErrorState(
              message: 'Could not load counts',
              onRetry: () => _setRange(_selectedRange),
            ),
            data: (counts) {
              return Column(
                children: [
                  Row(
                    children: [
                      _CountCard(
                        label: 'Pending',
                        count: counts[SubmissionStatus.pending] ?? 0,
                        color: AppTheme.statusPending,
                        icon: Icons.schedule,
                      ),
                      const SizedBox(width: 10),
                      _CountCard(
                        label: 'Active',
                        count: counts[SubmissionStatus.inProgress] ?? 0,
                        color: AppTheme.statusInProgress,
                        icon: Icons.trending_up,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _CountCard(
                        label: 'Completed',
                        count: counts[SubmissionStatus.completed] ?? 0,
                        color: AppTheme.statusCompleted,
                        icon: Icons.check_circle_outline,
                      ),
                      const SizedBox(width: 10),
                      _CountCard(
                        label: 'Cancelled',
                        count: counts[SubmissionStatus.cancelled] ?? 0,
                        color: AppTheme.statusCancelled,
                        icon: Icons.cancel_outlined,
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Recent activity header
          const SectionHeader(title: 'Recent Activity'),

          recentAsync.when(
            loading: () => Column(
              children: List.generate(3, (_) => const SkeletonCard()),
            ),
            error: (err, _) => ErrorState(
              message: 'Could not load activity',
              onRetry: () => ref.invalidate(recentSubmissionsProvider),
            ),
            data: (submissions) {
              if (submissions.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(Icons.inbox_outlined, size: 40, color: AppTheme.textSecondary),
                        const SizedBox(height: 8),
                        Text('No recent submissions', style: TextStyle(color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),
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
  const _CountCard({required this.label, required this.count, required this.color, required this.icon});

  final String label;
  final int count;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$count', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
                    Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
