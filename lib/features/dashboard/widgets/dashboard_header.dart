import 'package:flutter/material.dart';

import '../../../core/widgets/app_page_header.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return AppPageHeader(
      title: 'Dashboard',
      subtitle: 'Welcome to SpiceOS',
      action: FilledButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('New Order'),
      ),
    );
  }
}