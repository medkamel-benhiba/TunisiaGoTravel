import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
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
    final htmlContent = widget.description;

    final displayContent = _isExpanded
        ? htmlContent
        : _truncateHtml(htmlContent, 200); // Limite à 200 caractères (approximatif)

    return BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            icon: Icons.description,
            title: 'about'.tr(),
            iconColor: Colors.green,
          ),
          const SizedBox(height: 16),
          Html(
            data: displayContent,
            style: {
              "body": Style(
                margin: Margins.zero,
                fontSize: FontSize(16),
                lineHeight: const LineHeight(1.5),
                color: Colors.black87,
              ),
            },
          ),
          if (htmlContent.length > 200)
            GestureDetector(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _isExpanded ? 'see_less'.tr() : 'see_more'.tr(),
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

  // Fonction simple pour tronquer le HTML sans casser les balises
  String _truncateHtml(String html, int limit) {
    if (html.length <= limit) return html;
    return html.substring(0, limit) + '...';
  }
}
