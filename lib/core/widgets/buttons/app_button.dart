import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_text_styles.dart';

enum AppButtonType {
  primary,
  secondary,
  destructive,
}

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final bool loading;
  final bool fullWidth;
  final IconData? icon;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = AppButtonType.primary,
    this.loading = false,
    this.fullWidth = true,
    this.icon,
  });

  Color get _backgroundColor {
    switch (type) {
      case AppButtonType.primary:
        return AppColors.primary;

      case AppButtonType.secondary:
        return AppColors.neutral200;

      case AppButtonType.destructive:
        return AppColors.error;
    }
  }

  Color get _foregroundColor {
    switch (type) {
      case AppButtonType.secondary:
        return AppColors.textPrimary;

      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton(
      onPressed: loading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: _backgroundColor,
        foregroundColor: _foregroundColor,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.medium,
        ),
      ),
      child: loading
          ? const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      )
          : Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 18),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: AppTextStyles.button.copyWith(
              color: _foregroundColor,
            ),
          ),
        ],
      ),
    );

    if (fullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }
}