import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spicebox/core/theme/app_theme.dart';

import 'router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  // Keep one router instance alive. Recreating GoRouter whenever auth state
  // changes can reset the active location and make navigation appear to do
  // nothing. Authentication screens explicitly navigate after a successful
  // sign-in/sign-out, while route guards still read the latest auth state.
  return createRouter(ref);
});

class SpiceOSApp extends ConsumerWidget {
  const SpiceOSApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'SpiceOS',
      theme: AppTheme.lightTheme,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
