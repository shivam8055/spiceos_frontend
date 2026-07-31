import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/order_filter.dart';
import '../providers/order_filter_provider.dart';

class OrderFilters extends ConsumerWidget {
  const OrderFilters({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(orderFilterProvider);

    Widget buildChip(OrderFilter filter, String label) {
      return ChoiceChip(
        label: Text(label),
        selected: selected == filter,
        onSelected: (_) {
          ref.read(orderFilterProvider.notifier).state = filter;
        },
      );
    }

    return Wrap(
      spacing: 10,
      children: [
        buildChip(OrderFilter.all, 'All'),
        buildChip(OrderFilter.preparing, 'Preparing'),
        buildChip(OrderFilter.ready, 'Ready'),
        buildChip(OrderFilter.delivery, 'Delivery'),
        buildChip(OrderFilter.delivered, 'Delivered'),
      ],
    );
  }
}