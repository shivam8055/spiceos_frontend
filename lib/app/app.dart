import 'package:flutter/material.dart';
import 'package:spicebox/core/theme/app_theme.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router.dart';

class SpiceOSApp extends ConsumerWidget {
  const SpiceOSApp({super.key});

  @override
Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'SpiceOS',
      theme: AppTheme.lightTheme,
      routerConfig: createRouter(ref),
    );
  }
}