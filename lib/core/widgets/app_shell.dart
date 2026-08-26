import 'package:flutter/material.dart';

import 'app_sidebar.dart';
import 'app_top_bar.dart';
import 'responsive_layout.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final mobile = ResponsiveLayout.isMobile(context);

    return Scaffold(
      appBar: const AppTopBar(title: 'SpiceOS'),
      drawer: mobile
          ? const Drawer(
              width: 300,
              child: SafeArea(child: AppSidebar()),
            )
          : null,
      body: Row(
        children: [
          if (!mobile) const AppSidebar(),
          Expanded(
            child: Container(
              color: const Color(0xffF8FAFC),
              padding: EdgeInsets.all(mobile ? 12 : 24),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}
