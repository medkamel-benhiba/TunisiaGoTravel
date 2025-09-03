import 'package:flutter/material.dart';
import '../models/chatbot_response.dart';
import '../screens/autoCircuits_details.dart';
import '../services/ChatbotNavigationHelper.dart';
import '../theme/color.dart';

class ChatbotResponseCard extends StatelessWidget {
  final ChatbotResponse response;
  final VoidCallback? onTap;

  const ChatbotResponseCard({
    Key? key,
    required this.response,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleCardTap(context),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image cover
              Container(
                height: 120,
                width: double.infinity,
                child: response.cover.isNotEmpty
                    ? Image.network(
                  response.cover,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: Icon(
                        _getIconForType(response.type),
                        size: 40,
                        color: Colors.grey[600],
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey[300],
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColorstatic.primary,
                          ),
                        ),
                      ),
                    );
                  },
                )
                    : Container(
                  color: Colors.grey[300],
                  child: Icon(
                    _getIconForType(response.type),
                    size: 40,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              // Content
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Type badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getColorForType(response.type),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getDisplayType(response.type),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Title
                    Text(
                      response.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (response.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        response.description!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 8),
                    // Action button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Voir détails',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColorstatic.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: AppColorstatic.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleCardTap(BuildContext context) {
    if (onTap != null) {
      onTap!();
      return;
    }

    if (response.type.toLowerCase() == 'circuit') {
      // Extract the list of destinations
      final List<dynamic> allDestinations = response.circuit?['alldestination'] ?? [];

      // Create a new map to match the expected format of CircuitDayScreen
      final Map<String, dynamic> formattedCircuitData = {};
      for (int i = 0; i < allDestinations.length; i++) {
        formattedCircuitData['Jour ${i + 1}'] = allDestinations[i];
      }

      // Check if the formatted data is not empty
      if (formattedCircuitData.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CircuitDayScreen(
              listparjours: formattedCircuitData,
            ),
          ),
        );
      } else {
        // Handle the case where the data is empty or malformed
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Aucun circuit trouvé pour cette requête.'),
          ),
        );
      }
      return;
    }

    ChatbotNavigationHelper.navigateToDetails(context, response);
  }



  IconData _getIconForType(String type) {
    switch (type.toLowerCase()) {
      case 'hotel':
        return Icons.hotel;
      case 'restaurant':
        return Icons.restaurant;
      case 'activity':
        return Icons.local_activity;
      case 'event':
        return Icons.event;
      case 'circuit':
        return Icons.route;
      case 'culture':
        return Icons.museum;
      default:
        return Icons.info;
    }
  }

  Color _getColorForType(String type) {
    switch (type.toLowerCase()) {
      case 'hotel':
        return AppColorstatic.secondary;
      case 'restaurant':
        return AppColorstatic.primary2;
      case 'activity':
        return AppColorstatic.secondary;
      case 'event':
        return AppColorstatic.primary2;
      case 'circuit':
        return AppColorstatic.primary;
      case 'culture':
        return AppColorstatic.primary;
      default:
        return Colors.grey;
    }
  }

  String _getDisplayType(String type) {
    switch (type.toLowerCase()) {
      case 'hotel':
        return 'HÔTEL';
      case 'restaurant':
        return 'RESTAURANT';
      case 'activity':
        return 'ACTIVITÉ';
      case 'event':
        return 'ÉVÉNEMENT';
      case 'circuit':
        return 'CIRCUIT';
      case 'culture':
        return 'CULTURE';
      default:
        return type.toUpperCase();
    }
  }
}