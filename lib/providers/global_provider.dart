import 'package:flutter/material.dart';
import 'package:tunisiagotravel/models/conversation.dart';
import '../screens/culture_screen.dart';
import '../models/hotel.dart';

enum AppPage {
  home,
  hotels,
  restaurants,
  maisonsHotes,
  activites,
  evenement,
  circuits,
  circuitsPredefini,
  circuitsManuel,
  circuitsAuto,
  cultures,
  agil,
  guide,
  login,
  signup,
  chatbot,
  stateScreenDetails,

}

class GlobalProvider with ChangeNotifier {
  AppPage _currentPage = AppPage.home;
  int _rebuildCounter = 0;

  AppPage get currentPage => _currentPage;
  int get rebuildCounter => _rebuildCounter;

  CulturesCategory? _culturesInitialCategory;
  String? _selectedCityForHotels;
  List<Hotel> _availableHotels = [];

  // 🔹 Add search criteria storage
  Map<String, dynamic> _searchCriteria = {};
  Map<String, dynamic> get searchCriteria => _searchCriteria;

  String? get selectedCityForHotels => _selectedCityForHotels;
  List<Hotel> get availableHotels => _availableHotels;

  String? _initialRestaurantDestinationId;
  String? get initialRestaurantDestinationId => _initialRestaurantDestinationId;

  // 🔹 Add chatbot initial message storage
  String? _chatbotInitialMessage;
  String? get chatbotInitialMessage => _chatbotInitialMessage;

  Conversation? _selectedConversation;
  Conversation? get selectedConversation => _selectedConversation;

  void setPage(AppPage page) {
    _currentPage = page;
    _rebuildCounter++;
    notifyListeners();
  }

  void setCulturesInitialCategory(String? categoryStr) {
    if (categoryStr == null) return;
    switch (categoryStr.toLowerCase()) {
      case 'musee':
        _culturesInitialCategory = CulturesCategory.musee;
        break;
      case 'monument':
        _culturesInitialCategory = CulturesCategory.monument;
        break;
      case 'festival':
        _culturesInitialCategory = CulturesCategory.festival;
        break;
      case 'artisanat':
        _culturesInitialCategory = CulturesCategory.artisanat;
        break;
      default:
        _culturesInitialCategory = CulturesCategory.none;
    }
  }

  void setSelectedCityForHotels(String? city) {
    _selectedCityForHotels = city;
    notifyListeners();
  }

  void setAvailableHotels(List<Hotel> hotels) {
    _availableHotels = hotels;
    notifyListeners();
  }

  // 🔹 Add method to store search criteria
  void setSearchCriteria(Map<String, dynamic> criteria) {
    _searchCriteria = criteria;
    notifyListeners();
  }

  // 🔹 Clear search data when needed
  void clearSearchData() {
    _selectedCityForHotels = null;
    _availableHotels = [];
    _searchCriteria = {};
    notifyListeners();
  }

  // 🔹 Add method to store chatbot initial message
  void setChatbotInitialMessage(String? message) {
    _chatbotInitialMessage = message;
    notifyListeners();
  }

  // 🔹 Clear chatbot initial message after use
  void clearChatbotInitialMessage() {
    _chatbotInitialMessage = null;
    // Don't call notifyListeners() here as it's used after navigation
  }

  void setInitialRestaurantDestinationId(String? id) {
    _initialRestaurantDestinationId = id;
    notifyListeners();
  }

  void clearInitialRestaurantDestinationId() {
    _initialRestaurantDestinationId = null;
    notifyListeners();
  }

  void setChatbotConversation(Conversation? conversation, {String? initialMessage}) {
    _selectedConversation = conversation;
    _chatbotInitialMessage = initialMessage;
    setPage(AppPage.chatbot);
  }

  void clearChatbotConversation() {
    _selectedConversation = null;
    clearChatbotInitialMessage();
  }

}