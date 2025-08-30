import 'package:flutter/material.dart';
import '../../theme/color.dart';

class SearchCriteriaCard extends StatelessWidget {
  final Map<String, dynamic> searchCriteria;
  final String travelersSummary;

  const SearchCriteriaCard({
    super.key,
    required this.searchCriteria,
    required this.travelersSummary,
  });

  String _getRoomCountText() {
    // Try multiple ways to get the room count
    int roomCount = 0;

    // Method 1: Check if rooms is a List
    if (searchCriteria['rooms'] is List) {
      roomCount = (searchCriteria['rooms'] as List).length;
    }
    // Method 2: Check if roomsCount exists as string
    else if (searchCriteria['roomsCount'] != null) {
      roomCount = int.tryParse(searchCriteria['roomsCount'].toString()) ?? 0;
    }
    // Method 3: Check if rooms is a string number
    else if (searchCriteria['rooms'] is String) {
      roomCount = int.tryParse(searchCriteria['rooms'].toString()) ?? 0;
    }
    // Method 4: Default fallback
    else {
      roomCount = 1;
    }

    return "$roomCount chambre${roomCount > 1 ? 's' : ''}";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColorstatic.primary.withOpacity(0.1),
                  Colors.white,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColorstatic.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.search,
                    color: AppColorstatic.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Critères de recherche',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Détails de votre séjour',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content Section
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Dates
                _buildCriteriaItem(
                  Icons.calendar_month,
                  "Dates de séjour",
                  "${searchCriteria['dateStart']} - ${searchCriteria['dateEnd']}",
                  AppColorstatic.buttonbg.withOpacity(0.04),
                  AppColorstatic.primary,
                ),

                const SizedBox(height: 16),

                // Travelers and Rooms Row
                Row(
                  children: [
                    Expanded(
                      child: _buildCriteriaItem(
                        Icons.group,
                        "Voyageurs",
                        travelersSummary,
                        Colors.orange.withOpacity(0.1),
                        Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildCriteriaItem(
                        Icons.hotel,
                        "Chambres",
                        _getRoomCountText(),
                        Colors.teal.withOpacity(0.1),
                        Colors.teal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCriteriaItem(
      IconData icon,
      String title,
      String value,
      Color backgroundColor,
      Color iconColor,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: iconColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

/*import 'package:flutter/material.dart';
import '../../theme/color.dart';

class SearchSummary extends StatelessWidget {
  final Map<String, dynamic> searchCriteria;
  const SearchSummary({super.key, required this.searchCriteria});

  @override
  Widget build(BuildContext context) {
    final rooms = searchCriteria['rooms'] as List<Map<String, dynamic>>? ?? [];
    final totalAdults =
    rooms.fold<int>(0, (sum, room) => sum + (room['adults'] as int? ?? 0));
    final totalChildren =
    rooms.fold<int>(0, (sum, room) => sum + (room['children'] as int? ?? 0));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.search, color: AppColorstatic.primary, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Critères de recherche',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildCriteriaItem(
                      Icons.calendar_today,
                      'Dates',
                      '${searchCriteria['dateStart']} - ${searchCriteria['dateEnd']}'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildCriteriaItem(
                      Icons.group, 'Voyageurs', '$totalAdults adultes, $totalChildren enfants'),
                ),
                Expanded(
                  child: _buildCriteriaItem(
                      Icons.hotel, 'Chambres', '${rooms.length} chambre(s)'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCriteriaItem(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)),
              Text(value,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }
}*/