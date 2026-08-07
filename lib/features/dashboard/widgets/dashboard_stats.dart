import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_spacing.dart';
import '../providers/dashboard_provider.dart';
import 'kpi_card.dart';

class DashboardStats extends StatelessWidget {
  const DashboardStats({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final crossAxisCount = width < 600
        ? 1
        : width < 900
        ? 2
        : width < 1200
        ? 3
        : 4;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: dashboardData.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: AppSpacing.lg,
        mainAxisSpacing: AppSpacing.lg,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, index) {
        final icons = [
          AppIcons.revenue,
          AppIcons.orders,
          AppIcons.customers,
          AppIcons.delivery,
        ];

        final colors = [
          AppColors.success,
          AppColors.primary,
          AppColors.info,
          AppColors.secondary,
        ];

        return KpiCard(
          kpi: dashboardData[index],
          icon: icons[index],
          color: colors[index],
        );
      },
    );
  }
}