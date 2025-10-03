import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../models/hotel_details.dart';
import '../../theme/color.dart';

class HotelBioCard extends StatelessWidget {
  final Bio bio;
  final Locale locale;

  const HotelBioCard({super.key, required this.bio, required this.locale});

  @override
  Widget build(BuildContext context) {
    // Make the card width responsive based on screen size
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth > 600 ? screenWidth * 0.3 : screenWidth * 0.7;
    final padding = screenWidth > 600 ? 20.0 : 16.0;

    return FadeInUp(
      duration: const Duration(milliseconds: 400),
      child: GestureDetector(

        child: Card(
          elevation: 3,
          shadowColor: Colors.black.withOpacity(0.1),
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: AppColorstatic.primary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Container(
            width: cardWidth.clamp(220.0, 300.0),
            constraints: const BoxConstraints(minHeight: 180),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white,
                  AppColorstatic.primary.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: EdgeInsets.all(padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Animated icon container
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColorstatic.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getIcon(bio.icon),
                        color: AppColorstatic.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        bio.getName(locale),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColorstatic.mainColor,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  bio.getDescription(locale),
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColorstatic.darker.withOpacity(0.8),
                    height: 1.4,
                  ),
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIcon(String iconName) {
    switch (iconName) {
      case 'fa-user-slash':
        return Icons.person_off;
      case 'fa-water':
        return Icons.waves;
      case 'fa-ban':
        return Icons.block;
      case 'fa-wifi':
        return Icons.wifi;
      case 'fa-parking':
        return Icons.local_parking;
      case 'fa-paw':
        return Icons.pets;
      default:
        return Icons.info_outlined;
    }
  }
}