import 'package:flutter/material.dart';

import 'app_sidebar.dart';
import 'app_top_bar.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(
        title: 'SpiceOS',
      ),
      body: Row(
        children: [
          const AppSidebar(),
          Expanded(
            child: Container(
              color: const Color(0xffF8FAFC),
              padding: const EdgeInsets.all(24),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}