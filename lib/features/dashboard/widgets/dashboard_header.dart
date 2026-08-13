import 'package:flutter/material.dart';

import '../../../core/widgets/app_page_header.dart';

class DashboardHeader extends StatelessWidget {
  const DashboardHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppPageHeader(
      title: 'Dashboard',
      subtitle: 'Welcome to SpiceOS',
    );
  }
}
