import 'package:flutter/material.dart';
import '../../models/restaurant.dart';
import '../base_card.dart';
import '../section_header.dart';

class RestaurantContactCard extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantContactCard({super.key, required this.restaurant});

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
            title: 'Contact',
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

    if (restaurant.phone != null && restaurant.phone!.isNotEmpty) {
      items.add({'icon': Icons.phone, 'label': 'Téléphone', 'value': restaurant.phone, 'color': Colors.green});
    }
    if (restaurant.email != null && restaurant.email!.isNotEmpty) {
      items.add({'icon': Icons.email, 'label': 'Email', 'value': restaurant.email, 'color': Colors.orange});
    }
    if (restaurant.website != null && restaurant.website!.isNotEmpty) {
      items.add({'icon': Icons.web, 'label': 'Site Web', 'value': restaurant.website, 'color': Colors.blue});
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
                    color: item['label'] == 'Site Web' ? Colors.blue[700] : Colors.grey[800],
                    decoration: item['label'] == 'Site Web' ? TextDecoration.underline : null,
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
