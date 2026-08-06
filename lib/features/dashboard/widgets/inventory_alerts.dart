import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/cards/app_card.dart';

class InventoryAlerts extends StatelessWidget {
  const InventoryAlerts({super.key});

  @override
  Widget build(BuildContext context) {
    final alerts = [
      ('Paneer', 'Low Stock'),
      ('Rice', 'Restock Soon'),
      ('Cooking Oil', 'Critical'),
    ];

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Inventory Alerts',
            style: AppTextStyles.heading3,
          ),

          const SizedBox(height: AppSpacing.md),

          ...alerts.map(
                (item) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                AppIcons.warning,
                color: AppColors.warning,
              ),
              title: Text(
                item.$1,
                style: AppTextStyles.bodyLarge,
              ),
              subtitle: Text(
                item.$2,
                style: AppTextStyles.caption,
              ),
            ),
          ),
        ],
      ),
    );
  }
}