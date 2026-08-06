import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_shadows.dart';

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppRadius.medium,
        boxShadow: AppShadows.small,
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: child,
    );

    if (onTap != null) {
      content = InkWell(
        borderRadius: AppRadius.medium,
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }
}