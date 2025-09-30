import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
    final screenWidth = MediaQuery.of(context).size.width;
    final cardHeight = screenWidth < 600 ? 120.0 : 240.0;

    return GestureDetector(
      onTap: () => _handleCardTap(context),
      child: Container(
        height: cardHeight,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(screenWidth < 600 ? 12 : 16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: screenWidth < 600 ? 6 : 10,
              offset: Offset(0, screenWidth < 600 ? 2 : 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Image cover
            ClipRRect(
              borderRadius: BorderRadius.circular(screenWidth < 600 ? 12 : 16),
              child: response.cover.isNotEmpty
                  ? CachedNetworkImage(
                imageUrl: response.cover,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColorstatic.primary,
                      ),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: Icon(
                    _getIconForType(response.type),
                    size: screenWidth < 600 ? 30 : 40,
                    color: Colors.grey[400],
                  ),
                ),
              )
                  : Container(
                color: Colors.grey[200],
                child: Icon(
                  _getIconForType(response.type),
                  size: screenWidth < 600 ? 30 : 40,
                  color: Colors.grey[400],
                ),
              ),
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(screenWidth < 600 ? 12 : 16),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),
            // Content
            Positioned(
              left: screenWidth < 600 ? 12 : 16,
              bottom: screenWidth < 600 ? 12 : 16,
              right: screenWidth < 600 ? 12 : 16,
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
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth < 600 ? 10 : 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Title
                  Text(
                    response.title,
                    style: TextStyle(
                      fontSize: screenWidth < 600 ? 14 : 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (response.type.toLowerCase() == 'hotel' &&
                      response.categoryCode != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Row(
                        children: List.generate(
                          int.tryParse(response.categoryCode!) ?? 0,
                              (index) => Icon(
                            Icons.star,
                            size: screenWidth < 600 ? 14 : 16,
                            color: Colors.yellow[700],
                          ),
                        ),
                      ),
                    ),
                  // Action button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColorstatic.secondary.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Voir détails',
                          style: TextStyle(
                            fontSize: screenWidth < 600 ? 10 : 12,
                            color: AppColorstatic.lightTextColor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
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
      final List<dynamic> allDestinations = response.circuit?['alldestination'] ?? [];
      final Map<String, dynamic> formattedCircuitData = {};
      for (int i = 0; i < allDestinations.length; i++) {
        formattedCircuitData['Jour ${i + 1}'] = allDestinations[i];
      }

      if (formattedCircuitData.isNotEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AutoCircuitDayScreen(
              listparjours: formattedCircuitData,
            ),
          ),
        );
      } else {
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
      case 'musee':
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
      case 'musee':
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
      case 'musee':
        return 'MUSÉE';
      default:
        return type.toUpperCase();
    }
  }
}