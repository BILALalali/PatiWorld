import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../services/language_service.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageService = Provider.of<LanguageService>(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.selectLanguage), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.selectLanguage,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _getLanguageDescription(languageService.currentLanguageCode),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            // Language options
            _buildLanguageOption(
              context: context,
              languageService: languageService,
              languageCode: 'tr',
              languageName: l10n.turkish,
              flag: '🇹🇷',
              isSelected: languageService.isTurkish,
            ),
            const SizedBox(height: 12),
            _buildLanguageOption(
              context: context,
              languageService: languageService,
              languageCode: 'en',
              languageName: l10n.english,
              flag: '🇺🇸',
              isSelected: languageService.isEnglish,
            ),

            const Spacer(),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  l10n.save,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required LanguageService languageService,
    required String languageCode,
    required String languageName,
    required String flag,
    required bool isSelected,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
        color: isSelected
            ? Theme.of(context).primaryColor.withOpacity(0.1)
            : Colors.transparent,
      ),
      child: ListTile(
        leading: Text(flag, style: const TextStyle(fontSize: 24)),
        title: Text(
          languageName,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Theme.of(context).primaryColor : null,
          ),
        ),
        subtitle: Text(
          _getLanguageDescription(languageCode),
          style: TextStyle(
            color: isSelected
                ? Theme.of(context).primaryColor.withOpacity(0.8)
                : Colors.grey[600],
          ),
        ),
        trailing: isSelected
            ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor)
            : const Icon(Icons.radio_button_unchecked),
        onTap: () {
          languageService.changeLanguage(languageCode);
        },
      ),
    );
  }

  String _getLanguageDescription(String languageCode) {
    switch (languageCode) {
      case 'tr':
        return 'Türkçe dil desteği';
      case 'en':
        return 'English language support';
      default:
        return '';
    }
  }
}

// Language selection dialog
class LanguageSelectionDialog extends StatelessWidget {
  const LanguageSelectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final languageService = Provider.of<LanguageService>(context);

    return AlertDialog(
      title: Text(l10n.selectLanguage),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLanguageTile(
            context: context,
            languageService: languageService,
            languageCode: 'tr',
            languageName: l10n.turkish,
            flag: '🇹🇷',
            isSelected: languageService.isTurkish,
          ),
          const SizedBox(height: 8),
          _buildLanguageTile(
            context: context,
            languageService: languageService,
            languageCode: 'en',
            languageName: l10n.english,
            flag: '🇺🇸',
            isSelected: languageService.isEnglish,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.ok),
        ),
      ],
    );
  }

  Widget _buildLanguageTile({
    required BuildContext context,
    required LanguageService languageService,
    required String languageCode,
    required String languageName,
    required String flag,
    required bool isSelected,
  }) {
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 20)),
      title: Text(languageName),
      trailing: isSelected
          ? Icon(Icons.check, color: Theme.of(context).primaryColor)
          : null,
      onTap: () {
        languageService.changeLanguage(languageCode);
        Navigator.of(context).pop();
      },
    );
  }
}
