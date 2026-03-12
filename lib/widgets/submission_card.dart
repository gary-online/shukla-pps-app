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
    final subtitle = [submission.trayType, submission.facility].whereType<String>().join(' \u2022 ');

    return Semantics(
      label: '${submission.requestType.label} submission, status ${submission.status.label}${showRepName && submission.repName != null ? ', by ${submission.repName}' : ''}, $timeAgo',
      button: onTap != null,
      child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(submission.requestType.icon, color: AppTheme.primaryBlue, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        submission.requestType.label,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      if (showRepName && submission.repName != null)
                        Text(submission.repName!, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                      if (subtitle.isNotEmpty)
                        Text(
                          subtitle,
                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 4),
                      Text(timeAgo, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                StatusBadge(status: submission.status),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}
