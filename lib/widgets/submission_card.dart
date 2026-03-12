import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:shukla_pps/models/submission.dart';
import 'package:shukla_pps/widgets/status_badge.dart';
import 'package:shukla_pps/config/theme.dart';

class SubmissionCard extends StatelessWidget {
  const SubmissionCard({super.key, required this.submission, this.showRepName = false, this.onTap});

  final Submission submission;
  final bool showRepName;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final createdAt = DateTime.tryParse(submission.createdAt);
    final timeAgo = createdAt != null ? timeago.format(createdAt) : '';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(submission.requestType.icon, color: AppTheme.primaryBlue, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      submission.requestType.label,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    if (showRepName && submission.repName != null)
                      Text(submission.repName!, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                    Text(
                      [submission.trayType, submission.facility].whereType<String>().join(' • '),
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(timeAgo, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              StatusBadge(status: submission.status),
            ],
          ),
        ),
      ),
    );
  }
}
