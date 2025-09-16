import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; // ✅ pour .tr()
import '../../models/hotel_details.dart';
import '../section_header.dart';
import '../base_card.dart';

class HotelContactCard extends StatelessWidget {
  final HotelDetail hotel;

  const HotelContactCard({super.key, required this.hotel});

  @override
  Widget build(BuildContext context) {
    final contactItems = _buildContactItems();

    if (contactItems.isEmpty) return const SizedBox.shrink();

    return BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            icon: Icons.contact_phone,
            title: 'hotel.contact.title'.tr(),
            iconColor: Colors.teal[600]!,
          ),
          const SizedBox(height: 16),
          ...contactItems.map((item) => _buildContactItem(item)).toList(),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _buildContactItems() {
    final items = <Map<String, dynamic>>[];

    if (hotel.phone.isNotEmpty) {
      items.add({
        'icon': Icons.phone,
        'label': 'hotel.contact.phone'.tr(),
        'value': hotel.phone,
        'color': Colors.green,
      });
    }

    if (hotel.email.isNotEmpty) {
      items.add({
        'icon': Icons.email,
        'label': 'hotel.contact.email'.tr(),
        'value': hotel.email,
        'color': Colors.orange,
      });
    }

    if (hotel.website.isNotEmpty) {
      items.add({
        'icon': Icons.web,
        'label': 'hotel.contact.website'.tr(),
        'value': hotel.website,
        'color': Colors.blue,
      });
    }

    return items;
  }

  Widget _buildContactItem(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (item['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              item['icon'] as IconData,
              size: 20,
              color: item['color'] as Color,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['label'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item['value'] as String,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: (item['label'] == 'hotel.contact.website'.tr())
                        ? Colors.blue[700]
                        : Colors.grey[800],
                    decoration: (item['label'] == 'hotel.contact.website'.tr())
                        ? TextDecoration.underline
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
