import "package:flutter/material.dart";

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final Color? confirmColor;
  final IconData? icon;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = "Confirm",
    this.cancelText = "Cancel",
    this.confirmColor,
    this.icon,
  });

  /// Show the dialog and return true if confirmed
  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = "Confirm",
    String cancelText = "Cancel",
    Color? confirmColor,
    IconData? icon,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        confirmColor: confirmColor,
        icon: icon,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveColor = confirmColor ?? colorScheme.error;

    return AlertDialog(
      title: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, color: effectiveColor, size: 24),
            const SizedBox(width: 12),
          ],
          Expanded(child: Text(title, style: theme.textTheme.headlineSmall)),
        ],
      ),
      content: Text(message, style: theme.textTheme.bodyMedium),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelText),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: effectiveColor,
            foregroundColor: Colors.white,
          ),
          child: Text(confirmText),
        ),
      ],
    );
  }
}
