import 'package:flutter/material.dart';


import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/badges/app_status_badge.dart';
import '../../../core/widgets/cards/app_card.dart';

class KitchenQueue extends StatelessWidget {
  const KitchenQueue({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = [
      ('#1024', 'Paneer Butter Masala', AppStatus.cooking),
      ('#1025', 'Chicken Biryani', AppStatus.ready),
      ('#1026', 'Veg Fried Rice', AppStatus.cooking),
      ('#1027', 'Butter Naan', AppStatus.pending),
    ];

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kitchen Queue',
            style: AppTextStyles.heading3,
          ),

          const SizedBox(height: AppSpacing.lg),

          ...orders.map(
                (order) => Padding(
              padding: const EdgeInsets.only(
                bottom: AppSpacing.md,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${order.$1} • ${order.$2}',
                      style: AppTextStyles.bodyLarge,
                    ),
                  ),

                  AppStatusBadge(
                    status: order.$3,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}