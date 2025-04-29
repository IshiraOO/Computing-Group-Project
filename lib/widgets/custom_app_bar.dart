import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final Widget? leading;
  final double elevation;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final PreferredSizeWidget? bottom;
  final VoidCallback? onBackPressed;
  final bool useGradient;
  final List<Color>? gradientColors;
  final Widget? titleWidget;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = true,
    this.leading,
    this.elevation = 0,
    this.backgroundColor,
    this.foregroundColor,
    this.bottom,
    this.onBackPressed,
    this.useGradient = false,
    this.gradientColors,
    this.titleWidget,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      title: titleWidget ?? Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 18,
          letterSpacing: -0.5,
          color: theme.colorScheme.onSurface,
        ),
      ),
      centerTitle: true,
      elevation: elevation,
      backgroundColor: useGradient ? Colors.transparent : (backgroundColor ?? theme.colorScheme.surface),
      foregroundColor: foregroundColor ?? theme.colorScheme.onSurface,
      leading: showBackButton
          ? leading ?? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
            )
          : leading,
      actions: actions,
      bottom: bottom,
      flexibleSpace: useGradient ? Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors ?? [theme.colorScheme.primary, theme.colorScheme.primaryContainer],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ) : null,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(16),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(bottom == null ? kToolbarHeight : kToolbarHeight + bottom!.preferredSize.height);
}