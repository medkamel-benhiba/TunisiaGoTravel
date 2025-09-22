import 'package:flutter/material.dart';
import '../../theme/color.dart';
import 'ItemCard.dart';

class SectionWidget extends StatelessWidget {
  final String title;
  final List items;
  const SectionWidget({super.key, required this.title, required this.items});

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
    // Hôtels
      case 'hôtels': // fr
      case 'hotels': // en
      case 'الفنادق': // ar
      case 'ホテル': // ja
      case '호텔': // ko
      case '酒店': // zh
      case 'отели': // ru
        return AppColorstatic.primary85;

    // Restaurants
      case 'restaurants': // fr / en
      case 'المطاعم': // ar
      case 'レストラン': // ja
      case '레스토랑': // ko
      case '餐厅': // zh
      case 'рестораны': // ru
        return AppColorstatic.primary2.withOpacity(0.6);

    // Activités
      case 'activités': // fr
      case 'activities': // en
      case 'الأنشطة': // ar
      case 'アクティビティ': // ja
      case '액티비티': // ko
      case '活动': // zh
      case 'мероприятия': // ru
        return AppColorstatic.secondary;

    // Musées
      case 'musées': // fr
      case 'museums': // en
      case 'المتاحف': // ar
      case '博物館': // ja / zh
      case '박물관': // ko
      case 'музеи': // ru
        return AppColorstatic.buttonbg;

    // Monuments
      case 'monuments':
      case 'المعالم':
      case '記念碑':
      case '기념물':
      case '纪念碑':
      case 'памятники':
        return AppColorstatic.appBgColor;

    // Default
      default:
        return AppColorstatic.primary;
    }
  }


  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'hôtels':
        return Icons.hotel;
      case 'restaurants':
        return Icons.restaurant;
      case 'activités':
        return Icons.local_activity;
      case 'musées':
        return Icons.museum;
      case 'monuments':
        return Icons.account_balance;
      default:
        return Icons.place;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox();

    final color = _getCategoryColor(title);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.8)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(_getCategoryIcon(title), color: Colors.white),
              const SizedBox(width: 12),
              Text(
                "$title (${items.length})",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),

        // Items
        ...items.map((item) => ItemCard(item: Map<String, dynamic>.from(item), categoryColor: color)),
      ],
    );
  }
}
