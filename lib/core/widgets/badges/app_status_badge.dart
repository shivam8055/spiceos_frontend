import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_text_styles.dart';

enum AppStatus {
  pending,
  cooking,
  ready,
  delivered,
  completed,
  cancelled,
}

class AppStatusBadge extends StatelessWidget {
  final AppStatus status;

  const AppStatusBadge({
    super.key,
    required this.status,
  });

  Color get _background {
    switch (status) {
      case AppStatus.pending:
        return AppColors.warning;

      case AppStatus.cooking:
        return AppColors.info;

      case AppStatus.ready:
        return AppColors.success;

      case AppStatus.delivered:
        return AppColors.primary;

      case AppStatus.completed:
        return AppColors.success;

      case AppStatus.cancelled:
        return AppColors.error;
    }
  }

  String get _label {
    switch (status) {
      case AppStatus.pending:
        return 'Pending';
      case AppStatus.cooking:
        return 'Cooking';
      case AppStatus.ready:
        return 'Ready';
      case AppStatus.delivered:
        return 'Delivered';
      case AppStatus.completed:
        return 'Completed';
      case AppStatus.cancelled:
        return 'Cancelled';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: _background,
        borderRadius: AppRadius.pill,
      ),
      child: Text(
        _label,
        style: AppTextStyles.caption.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}