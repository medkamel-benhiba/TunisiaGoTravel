import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../models/maisondHote.dart';
import '../base_card.dart';
import '../section_header.dart';

class MaisonContactCard extends StatelessWidget {
  final MaisonDHote maison;

  const MaisonContactCard({super.key, required this.maison});

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
            title: 'contact'.tr(),
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

    if (maison.phone.isNotEmpty) {
      items.add({'icon': Icons.phone, 'label': 'phone'.tr(), 'value': maison.phone, 'color': Colors.green});
    }
    if (maison.email.isNotEmpty) {
      items.add({'icon': Icons.email, 'label': 'email'.tr(), 'value': maison.email, 'color': Colors.orange});
    }
    if (maison.website.isNotEmpty) {
      items.add({'icon': Icons.web, 'label': 'website'.tr(), 'value': maison.website, 'color': Colors.blue});
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
            child: Icon(item['icon'] as IconData, size: 20, color: item['color'] as Color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['label'] as String,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey[500]),
                ),
                const SizedBox(height: 2),
                Text(
                  item['value'] as String,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: item['label'] == 'website'.tr() ? Colors.blue[700] : Colors.grey[800],
                    decoration: item['label'] == 'website'.tr() ? TextDecoration.underline : null,
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
