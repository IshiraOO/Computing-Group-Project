import 'package:flutter/material.dart';

enum ButtonType { primary, secondary, outline, text }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonType type;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final double borderRadius;
  final Color? backgroundColor;
  final Color? textColor;
  final bool isOutlined;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
    this.padding,
    this.width,
    this.height,
    this.borderRadius = 12,
    this.backgroundColor,
    this.textColor,
    this.isOutlined = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget button;
    switch (type) {
      case ButtonType.primary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? (theme.brightness == Brightness.dark
                    ? theme.colorScheme.primary.withOpacity(0.2)
                    : theme.colorScheme.primary),
            foregroundColor: textColor ?? theme.colorScheme.onPrimary,
            iconColor: textColor ?? theme.colorScheme.onPrimary,
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              side: isOutlined ? BorderSide(color: theme.colorScheme.primary.withOpacity(0.5), width: 1) : BorderSide.none,
            ),
            elevation: 2,
            disabledBackgroundColor: theme.colorScheme.primary.withOpacity(0.38),
            disabledForegroundColor: theme.colorScheme.onPrimary.withOpacity(0.38),
          ),
          child: _buildButtonContent(theme),
        );
        break;
      case ButtonType.secondary:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? (theme.brightness == Brightness.dark
                    ? theme.colorScheme.secondary.withOpacity(0.2)
                    : theme.colorScheme.secondary),
            foregroundColor: textColor ?? theme.colorScheme.onSecondary,
            iconColor: textColor ?? theme.colorScheme.onSecondary,
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              side: isOutlined ? BorderSide(color: theme.colorScheme.secondary.withOpacity(0.5), width: 1) : BorderSide.none,
            ),
            elevation: 2,
            disabledBackgroundColor: theme.colorScheme.secondary.withOpacity(0.38),
            disabledForegroundColor: theme.colorScheme.onSecondary.withOpacity(0.38),
          ),
          child: _buildButtonContent(theme),
        );
        break;
      case ButtonType.outline:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: isOutlined ? theme.colorScheme.primary : textColor ?? theme.colorScheme.primary,
            side: BorderSide(
              color: isOutlined ? theme.colorScheme.primary : backgroundColor ?? theme.colorScheme.primary,
              width: 1.5,
            ),
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            disabledForegroundColor: theme.colorScheme.primary.withOpacity(0.38),
          ),
          child: _buildButtonContent(theme),
        );
        break;
      case ButtonType.text:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: isOutlined ? theme.colorScheme.primary : textColor ?? theme.colorScheme.primary,
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            disabledForegroundColor: theme.colorScheme.primary.withOpacity(0.38),
          ),
          child: _buildButtonContent(theme),
        );
        break;
    }

    // Apply width constraints if specified
    if (fullWidth || width != null) {
      return SizedBox(
        width: fullWidth ? double.infinity : width,
        height: height,
        child: button,
      );
    }

    return button;
  }

  Widget _buildButtonContent(ThemeData theme) {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            type == ButtonType.text || type == ButtonType.outline
                ? theme.colorScheme.primary
                : theme.colorScheme.onPrimary,
          ),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: theme.textTheme.labelLarge?.copyWith(
              color: type == ButtonType.text || type == ButtonType.outline
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onPrimary,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: theme.textTheme.labelLarge?.copyWith(
        color: type == ButtonType.text || type == ButtonType.outline
            ? theme.colorScheme.primary
            : theme.colorScheme.onPrimary,
      ),
    );
  }
}