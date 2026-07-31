import 'package:flutter/material.dart';

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
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(
                icon,
                color: color,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              kpi.title,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              kpi.value,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              kpi.subtitle,
              style: TextStyle(
                color: kpi.positive ? Colors.green : Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}