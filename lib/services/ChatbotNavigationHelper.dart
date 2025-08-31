// services/ChatbotNavigationHelper.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Providers
import '../providers/hotel_provider.dart';
import '../providers/maisondhote_provider.dart';
import '../providers/restaurant_provider.dart';
import '../providers/musee_provider.dart';
import '../providers/event_provider.dart';

// Models
import '../models/chatbot_response.dart';

// Screens
import '../screens/hotel_details_screen.dart';
import '../screens/maisonDhote_details_screen.dart';
import '../screens/restaurant_details_screen.dart';
import '../screens/musee_details_screen.dart';
import '../screens/event_details_screen.dart';

class ChatbotNavigationHelper {
  static Future<void> navigateToDetails(
      BuildContext context, ChatbotResponse response) async {
    switch (response.type.toLowerCase()) {
      case 'hotel':
        await _navigateToHotelDetails(context, response);
        break;

      case 'restaurant':
        await _navigateToRestaurantDetails(context, response);
        break;

      case 'culture': // musée
        await _navigateToMuseeDetails(context, response);
        break;

      case 'maison':
        await _navigateToMaisonDetails(context, response);
        break;

      case 'event':
        await _navigateToEventDetails(context, response);
        break;

      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Type ${response.type} non encore supporté'),
            backgroundColor: Colors.orange,
          ),
        );
    }
  }

  // 🔹 HOTEL
  static Future<void> _navigateToHotelDetails(
      BuildContext context, ChatbotResponse response) async {
    final provider = Provider.of<HotelProvider>(context, listen: false);

    _showLoading(context);
    try {
      await provider.fetchHotelDetail(response.slug.toString());
      Navigator.pop(context);

      if (provider.selectedHotel != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HotelDetailsScreen(hotelSlug: response.slug.toString()),
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      _showError(context, 'Erreur: $e');
    }
  }

  // 🔹 RESTAURANT
  static Future<void> _navigateToRestaurantDetails(
      BuildContext context, ChatbotResponse response) async {
    final provider = Provider.of<RestaurantProvider>(context, listen: false);

    _showLoading(context);
    try {
      await provider.selectRestaurantBySlug(response.slug.toString());
      Navigator.pop(context);

      if (provider.selectedRestaurant != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                RestaurantDetailsScreen(restaurant: provider.selectedRestaurant!),
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      _showError(context, 'Erreur: $e');
    }
  }

  // 🔹 MUSEE
  static Future<void> _navigateToMuseeDetails(
      BuildContext context, ChatbotResponse response) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MuseeDetailsScreen(museeSlug: response.slug.toString()),
      ),
    );
  }

  // 🔹 MAISON D'HOTE
  static Future<void> _navigateToMaisonDetails(
      BuildContext context, ChatbotResponse response) async {
    final provider = Provider.of<MaisonProvider>(context, listen: false);

    _showLoading(context);
    try {
      await provider.fetchMaisonBySlug(response.slug.toString());
      Navigator.pop(context);

      if (provider.selectedMaison != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                MaisonDetailsScreen(maison: provider.selectedMaison!),
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      _showError(context, 'Erreur: $e');
    }
  }

  // 🔹 EVENT
  static Future<void> _navigateToEventDetails(
      BuildContext context, ChatbotResponse response) async {
    final provider = Provider.of<EventProvider>(context, listen: false);

    _showLoading(context);
    try {
      await provider.fetchEventBySlug(response.slug.toString());
      Navigator.pop(context);

      if (provider.selectedEvent != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EventDetailsScreen(event: provider.selectedEvent!),
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      _showError(context, 'Erreur: $e');
    }
  }

  // Utils
  static void _showLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  static void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
