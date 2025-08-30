import 'package:flutter/material.dart';
import '../base_card.dart';
import '../section_header.dart';

class DescriptionCard extends StatefulWidget {
  final String description;

  const DescriptionCard({super.key, required this.description});

  @override
  State<DescriptionCard> createState() => _DescriptionCardState();
}

class _DescriptionCardState extends State<DescriptionCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final text = widget.description;

    return BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            icon: Icons.description,
            title: 'Description',
            iconColor: Colors.green,
          ),
          const SizedBox(height: 16),
          Text(
            text,
            maxLines: _isExpanded ? null : 4,
            overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 16, height: 1.5),
          ),
          if (text.length > 100)
            GestureDetector(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _isExpanded ? 'Voir moins' : 'Voir plus',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
