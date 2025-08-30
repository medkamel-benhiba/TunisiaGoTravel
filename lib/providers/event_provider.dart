import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/event.dart';

class EventProvider with ChangeNotifier {
  final String _baseUrl = "https://backend.tunisiagotravel.com";

  List<Event> _events = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Event> get events => _events;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Fetch all events from API
  Future<void> fetchEvents() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('$_baseUrl/utilisateur/allevent'));

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        if (jsonData == null || jsonData['events'] == null) {
          throw Exception("API returned null data");
        }

        if (jsonData['events']['data'] is List) {
          _events = (jsonData['events']['data'] as List)
              .map((e) => Event.fromJson(e))
              .toList();
        } else {
          throw Exception("Unexpected data format: ${jsonData['events']}");
        }
      } else {
        throw Exception("Failed to fetch events: ${response.statusCode}");
      }
    } catch (e, stackTrace) {
      debugPrint("Error in fetchEvents: $e");
      debugPrint("StackTrace: $stackTrace");
      _errorMessage = "Impossible de charger les événements";
      _events = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Filter events by destinationId
  List<Event> getEventsByDestination(String destinationId) {
    return _events.where((event) => event.destinationId == destinationId).toList();
  }

  // Optional: update cache or state when a destination is selected
  void setEventsByDestination(String destinationId) {
    // Currently nothing extra needed, but you could implement caching here
    notifyListeners();
  }
}
