import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/cards/app_card.dart';
import '../models/dashboard_kpi.dart';

class KpiCard extends StatelessWidget {
  final DashboardKpi kpi;
  final IconData icon;
  final Color color;

  const KpiCard({
    super.key,
    required this.kpi,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(
              icon,
              color: color,
            ),
          ),

          const Spacer(),

          Text(
            kpi.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          Text(
            kpi.value,
            maxLines: 1,
            style: AppTextStyles.display,
          ),

          const SizedBox(height: AppSpacing.sm),

          Text(
            kpi.subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.label.copyWith(
              color: kpi.positive
                  ? AppColors.success
                  : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}