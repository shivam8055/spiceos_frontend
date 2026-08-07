import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_shell.dart';
import '../providers/orders_provider.dart';
import '../widgets/order_card.dart';
import '../widgets/order_filter_bar.dart';
import '../widgets/orders_header.dart';
import '../widgets/orders_statistics.dart';
import 'order_details_screen.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/widgets/inputs/app_text_field.dart';
import '../../../core/theme/app_spacing.dart';

class OrdersScreen extends ConsumerWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(filteredOrdersProvider);

    return AppShell(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const OrdersHeader(),

            const SizedBox(height: AppSpacing.lg),

            const OrdersStatistics(),

            const SizedBox(height: AppSpacing.lg),

            AppTextField(
              hint: 'Search orders...',
              prefixIcon: AppIcons.search,
            ),

            const SizedBox(height: AppSpacing.md),

            const OrderFilters(),

            const SizedBox(height: AppSpacing.lg),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: orders.length,
              separatorBuilder: (context, index) =>
              const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return OrderCard(
                  order: orders[index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            OrderDetailsScreen(
                              order: orders[index],
                            ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}