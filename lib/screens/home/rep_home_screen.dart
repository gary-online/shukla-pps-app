import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shukla_pps/providers/submission_providers.dart';
import 'package:shukla_pps/widgets/submission_card.dart';
import 'package:shukla_pps/widgets/empty_state.dart';
import 'package:shukla_pps/widgets/error_state.dart';
import 'package:shukla_pps/widgets/skeleton_card.dart';
import 'package:shukla_pps/widgets/section_header.dart';

class RepHomeScreen extends ConsumerWidget {
  const RepHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submissionsAsync = ref.watch(recentSubmissionsProvider);

    return submissionsAsync.when(
      loading: () => const SkeletonList(),
      error: (err, _) => ErrorState(
        message: 'Could not load submissions',
        onRetry: () => ref.invalidate(recentSubmissionsProvider),
      ),
      data: (submissions) {
        if (submissions.isEmpty) {
          return EmptyState(
            message: 'No submissions yet',
            actionLabel: 'Create your first submission',
            onAction: () => context.push('/submission/new'),
            icon: Icons.note_add_outlined,
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(recentSubmissionsProvider),
          child: ListView(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: SectionHeader(title: 'Recent Submissions'),
              ),
              ...submissions.map((sub) => SubmissionCard(
                submission: sub,
                onTap: () => context.push('/submissions/${sub.id}'),
              )),
            ],
          ),
        );
      },
    );
  }
}
