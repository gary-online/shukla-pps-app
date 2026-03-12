import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shukla_pps/providers/submission_providers.dart';
import 'package:shukla_pps/widgets/submission_card.dart';
import 'package:shukla_pps/widgets/empty_state.dart';

class RepHomeScreen extends ConsumerWidget {
  const RepHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final submissionsAsync = ref.watch(recentSubmissionsProvider);

    return submissionsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
      data: (submissions) {
        if (submissions.isEmpty) {
          return EmptyState(
            message: 'No submissions yet',
            actionLabel: 'Create your first submission',
            onAction: () => context.push('/submission/new'),
            icon: Icons.note_add,
          );
        }

        return RefreshIndicator(
          onRefresh: () async => ref.invalidate(recentSubmissionsProvider),
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 80),
            itemCount: submissions.length,
            itemBuilder: (context, index) {
              final sub = submissions[index];
              return SubmissionCard(
                submission: sub,
                onTap: () => context.push('/submissions/${sub.id}'),
              );
            },
          ),
        );
      },
    );
  }
}
