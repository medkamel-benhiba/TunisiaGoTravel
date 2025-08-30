import 'package:flutter/material.dart';
import '../../theme/color.dart';
import 'SectionWidget.dart';

class DayCard extends StatefulWidget {
  final String dayKey;
  final Map<String, dynamic> dayData;
  const DayCard({super.key, required this.dayKey, required this.dayData});

  @override
  State<DayCard> createState() => _DayCardState();
}

class _DayCardState extends State<DayCard> {
  bool isExpanded = false;

  // Convertit un objet ou null en liste
  List safeList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value;
    if (value is Map) return [value];
    return [];
  }

  int _calculateTotalActivities() {
    int total = 0;
    total += safeList(widget.dayData['hotel']).length;
    total += safeList(widget.dayData['Restaurant']).length;
    total += safeList(widget.dayData['Activity']).length;
    total += safeList(widget.dayData['musees']).length;
    total += safeList(widget.dayData['monuments']).length;
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final totalActivities = _calculateTotalActivities();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColorstatic.white80,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        initiallyExpanded: isExpanded,
        onExpansionChanged: (expanded) {
          setState(() => isExpanded = expanded);
        },
        tilePadding: const EdgeInsets.all(20),
        title: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColorstatic.secondary,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: Text(
                  widget.dayKey,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jour ${widget.dayKey}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  Text(
                    '$totalActivities activité${totalActivities > 1 ? 's' : ''} planifiée${totalActivities > 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        children: [
          Column(
            children: [
              SectionWidget(title: 'Hôtels', items: safeList(widget.dayData['hotel'])),
              SectionWidget(title: 'Restaurants', items: safeList(widget.dayData['Restaurant'])),
              SectionWidget(title: 'Activités', items: safeList(widget.dayData['Activity'])),
              SectionWidget(title: 'Musées', items: safeList(widget.dayData['musees'])),
              SectionWidget(title: 'Monuments', items: safeList(widget.dayData['monuments'])),
              const SizedBox(height: 16),
            ],
          ),
        ],
      ),
    );
  }
}
