import 'package:flutter/material.dart';

enum AppButtonStyle { primary, secondary, outlined, ghost }

class AppButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final AppButtonStyle style;
  final bool isLoading;
  final double? width;
  final double? height;

  const AppButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.style = AppButtonStyle.primary,
    this.isLoading = false,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Define style properties based on the button style
    Color backgroundColor;
    Color textColor;
    Color? overlayColor;
    BoxBorder? border;
    double elevation;

    switch (style) {
      case AppButtonStyle.primary:
        backgroundColor = theme.colorScheme.primary;
        textColor = theme.colorScheme.onPrimary;
        overlayColor = theme.colorScheme.onPrimary.withOpacity(0.1);
        border = null;
        elevation = 2;
        break;
      case AppButtonStyle.secondary:
        backgroundColor = theme.colorScheme.secondary;
        textColor = theme.colorScheme.onSecondary;
        overlayColor = theme.colorScheme.onSecondary.withOpacity(0.1);
        border = null;
        elevation = 2;
        break;
      case AppButtonStyle.outlined:
        backgroundColor = Colors.transparent;
        textColor = theme.colorScheme.primary;
        overlayColor = theme.colorScheme.primary.withOpacity(0.1);
        border = Border.all(color: theme.colorScheme.primary, width: 1.5);
        elevation = 0;
        break;
      case AppButtonStyle.ghost:
        backgroundColor = Colors.transparent;
        textColor = theme.colorScheme.primary;
        overlayColor = theme.colorScheme.primary.withOpacity(0.05);
        border = null;
        elevation = 0;
        break;
    }

    // Common button shape
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    );

    // Button content
    Widget buttonContent = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(textColor),
            ),
          )
        else if (icon != null) ...[
          Icon(icon, color: textColor),
          const SizedBox(width: 8),
        ],
        if (!isLoading)
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
      ],
    );

    // Container to provide consistent sizing
    return SizedBox(
      width: width,
      height: height ?? 48,
      child:
          style == AppButtonStyle.outlined || style == AppButtonStyle.ghost
              ? OutlinedButton(
                onPressed: isLoading ? null : onPressed,
                style: OutlinedButton.styleFrom(
                  foregroundColor: textColor,
                  backgroundColor: backgroundColor,
                  side: border != null ? BorderSide(color: textColor) : null,
                  shape: shape,
                  elevation: elevation,
                ),
                child: buttonContent,
              )
              : ElevatedButton(
                onPressed: isLoading ? null : onPressed,
                style: ElevatedButton.styleFrom(
                  foregroundColor: textColor,
                  backgroundColor: backgroundColor,
                  shape: shape,
                  elevation: elevation,
                ),
                child: buttonContent,
              ),
    );
  }
}
