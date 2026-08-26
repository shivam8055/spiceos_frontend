import 'package:flutter/material.dart';

import '../../../core/widgets/app_shell.dart';
import '../../../core/widgets/responsive_layout.dart';
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
    final mobile = ResponsiveLayout.isMobile(context);

    return AppShell(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const DashboardHeader(),
            SizedBox(height: mobile ? 14 : 24),
            const DashboardStats(),
            SizedBox(height: mobile ? 14 : 24),
            const QuickActions(),
            SizedBox(height: mobile ? 14 : 24),
            const AiInsights(),
            SizedBox(height: mobile ? 14 : 24),
            if (mobile) ...[
              const SalesChart(),
              const SizedBox(height: 14),
              const KitchenQueue(),
              const SizedBox(height: 14),
              const RecentOrdersCard(),
              const SizedBox(height: 14),
              const InventoryAlerts(),
            ] else ...[
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
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
