import 'package:flutter/material.dart';
import '../screens/chat_dialog.dart';

/// A reusable button widget for opening the chatbot dialog
///
/// This widget follows OOP principles by:
/// - Encapsulating chatbot button UI logic
/// - Providing a clean, reusable interface
/// - Separating concerns from parent widgets
class ChatBotButton extends StatelessWidget {
  /// The size of the button
  final double? size;

  /// Whether to show as a floating action button style
  final bool isFloating;

  /// Custom icon to display
  final IconData? icon;

  /// Custom background color
  final Color? backgroundColor;

  /// Custom foreground color
  final Color? foregroundColor;

  /// Tooltip text
  final String? tooltip;

  const ChatBotButton({
    super.key,
    this.size,
    this.isFloating = false,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
    this.tooltip,
  });

  /// Creates a floating action button style chatbot button
  factory ChatBotButton.floating({
    Key? key,
    double? size,
    Color? backgroundColor,
    Color? foregroundColor,
    String? tooltip,
  }) {
    return ChatBotButton(
      key: key,
      isFloating: true,
      size: size,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      tooltip: tooltip,
    );
  }

  /// Creates a regular icon button style chatbot button
  factory ChatBotButton.icon({
    Key? key,
    double? size,
    IconData? icon,
    Color? backgroundColor,
    Color? foregroundColor,
    String? tooltip,
  }) {
    return ChatBotButton(
      key: key,
      isFloating: false,
      size: size,
      icon: icon,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      tooltip: tooltip,
    );
  }

  /// Opens the chatbot dialog/bottom sheet
  void _openChatBot(BuildContext context) {
    if (isFloating) {
      // Use bottom sheet for floating button
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const ChatDialog(isBottomSheet: true),
      );
    } else {
      // Use dialog for icon button
      showDialog(
        context: context,
        builder: (context) => const ChatDialog(isBottomSheet: false),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultSize = size ?? (isFloating ? 56.0 : 40.0);
    final defaultIcon = icon ?? Icons.chat_bubble_outline;
    final defaultBackgroundColor = backgroundColor ?? theme.colorScheme.primary;
    final defaultForegroundColor = foregroundColor ?? Colors.white;
    final defaultTooltip = tooltip ?? 'Sohbet Botu';

    if (isFloating) {
      return FloatingActionButton(
        onPressed: () => _openChatBot(context),
        backgroundColor: defaultBackgroundColor,
        tooltip: defaultTooltip,
        child: Icon(
          defaultIcon,
          color: defaultForegroundColor,
          size: defaultSize * 0.5,
        ),
      );
    }

    return Tooltip(
      message: defaultTooltip,
      child: Container(
        width: defaultSize,
        height: defaultSize,
        decoration: BoxDecoration(
          color: defaultBackgroundColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: defaultBackgroundColor.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _openChatBot(context),
            borderRadius: BorderRadius.circular(defaultSize / 2),
            child: Icon(
              defaultIcon,
              color: defaultForegroundColor,
              size: defaultSize * 0.5,
            ),
          ),
        ),
      ),
    );
  }
}
