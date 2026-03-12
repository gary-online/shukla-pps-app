import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shukla_pps/config/theme.dart';
import 'package:shukla_pps/models/submission_status.dart';
import 'package:shukla_pps/models/request_type.dart';
import 'package:shukla_pps/providers/submission_providers.dart';
import 'package:shukla_pps/providers/auth_providers.dart';
import 'package:shukla_pps/widgets/submission_card.dart';
import 'package:shukla_pps/widgets/empty_state.dart';
import 'package:shukla_pps/widgets/error_state.dart';
import 'package:shukla_pps/widgets/skeleton_card.dart';

class SubmissionListScreen extends ConsumerStatefulWidget {
  const SubmissionListScreen({super.key});

  @override
  ConsumerState<SubmissionListScreen> createState() => _SubmissionListScreenState();
}

class _SubmissionListScreenState extends ConsumerState<SubmissionListScreen> {
  SubmissionStatus? _statusFilter;
  String? _typeFilter;

  SubmissionFilters get _filters => SubmissionFilters(
    status: _statusFilter,
    requestType: _typeFilter,
  );

  bool get _hasFilters => _statusFilter != null || _typeFilter != null;

  void _showFilterSheet() {
    // Use local copies so the outer state only changes on Apply
    SubmissionStatus? localStatus = _statusFilter;
    String? localType = _typeFilter;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return SafeArea(
              child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Filters', style: Theme.of(ctx).textTheme.titleMedium),
                      TextButton(
                        onPressed: () {
                          setSheetState(() {
                            localStatus = null;
                            localType = null;
                          });
                        },
                        child: const Text('Clear all'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Status', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: localStatus == null,
                        onSelected: (_) => setSheetState(() => localStatus = null),
                      ),
                      ...SubmissionStatus.values.map((s) => FilterChip(
                        label: Text(s.label),
                        selected: localStatus == s,
                        selectedColor: s.color.withValues(alpha: 0.2),
                        onSelected: (_) => setSheetState(() => localStatus = localStatus == s ? null : s),
                      )),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Type', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textSecondary)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: localType == null,
                        onSelected: (_) => setSheetState(() => localType = null),
                      ),
                      ...RequestType.values.map((rt) => FilterChip(
                        label: Text(rt.label),
                        selected: localType == rt.jsonValue,
                        onSelected: (_) => setSheetState(() => localType = localType == rt.jsonValue ? null : rt.jsonValue),
                      )),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        setState(() {
                          _statusFilter = localStatus;
                          _typeFilter = localType;
                        });
                      },
                      child: const Text('Apply Filters'),
                    ),
                  ),
                ],
              ),
            ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(isAdminProvider);
    final submissionsAsync = ref.watch(submissionListProvider(_filters));

    return Column(
      children: [
        // Filter button bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              OutlinedButton.icon(
                onPressed: _showFilterSheet,
                icon: const Icon(Icons.filter_list, size: 18),
                label: Text(_hasFilters ? 'Filtered' : 'Filter'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _hasFilters ? AppTheme.primaryBlue : AppTheme.textSecondary,
                  side: BorderSide(color: _hasFilters ? AppTheme.primaryBlue : Colors.grey.shade300),
                ),
              ),
              if (_hasFilters) ...[
                const SizedBox(width: 8),
                ActionChip(
                  label: const Text('Clear'),
                  onPressed: () => setState(() {
                    _statusFilter = null;
                    _typeFilter = null;
                  }),
                ),
              ],
            ],
          ),
        ),

        // List
        Expanded(
          child: submissionsAsync.when(
            loading: () => const SkeletonList(),
            error: (err, _) => ErrorState(
              message: 'Could not load submissions',
              onRetry: () => ref.invalidate(submissionListProvider(_filters)),
            ),
            data: (submissions) {
              if (submissions.isEmpty) {
                return EmptyState(
                  message: _hasFilters
                      ? 'No results found.\nTry adjusting or clearing your filters.'
                      : 'No submissions yet',
                  icon: Icons.search_off,
                );
              }
              return RefreshIndicator(
                onRefresh: () async => ref.invalidate(submissionListProvider(_filters)),
                child: ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: submissions.length,
                  itemBuilder: (context, index) {
                    final sub = submissions[index];
                    return SubmissionCard(
                      submission: sub,
                      showRepName: isAdmin,
                      onTap: () => context.push('/submissions/${sub.id}'),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
