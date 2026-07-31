import 'package:flutter/material.dart';

import '../providers/dashboard_provider.dart';
import 'kpi_card.dart';

class DashboardStats extends StatelessWidget {
  const DashboardStats({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: dashboardData.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1.05,
      ),
      itemBuilder: (context, index) {
        final icons = [
          Icons.currency_rupee,
          Icons.receipt_long,
          Icons.people,
          Icons.delivery_dining,
        ];

        final colors = [
          Colors.green,
          Colors.deepOrange,
          Colors.blue,
          Colors.purple,
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