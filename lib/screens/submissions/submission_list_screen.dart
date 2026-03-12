import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shukla_pps/models/submission_status.dart';
import 'package:shukla_pps/models/request_type.dart';
import 'package:shukla_pps/providers/submission_providers.dart';
import 'package:shukla_pps/providers/auth_providers.dart';
import 'package:shukla_pps/widgets/submission_card.dart';
import 'package:shukla_pps/widgets/empty_state.dart';

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

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(isAdminProvider);
    final submissionsAsync = ref.watch(submissionListProvider(_filters));

    return Column(
      children: [
        // Status filter bar
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              FilterChip(
                label: const Text('All Statuses'),
                selected: _statusFilter == null,
                onSelected: (_) => setState(() => _statusFilter = null),
              ),
              const SizedBox(width: 8),
              ...SubmissionStatus.values.map((s) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(s.label),
                  selected: _statusFilter == s,
                  selectedColor: s.color.withValues(alpha: 0.2),
                  onSelected: (_) => setState(() => _statusFilter = _statusFilter == s ? null : s),
                ),
              )),
            ],
          ),
        ),
        // Type filter bar
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              FilterChip(
                label: const Text('All Types'),
                selected: _typeFilter == null,
                onSelected: (_) => setState(() => _typeFilter = null),
              ),
              const SizedBox(width: 8),
              ...RequestType.values.map((rt) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(rt.label),
                  selected: _typeFilter == rt.jsonValue,
                  onSelected: (_) => setState(() => _typeFilter = _typeFilter == rt.jsonValue ? null : rt.jsonValue),
                ),
              )),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // List
        Expanded(
          child: submissionsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error: $err')),
            data: (submissions) {
              if (submissions.isEmpty) {
                return const EmptyState(
                  message: 'No results found',
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
