import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../services/language_service.dart';
import '../screens/language_selection_screen.dart';

class LanguageSelector extends StatelessWidget {
  final bool showAsDialog;
  final bool showFlag;
  final bool showDescription;

  const LanguageSelector({
    super.key,
    this.showAsDialog = false,
    this.showFlag = true,
    this.showDescription = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageService = Provider.of<LanguageService>(context);

    if (showAsDialog) {
      return _buildDialogButton(context, l10n, languageService);
    }

    return _buildListTile(context, l10n, languageService);
  }

  Widget _buildDialogButton(
    BuildContext context,
    AppLocalizations l10n,
    LanguageService languageService,
  ) {
    return ListTile(
      leading: const Icon(Icons.language),
      title: Text(l10n.language),
      subtitle: showDescription
          ? Text(languageService.currentLanguageName)
          : null,
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => const LanguageSelectionDialog(),
        );
      },
    );
  }

  Widget _buildListTile(
    BuildContext context,
    AppLocalizations l10n,
    LanguageService languageService,
  ) {
    return ListTile(
      leading: const Icon(Icons.language),
      title: Text(l10n.language),
      subtitle: Text(languageService.currentLanguageName),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const LanguageSelectionScreen(),
          ),
        );
      },
    );
  }
}

// Compact language selector for app bars
class CompactLanguageSelector extends StatelessWidget {
  const CompactLanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);

    return PopupMenuButton<String>(
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _getLanguageFlag(languageService.currentLanguageCode),
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_drop_down),
        ],
      ),
      onSelected: (String languageCode) {
        languageService.changeLanguage(languageCode);
      },
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          value: 'tr',
          child: Row(
            children: [
              Text('🇹🇷', style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              const Text('Türkçe'),
              if (languageService.isTurkish) ...[
                const Spacer(),
                Icon(
                  Icons.check,
                  color: Theme.of(context).primaryColor,
                  size: 16,
                ),
              ],
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'en',
          child: Row(
            children: [
              Text('🇺🇸', style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              const Text('English'),
              if (languageService.isEnglish) ...[
                const Spacer(),
                Icon(
                  Icons.check,
                  color: Theme.of(context).primaryColor,
                  size: 16,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _getLanguageFlag(String languageCode) {
    switch (languageCode) {
      case 'tr':
        return '🇹🇷';
      case 'en':
        return '🇺🇸';
      default:
        return '🌐';
    }
  }
}

// Language indicator widget
class LanguageIndicator extends StatelessWidget {
  const LanguageIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _getLanguageFlag(languageService.currentLanguageCode),
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(width: 4),
          Text(
            languageService.currentLanguageCode.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  String _getLanguageFlag(String languageCode) {
    switch (languageCode) {
      case 'tr':
        return '🇹🇷';
      case 'en':
        return '🇺🇸';
      default:
        return '🌐';
    }
  }
}
