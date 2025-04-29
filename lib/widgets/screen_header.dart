import 'package:flutter/material.dart';
import 'custom_card.dart';

class ScreenHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String cardTitle;
  final String cardSubtitle;
  final IconData cardIcon;
  final Color? cardColor;
  final VoidCallback? onCardButtonPressed;
  final bool isCardButtonLoading;

  const ScreenHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.cardTitle,
    required this.cardSubtitle,
    required this.cardIcon,
    this.cardColor,
    this.onCardButtonPressed,
    this.isCardButtonLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = cardColor ?? theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.fromLTRB(20.0, 24.0, 20.0, 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24.0),
          CustomCard(
            title: cardTitle,
            subtitle: cardSubtitle,
            icon: cardIcon,
            color: color,
            onTap: isCardButtonLoading ? null : onCardButtonPressed,
            isLoading: isCardButtonLoading,
          ),
        ],
      ),
    );
  }
}