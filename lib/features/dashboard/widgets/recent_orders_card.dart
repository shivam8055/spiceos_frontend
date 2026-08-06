import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/cards/app_card.dart';

class RecentOrdersCard extends StatelessWidget {
  const RecentOrdersCard({super.key});

  @override
  Widget build(BuildContext context) {
    final recentOrders = [
      ('#1027', 'Rahul Kumar', '₹420'),
      ('#1026', 'Priya Singh', '₹310'),
      ('#1025', 'Aman Verma', '₹580'),
      ('#1024', 'Neha Sharma', '₹240'),
    ];

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Orders',
            style: AppTextStyles.heading3,
          ),

          const SizedBox(height: AppSpacing.lg),

          ...recentOrders.map(
                (order) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                child: const Icon(
                  AppIcons.orders,
                  color: AppColors.primary,
                ),
              ),
              title: Text(
                order.$2,
                style: AppTextStyles.bodyLarge,
              ),
              subtitle: Text(
                order.$1,
                style: AppTextStyles.caption,
              ),
              trailing: Text(
                order.$3,
                style: AppTextStyles.title,
              ),
            ),
          ),
        ],
      ),
    );
  }
}