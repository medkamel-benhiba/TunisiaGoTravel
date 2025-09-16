import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tunisiagotravel/theme/color.dart';

class LanguageSelector extends StatelessWidget {
  final bool showInTopMenu;

  const LanguageSelector({Key? key, this.showInTopMenu = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (showInTopMenu) {
      return _buildTopMenuLanguageSelector(context);
    }
    return _buildPopupLanguageSelector(context);
  }

  Widget _buildTopMenuLanguageSelector(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: AppColorstatic.secondary,
        borderRadius: BorderRadius.circular(6),
      ),
      child: PopupMenuButton<Locale>(
        icon: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.language, color: Colors.white, size: 20),
            const SizedBox(width: 4),
            Text(
              context.locale.languageCode.toUpperCase(),
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        color: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onSelected: (Locale locale) {
          context.setLocale(locale);
        },
        itemBuilder: (BuildContext context) {
          return context.supportedLocales.map((locale) {
            final isSelected = context.locale == locale;
            return PopupMenuItem<Locale>(
              value: locale,
              child: Row(
                children: [
                  Text(_getLanguageFlag(locale.languageCode)),
                  const SizedBox(width: 8),
                  Text(_getLanguageName(locale.languageCode)),
                  if (isSelected) ...[
                    const Spacer(),
                    Icon(Icons.check, color: AppColorstatic.primary, size: 20),
                  ],
                ],
              ),
            );
          }).toList();
        },
      ),
    );
  }

  Widget _buildPopupLanguageSelector(BuildContext context) {
    return PopupMenuButton<Locale>(
      icon: const Icon(Icons.language),
      tooltip: 'language'.tr(),
      color: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onSelected: (Locale locale) {
        context.setLocale(locale);
      },
      itemBuilder: (BuildContext context) {
        return context.supportedLocales.map((locale) {
          final isSelected = context.locale == locale;
          return PopupMenuItem<Locale>(
            value: locale,
            child: Row(
              children: [
                Text(_getLanguageFlag(locale.languageCode)),
                const SizedBox(width: 8),
                Text(_getLanguageName(locale.languageCode)),
                if (isSelected) ...[
                  const Spacer(),
                  Icon(Icons.check, color: AppColorstatic.primary, size: 20),
                ],
              ],
            ),
          );
        }).toList();
      },
    );
  }

  String _getLanguageFlag(String languageCode) {
    switch (languageCode) {
      case 'en':
        return '🇺🇸';
      case 'fr':
        return '🇫🇷';
      case 'ar':
        return '🇹🇳';
      case 'ru':
        return '🇷🇺';
      case 'ja':
        return '🇯🇵';
      case 'zh':
        return '🇨🇳';
      case 'ko':
        return '🇰🇷';

      default:
        return '🌍';
    }
  }

  String _getLanguageName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'fr':
        return 'Français';
      case 'ar':
        return 'العربية';
      case 'ru':
        return 'Русский';
      case 'ja':
        return '日本語';
      case 'zh':
        return '中文';
      case 'ko':
        return '한국어';
      default:
        return 'Unknown';
    }
  }
}