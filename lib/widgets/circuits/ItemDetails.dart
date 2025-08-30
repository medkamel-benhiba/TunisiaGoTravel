import 'package:flutter/material.dart';

class ItemDetail extends StatelessWidget {
  final Map<String, dynamic> item;
  const ItemDetail({super.key, required this.item});

  Widget _buildInfoRow(String title, String content, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF6B7280)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(content, style: const TextStyle(color: Color(0xFF6B7280))),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildGallery(List<dynamic> images) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          final imgUrl = images[index];
          return Container(
            margin: const EdgeInsets.only(right: 12),
            width: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade200,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imgUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic>? gallery = item['images'] ?? item['gallery'];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item['Description'] != null)
            _buildInfoRow("Description", item['Description'], Icons.description),
          if (item['Situation'] != null)
            _buildInfoRow("Situation", item['Situation'], Icons.location_on),
          if (item['Horaires_d_ouverture'] != null)
            _buildInfoRow(
                "Horaires",
                (item['Horaires_d_ouverture'] as List).join(', '),
                Icons.access_time),
          if (item['Droits_d_entre'] != null)
            _buildInfoRow("Tarif", item['Droits_d_entre'], Icons.payments),

          const SizedBox(height: 12),

          if (gallery != null && gallery.isNotEmpty) ...[
            const Text("Galerie",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            _buildGallery(gallery),
          ],
        ],
      ),
    );
  }
}
