import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/widgets/app_page_header.dart';

class OrdersHeader extends StatelessWidget {
  const OrdersHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPageHeader(
      title: 'Orders',
      subtitle: 'Manage all restaurant orders',
      action: FilledButton.icon(
        onPressed: () {
          context.push('/orders/new');
        },
        icon: const Icon(Icons.add),
        label: const Text('New Order'),
      ),
    );
  }
}