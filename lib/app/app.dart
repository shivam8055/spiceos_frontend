import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spicebox/core/theme/app_theme.dart';

import '../features/auth/providers/auth_notifier.dart';
import 'router.dart';

final routerProvider = Provider<GoRouter>((ref) => createRouter(ref));

class SpiceOSApp extends ConsumerWidget {
  const SpiceOSApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(authNotifierProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'SpiceOS',
      theme: AppTheme.lightTheme,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
