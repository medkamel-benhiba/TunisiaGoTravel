import 'package:flutter/material.dart';
import '../screens/culture_screen.dart';
import '../models/hotel.dart'; // â† Assure-toi que ton modÃ¨le Hotel est importÃ©

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
  chatbot
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
}