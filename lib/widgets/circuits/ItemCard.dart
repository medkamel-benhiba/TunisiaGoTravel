import 'package:flutter/material.dart';
import '../../theme/color.dart';
import 'ItemDetails.dart';

class ItemCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final Color categoryColor;
  const ItemCard({super.key, required this.item, required this.categoryColor});

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
        title: Text(item['Name'] ?? item['name'] ?? item['title'] ?? 'Nom introuvable'),
        subtitle: item['Description'] != null
            ? Text(item['Description'],
            maxLines: 2, overflow: TextOverflow.ellipsis)
            : null,
        children: [ItemDetail(item: item)],
      ),
    );
  }
}
