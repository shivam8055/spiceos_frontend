import 'package:flutter/material.dart';

import '../../../core/widgets/app_shell.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/kpi_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      child: GridView.count(
        crossAxisCount: 4,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1.1,
        children: [
          KpiCard(
            kpi: dashboardData[0],
            icon: Icons.currency_rupee,
            color: Colors.green,
          ),
          KpiCard(
            kpi: dashboardData[1],
            icon: Icons.receipt_long,
            color: Colors.deepOrange,
          ),
          KpiCard(
            kpi: dashboardData[2],
            icon: Icons.people,
            color: Colors.blue,
          ),
          KpiCard(
            kpi: dashboardData[3],
            icon: Icons.delivery_dining,
            color: Colors.purple,
          ),
        ],
      ),
    );
  }
}