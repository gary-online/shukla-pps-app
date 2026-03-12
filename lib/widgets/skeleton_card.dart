import 'package:flutter/material.dart';
import 'package:shukla_pps/config/theme.dart';

class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              _SkeletonBox(width: 44, height: 44, borderRadius: 10),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SkeletonBox(width: 140, height: 14, borderRadius: 4),
                    const SizedBox(height: 8),
                    _SkeletonBox(width: 200, height: 12, borderRadius: 4),
                    const SizedBox(height: 6),
                    _SkeletonBox(width: 80, height: 10, borderRadius: 4),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _SkeletonBox(width: 64, height: 24, borderRadius: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({required this.width, required this.height, required this.borderRadius});

  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.divider,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class SkeletonList extends StatelessWidget {
  const SkeletonList({super.key, this.itemCount = 5});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (_, __) => const SkeletonCard(),
    );
  }
}
