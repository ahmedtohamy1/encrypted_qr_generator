import 'package:flutter/material.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final IconData? icon;
  final VoidCallback? onActionPressed;
  final IconData? actionIcon;
  final String? actionTooltip;

  const SectionTitle({
    super.key,
    required this.title,
    this.icon,
    this.onActionPressed,
    this.actionIcon,
    this.actionTooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 20,
              color: theme.colorScheme.primary.withOpacity(0.8),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
                letterSpacing: 0.2,
              ),
            ),
          ),
          if (onActionPressed != null && actionIcon != null)
            Tooltip(
              message: actionTooltip ?? 'Action',
              child: IconButton(
                icon: Icon(actionIcon),
                onPressed: onActionPressed,
                iconSize: 20,
                color: theme.colorScheme.primary,
                splashRadius: 24,
              ),
            ),
        ],
      ),
    );
  }
}
