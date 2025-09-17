import 'package:flutter/material.dart';
import 'package:tunisiagotravel/widgets/circuits/ItemDetails.dart';
import '../../theme/color.dart';

class ItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final Color categoryColor;
  final DateTime? startDate;
  final int dayIndex;

  const ItemCard({
    super.key,
    required this.item,
    required this.categoryColor,
    this.startDate,
    this.dayIndex = 0,
  });

  Widget _buildItemImage() {
    return Container(
      width: 60,
      height: 60,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: item['vignette'] != null
            ? Image.network(item['vignette'], fit: BoxFit.cover)
            : Container(
          color: categoryColor.withOpacity(0.2),
          child: const Icon(Icons.image, color: Colors.white),
        ),
      ),
    );
  }

  String _getLocalizedTitle(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;

    // Debug: print all keys and their values
    print('--- Item Keys & Values ---');
    item.forEach((k, v) => print('$k: $v'));
    print('--------------------------');

    // Define possible key mappings per language
    final Map<String, List<String>> keysByLocale = {
      'ar': ['Name_ar', 'name_ar', 'title_ar'],
      'en': ['Name_en', 'name_en', 'title_en'],
      'ru': ['Name_ru', 'name_ru', 'title_ru'],
      'ja': ['Name_ja', 'name_ja', 'title_ja'],
      'ko': ['Name_ko', 'name_ko', 'title_ko'],
      'zh': ['Name_zh', 'name_zh', 'title_zh'],
      'fr': ['Name', 'name', 'title'],
    };

    final keys = keysByLocale[locale] ?? ['Name', 'name', 'title'];

    for (final key in keys) {
      if (item[key] != null && item[key].toString().trim().isNotEmpty) {
        print('Using key: $key -> ${item[key]}'); // Debug which key was used
        return item[key];
      }
    }

    // Fallback text
    switch (locale) {
      case 'ar':
        return 'الاسم غير متوفر';
      case 'en':
        return 'Name not available';
      case 'ru':
        return 'Имя не найдено';
      case 'ja':
        return '名前はありません';
      case 'ko':
        return '이름이 없습니다';
      case 'zh':
        return '名称不可用';
      default:
        return 'Nom introuvable';
    }
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColorstatic.white80,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ExpansionTile(
        leading: _buildItemImage(),
        title: Text(_getLocalizedTitle(context)),
        children: [
          ItemDetail(
            item: item,
            startDate: startDate,
            dayIndex: dayIndex,
          ),
        ],
      ),
    );
  }
}
