import 'package:flutter/material.dart';
import 'package:spicebox/core/theme/app_theme.dart';

import 'router.dart';

class SpiceOSApp extends StatelessWidget {
  const SpiceOSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'SpiceOS',
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}