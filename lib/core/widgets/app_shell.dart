import 'package:flutter/material.dart';

import 'app_sidebar.dart';
import 'app_top_bar.dart';

class AppShell extends StatelessWidget {
  final String title;
  final Widget child;

  const AppShell({
    super.key,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppTopBar(title: title),
      body: Row(
        children: [
          const AppSidebar(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}