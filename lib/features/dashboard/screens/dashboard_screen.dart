import 'package:flutter/material.dart';

import '../../../core/widgets/app_shell.dart';
import '../widgets/ai_insights.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_stats.dart';
import '../widgets/inventory_alerts.dart';
import '../widgets/kitchen_queue.dart';
import '../widgets/recent_orders_card.dart';
import '../widgets/sales_chart.dart';
import '../widgets/quick_actions.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShell(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const DashboardHeader(),
            const SizedBox(height: 24),
            const DashboardStats(),
            const SizedBox(height: 24),
            const QuickActions(),
            const SizedBox(height: 24),
            const AiInsights(),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Expanded(flex: 2, child: SalesChart()),
                SizedBox(width: 24),
                Expanded(child: KitchenQueue()),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Expanded(child: RecentOrdersCard()),
                SizedBox(width: 24),
                Expanded(child: InventoryAlerts()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
