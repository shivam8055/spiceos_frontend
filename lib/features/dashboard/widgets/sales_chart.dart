import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/cards/app_card.dart';

class SalesChart extends StatelessWidget {
  const SalesChart({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: SizedBox(
        height: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sales Overview',
              style: AppTextStyles.heading3,
            ),

            const SizedBox(height: AppSpacing.sm),

            Text(
              'Last 7 Days',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),

            const Spacer(),

            Center(
              child: Icon(
                Icons.show_chart_rounded,
                size: 90,
                color: AppColors.primary,
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            Center(
              child: Text(
                'Chart integration coming in Sprint 5',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}