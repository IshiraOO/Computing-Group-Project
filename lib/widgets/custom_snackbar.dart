import 'package:flutter/material.dart';

enum SnackBarType {
  success,
  error,
  warning,
  info,
}

class CustomSnackBar extends SnackBar {
  CustomSnackBar({
    super.key,
    required String message,
    required SnackBarType type,
    required ThemeData theme,
    Duration? duration,
    VoidCallback? onPressed,
    String? actionLabel,
    bool showIcon = true,
    required BuildContext context,
  }) : super(
          content: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border(
                left: BorderSide(
                  color: _getAccentColor(type, theme),
                  width: 4,
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                if (showIcon) ...[
                  Icon(
                    _getIcon(type),
                    color: _getAccentColor(type, theme),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.3,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: Colors.transparent,
          duration: duration ?? const Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          action: actionLabel != null && onPressed != null
              ? SnackBarAction(
                  label: actionLabel,
                  textColor: _getAccentColor(type, theme),
                  onPressed: onPressed,
                )
              : null,
        );

  static IconData _getIcon(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return Icons.check_circle_outline;
      case SnackBarType.error:
        return Icons.error_outline;
      case SnackBarType.warning:
        return Icons.warning_amber_outlined;
      case SnackBarType.info:
        return Icons.info_outline;
    }
  }

  static Color _getAccentColor(SnackBarType type, ThemeData theme) {
    switch (type) {
      case SnackBarType.success:
        return theme.colorScheme.tertiary;
      case SnackBarType.error:
        return theme.colorScheme.error;
      case SnackBarType.warning:
        return theme.colorScheme.tertiary;
      case SnackBarType.info:
        return theme.colorScheme.primary;
    }
  }

  static void show({
    required BuildContext context,
    required String message,
    required SnackBarType type,
    Duration? duration,
    VoidCallback? onPressed,
    String? actionLabel,
    bool showIcon = true,
  }) {
    final theme = Theme.of(context);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      CustomSnackBar(
        message: message,
        type: type,
        theme: theme,
        duration: duration,
        onPressed: onPressed,
        actionLabel: actionLabel,
        showIcon: showIcon,
        context: context,
      ),
    );
  }
}