import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../models/hotel.dart';
import '../models/hotelAvailabilityResponse.dart';
import '../models/hotelTgt.dart';
import '../models/hotel_details.dart';
import '../models/mouradi.dart';
import '../services/api_service.dart';
import 'global_provider.dart';

class HotelProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  /// Cached hotels per destination
  final Map<String, List<Hotel>> _hotelsByDestination = {};

  /// All fetched hotels
  List<Hotel> _allHotels = [];
  List<Hotel> get allHotels => _allHotels;

  /// Current displayed hotels
  List<Hotel> _hotels = [];
  List<Hotel> get hotels => _hotels;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  HotelDetail? _selectedHotel;
  HotelDetail? get selectedHotel => _selectedHotel;

  bool _isLoadingDetail = false;
  bool get isLoadingDetail => _isLoadingDetail;

  String? _errorDetail;
  String? get errorDetail => _errorDetail;

  MouradiHotel? _selectedMouradiHotel;
  MouradiHotel? get selectedMouradiHotel => _selectedMouradiHotel;

  //optimised for pagination
  List<dynamic> _searchResults = [];
  List<dynamic> get searchResults => _searchResults;

  bool _hasMoreSearchResults = true;
  bool get hasMoreSearchResults => _hasMoreSearchResults;

  bool _isInitialSearchLoading = false;
  bool get isInitialSearchLoading => _isInitialSearchLoading;

  bool _isLoadingMoreResults = false;
  bool get isLoadingMoreResults => _isLoadingMoreResults;

  Map<String, dynamic>? _currentSearchParams;
  int _searchDisponibilityPage = 1;
  int _searchSimplePage = 1;


  // ===== Fetch all hotels once =====
  Future<void> fetchAllHotels() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allHotels = await _apiService.gethotels();
      // Pre-cache per destination
      for (var hotel in _allHotels) {
        final destId = hotel.destinationId;
        if (!_hotelsByDestination.containsKey(destId)) {
          _hotelsByDestination[destId] = [];
        }
        _hotelsByDestination[destId]!.add(hotel);
      }
    } catch (e) {
      _allHotels = [];
      debugPrint("Error fetching hotels: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  // ===== Get hotels by destination from cache =====
  void setHotelsByDestination(String? destinationId) {
    _hotels = _hotelsByDestination[destinationId] ?? [];
    notifyListeners();
  }

  // ===== Fetch hotel details =====
  Future<void> fetchHotelDetail(String slug) async {
    _isLoadingDetail = true;
    _errorDetail = null;
    notifyListeners();

    try {
      final detail = await _apiService.gethoteldetail(slug);
      if (detail != null) {
        _selectedHotel = detail;
      } else {
        _errorDetail = "Hotel details not found";
        _selectedHotel = null;
      }
    } catch (e) {
      _errorDetail = e.toString();
      _selectedHotel = null;
      debugPrint("Error fetching hotel detail: $e");
    }

    _isLoadingDetail = false;
    notifyListeners();
  }

  // ===== Get hotels by destination from cache =====
  List<Hotel> getHotelsByDestination(String destinationId) {
    return _hotelsByDestination[destinationId] ?? [];
  }

  // ===== Clear selected hotel =====
  void clearSelectedHotel() {
    _selectedHotel = null;
    _errorDetail = null;
    notifyListeners();
  }

  // ===== Get destination ID by city name =====
  String? getDestinationIdByCity(String cityName) {
    try {
      return _allHotels.firstWhere(
            (hotel) => hotel.destinationName?.toLowerCase() == cityName.toLowerCase(),
      ).destinationId;
    } catch (e) {
      return null;
    }
  }

  // ======================================================
  // 🔹 Disponibility simple (getAvailableHotels) - WITH PAGINATION
  // ======================================================
  List<Hotel> _availableHotels = [];
  List<Hotel> get availableHotels => _availableHotels;

  bool _isLoadingAvailableHotels = false;
  bool get isLoadingAvailableHotels => _isLoadingAvailableHotels;

  String? _errorAvailableHotels;
  String? get errorAvailableHotels => _errorAvailableHotels;

  // 🔹 Clear available hotels
  void clearAvailableHotels() {
    _availableHotels = [];
    _hotelDisponibilityPontion = null;
    _errorAvailableHotels = null;
    _errorDisponibilityPontion = null;
  }

  // 🔹 Fetch single page
  Future<void> fetchAvailableHotels({
    required String destinationId,
    required String dateStart,
    required String dateEnd,
    required String adults,
    required String rooms,
    required String children,
    int babies = 0,
    int page = 1,
  }) async {
    _isLoadingAvailableHotels = true;
    _errorAvailableHotels = null;
    notifyListeners();

    try {
      final hotels = await _apiService.getAvailableHotels(
        destinationId: destinationId,
        dateStart: dateStart,
        dateEnd: dateEnd,
        adults: adults,
        rooms: rooms,
        children: children,
        babies: babies,
        page: page,
      );
      // Deduplicate hotels by ID
      final existingIds = _availableHotels.map((hotel) => hotel.id).toSet();
      final newHotels = hotels.where((hotel) => !existingIds.contains(hotel.id)).toList();
      _availableHotels = [..._availableHotels, ...newHotels];
    } catch (e) {
      _errorAvailableHotels = e.toString();
      debugPrint("Error fetching available hotels: $e");
    }

    _isLoadingAvailableHotels = false;
    notifyListeners();
  }

  // 🔹 Fetch ALL pages for simple availability
  Future<void> fetchAllAvailableHotels({
    required String destinationId,
    required String dateStart,
    required String dateEnd,
    required String adults,
    required String rooms,
    required String children,
    int babies = 0,
    int maxPages = 12,
    required List<String> filteredHotelIds, // IDs from fetchAllHotelDisponibilityPontion
  }) async {
    _isLoadingAvailableHotels = true;
    _errorAvailableHotels = null;
    notifyListeners();

    List<Hotel> allHotels = List.from(_availableHotels); // Start with existing hotels
    Set<String> existingIds = allHotels.map((hotel) => hotel.id).toSet();
    Set<String> remainingIds = Set.from(filteredHotelIds); // Track unmatched IDs
    int page = 1;
    bool hasMorePages = true;
    int? lastPage;

    try {
      while (hasMorePages && page <= maxPages && remainingIds.isNotEmpty) {
        debugPrint("Fetching available hotels page $page");

        final response = await _apiService.getAvailableHotels(
          destinationId: destinationId,
          dateStart: dateStart,
          dateEnd: dateEnd,
          adults: adults,
          rooms: rooms,
          children: children,
          babies: babies,
          page: page,
        );

        // Filter and deduplicate hotels
        final filteredHotels = response
            .where((hotel) => filteredHotelIds.contains(hotel.id) && !existingIds.contains(hotel.id))
            .toList();

        allHotels.addAll(filteredHotels);
        existingIds.addAll(filteredHotels.map((hotel) => hotel.id));
        remainingIds.removeAll(filteredHotels.map((hotel) => hotel.id));

        // Check pagination info
        final rawResponse = await http.post(
          Uri.parse('https://backend.tunisiagotravel.com/utilisateur/hoteldisponible?page=$page'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'destination_id': destinationId,
            'date_start': dateStart,
            'date_end': dateEnd,
            'adults': adults,
            'rooms': rooms,
            'children': children,
            'babies': babies,
          }),
        );

        if (rawResponse.statusCode == 200) {
          final jsonData = json.decode(rawResponse.body);
          if (jsonData is Map<String, dynamic> && jsonData.containsKey('last_page')) {
            lastPage = jsonData['last_page'] as int;
            if (page >= lastPage) {
              hasMorePages = false;
            }
          } else if (response.length < 13) {
            hasMorePages = false;
          }
        } else {
          hasMorePages = false;
        }

        page++;
      }

      _availableHotels = allHotels;
      debugPrint("Fetched ${allHotels.length} available hotels across ${page - 1} pages");
      if (remainingIds.isNotEmpty) {
        debugPrint("Warning: Not all filteredHotelIds found: $remainingIds");
      }
    } catch (e) {
      _errorAvailableHotels = e.toString();
      debugPrint("Error fetching all available hotels: $e");
    }

    _isLoadingAvailableHotels = false;
    notifyListeners();
  }

  // ======================================================
  // 🔹 Disponibility avec pontion (pagination)
  // ======================================================
  HotelAvailabilityResponse? _hotelDisponibilityPontion;
  HotelAvailabilityResponse? get hotelDisponibilityPontion => _hotelDisponibilityPontion;

  bool _isLoadingDisponibilityPontion = false;
  bool get isLoadingDisponibilityPontion => _isLoadingDisponibilityPontion;

  String? _errorDisponibilityPontion;
  String? get errorDisponibilityPontion => _errorDisponibilityPontion;

  // 🔹 Update hotel disponibility pention
  void updateHotelDisponibilityPontion(HotelAvailabilityResponse response) {
    _hotelDisponibilityPontion = response;
    notifyListeners();
  }

  // 🔹 Fetch single page
  Future<void> fetchHotelDisponibilityPontion({
    required String destinationId,
    required String dateStart,
    required String dateEnd,
    required List<Map<String, dynamic>> rooms,
    int page = 1,
  }) async {
    _isLoadingDisponibilityPontion = true;
    _errorDisponibilityPontion = null;
    notifyListeners();

    try {
      final res = await _apiService.getHotelDisponibilityPontion(
        destinationId: destinationId,
        dateStart: dateStart,
        dateEnd: dateEnd,
        rooms: rooms,
        page: page,
      );

      // Deduplicate hotels by ID
      final existingIds = _hotelDisponibilityPontion?.data.map((hotel) => hotel.id).toSet() ?? {};
      final newHotels = res.data.where((hotel) => !existingIds.contains(hotel.id)).toList();

      _hotelDisponibilityPontion = HotelAvailabilityResponse(
        currentPage: res.currentPage,
        data: [...?_hotelDisponibilityPontion?.data ?? [], ...newHotels],
        lastPage: res.lastPage,
        nextPageUrl: res.nextPageUrl,
      );
    } catch (e) {
      _errorDisponibilityPontion = e.toString();
      if (page == 1) _hotelDisponibilityPontion = null;
      debugPrint("Error fetching hotel disponibility pontion: $e");
    }

    _isLoadingDisponibilityPontion = false;
    notifyListeners();
  }


  // ======================================================
  // 🔹 TGT HOTEL CONVERSION METHODS
  // ======================================================

  /// Convert HotelData with TGT type to HotelTgt
  HotelTgt? convertToHotelTgt(HotelData hotelData) {
    if (hotelData.disponibility.disponibilityType != 'tgt') {
      return null;
    }

    try {
      List<PensionTgt> pensionsList = [];

      for (var pension in hotelData.disponibility.pensions) {
        if (pension is Map<String, dynamic>) {
          pensionsList.add(PensionTgt.fromJson(pension));
        }
      }

      return HotelTgt(
        id: hotelData.id,
        name: hotelData.name,
        slug: hotelData.slug,
        idCityBbx: hotelData.idCityBbx,
        idHotelBbx: hotelData.idHotelBbx,
        disponibility: DisponibilityTgt(
          disponibilitytype: hotelData.disponibility.disponibilityType,
          pensions: pensionsList,
        ),
      );
    } catch (e) {
      debugPrint("Error converting to HotelTgt: $e");
      return null;
    }
  }

  /// Get all TGT hotels from current availability data
  List<HotelTgt> getTgtHotels() {
    if (_hotelDisponibilityPontion == null) return [];

    List<HotelTgt> tgtHotels = [];

    for (var hotelData in _hotelDisponibilityPontion!.data) {
      if (hotelData.disponibility.disponibilityType == 'tgt') {
        final tgtHotel = convertToHotelTgt(hotelData);
        if (tgtHotel != null) {
          tgtHotels.add(tgtHotel);
        }
      }
    }

    return tgtHotels;
  }

  /// Find TGT hotel by hotel ID
  HotelTgt? findTgtHotelById(String hotelId) {
    if (_hotelDisponibilityPontion == null) return null;

    try {
      final hotelData = _hotelDisponibilityPontion!.data
          .firstWhere((h) => h.id == hotelId && h.disponibility.disponibilityType == 'tgt');
      return convertToHotelTgt(hotelData);
    } catch (e) {
      debugPrint("TGT hotel with ID $hotelId not found");
      return null;
    }
  }

  // ======================================================
  // 🔹 MOURADI HOTEL METHODS
  // ======================================================

  Future<void> fetchMouradiHotelAvailability({
    required String hotelId,
    required String cityId,
    required String dateStart,
    required String dateEnd,
    required List<Map<String, dynamic>> rooms,
  }) async {
    try {
      final res = await ApiService().showMouradiDisponibility(
        hotelId: hotelId,
        city: cityId,
        dateStart: dateStart,
        dateEnd: dateEnd,
        rooms: rooms,
      );

      if (res.isNotEmpty) {
        _selectedMouradiHotel = MouradiHotel.fromJson(res);
      } else {
        _selectedMouradiHotel = null;
      }
      notifyListeners();
    } catch (e) {
      _selectedMouradiHotel = null;
      debugPrint("Error fetching Mouradi hotel: $e");
      notifyListeners();
    }
  }
  ////////////////////
// 🚀 MAIN SMOOTH SEARCH METHOD
  Future<void> startSmoothSearch({
    required String destinationId,
    required String dateStart,
    required String dateEnd,
    required List<Map<String, dynamic>> rooms,
    required String adults,
    required String children,
    required String totalRooms,
  }) async {
    // Reset search state
    _searchResults.clear();
    _hasMoreSearchResults = true;
    _isInitialSearchLoading = true;
    _searchDisponibilityPage = 1;
    _searchSimplePage = 1;
    _currentSearchParams = {
      'destinationId': destinationId,
      'dateStart': dateStart,
      'dateEnd': dateEnd,
      'rooms': rooms,
      'adults': adults,
      'children': children,
      'totalRooms': totalRooms,
    };

    notifyListeners();

    try {
      // Load first page of results quickly
      await _loadFirstSearchResults();

      // Continue loading in background WITHOUT triggering UI updates
      _loadMoreSearchResultsInBackground();

    } catch (e) {
      debugPrint("Error in smooth search: $e");
      _isInitialSearchLoading = false;
      notifyListeners();
    }
  }

// 🚀 LOAD FIRST SEARCH RESULTS (Fast initial response)
  Future<void> _loadFirstSearchResults() async {
    if (_currentSearchParams == null) return;

    try {
      // Load first pages in parallel
      final futures = [
        _loadSearchDisponibilityPage(_searchDisponibilityPage),
        _loadSearchSimplePage(_searchSimplePage),
      ];

      final results = await Future.wait(futures, eagerError: false);

      List<Hotel> initialResults = [];

      // Process disponibility results
      if (results[0] != null && results[0].isNotEmpty) {
        initialResults.addAll(results[0].map((e) => Hotel.fromJson(e)).toList());
        _searchDisponibilityPage++;
      }

      // Process simple results
      if (results[1] != null && results[1].isNotEmpty) {
        // Filter simple results based on disponibility IDs
        final disponibilityIds =
            results[0]?.map((hotel) => hotel['id']).toSet() ?? <String>{};

        final filteredSimpleResults = results[1]
            .where((hotel) => disponibilityIds.contains(hotel['id']))
            .map((e) => Hotel.fromJson(e))
            .toList();

        initialResults.addAll(filteredSimpleResults);
        _searchSimplePage++;
      }

      _searchResults = initialResults;
      _isInitialSearchLoading = false;

      notifyListeners(); // Widget should update GlobalProvider separately

      debugPrint("Initial search results loaded: ${initialResults.length} hotels");
    } catch (e) {
      debugPrint("Error loading initial search results: $e");
      _isInitialSearchLoading = false;
      notifyListeners();
    }
  }


// 🚀 LOAD MORE RESULTS IN BACKGROUND (Silent loading)
  void _loadMoreSearchResultsInBackground() async {
    int maxPages = 8; // Reasonable limit
    int currentIteration = 0;

    while (_hasMoreSearchResults && _currentSearchParams != null && currentIteration < maxPages) {
      await Future.delayed(const Duration(milliseconds: 800)); // Delay between requests

      try {
        await _loadNextBatchSilently();
        currentIteration++;
      } catch (e) {
        debugPrint("Error in background loading: $e");
        _hasMoreSearchResults = false;
        break;
      }
    }
  }

// 🚀 LOAD NEXT BATCH SILENTLY
  Future<void> _loadNextBatchSilently() async {
    if (_isLoadingMoreResults || !_hasMoreSearchResults || _currentSearchParams == null) return;

    _isLoadingMoreResults = true;

    try {
      final futures = <Future>[];

      if (_searchDisponibilityPage <= 8) {
        futures.add(_loadSearchDisponibilityPage(_searchDisponibilityPage));
      }
      if (_searchSimplePage <= 8) {
        futures.add(_loadSearchSimplePage(_searchSimplePage));
      }

      if (futures.isEmpty) {
        _hasMoreSearchResults = false;
        _isLoadingMoreResults = false;
        return;
      }

      final results = await Future.wait(futures, eagerError: false);

      List<Hotel> newResults = [];
      bool hasMoreDisponibility = false;
      bool hasMoreSimple = false;

      if (results.isNotEmpty && results[0] != null && results[0].isNotEmpty) {
        newResults.addAll(results[0].map((e) => Hotel.fromJson(e)).toList());
        _searchDisponibilityPage++;
        hasMoreDisponibility = true;
      }

      if (results.length > 1 && results[1] != null && results[1].isNotEmpty) {
        final newDisponibilityIds =
            results[0]?.map((hotel) => hotel['id']).toSet() ?? <String>{};

        final filteredSimple =
        results[1].where((hotel) => newDisponibilityIds.contains(hotel['id'])).map((e) => Hotel.fromJson(e)).toList();

        newResults.addAll(filteredSimple);
        _searchSimplePage++;
        hasMoreSimple = true;
      }

      if (newResults.isNotEmpty) {
        _searchResults.addAll(newResults);
      }

      if (!hasMoreDisponibility && !hasMoreSimple) {
        _hasMoreSearchResults = false;
      }
    } catch (e) {
      debugPrint("Error loading next batch silently: $e");
      _hasMoreSearchResults = false;
    }

    _isLoadingMoreResults = false;
  }

// 🚀 LOAD SEARCH DISPONIBILITY PAGE
  Future<List<dynamic>> _loadSearchDisponibilityPage(int page) async {
    if (_currentSearchParams == null) return [];

    try {
      final res = await _apiService.getHotelDisponibilityPontion(
        destinationId: _currentSearchParams!['destinationId'],
        dateStart: _currentSearchParams!['dateStart'],
        dateEnd: _currentSearchParams!['dateEnd'],
        rooms: _currentSearchParams!['rooms'],
        page: page,
      );

      // Apply your existing filtering logic
      final filteredHotels = res.data.where((hotel) {
        final dispo = hotel.disponibility;
        final hotelName = hotel.name?.toLowerCase() ?? '';

        return (dispo != null &&
            (dispo.disponibilityType == 'bhr' ||
                dispo.disponibilityType == 'tgt' ||
                hotelName.contains('mouradi')));
      }).toList();

      return filteredHotels;

    } catch (e) {
      debugPrint("Error loading search disponibility page $page: $e");
      return [];
    }
  }

// 🚀 LOAD SEARCH SIMPLE PAGE
  Future<List<dynamic>> _loadSearchSimplePage(int page) async {
    if (_currentSearchParams == null) return [];

    try {
      final hotels = await _apiService.getAvailableHotels(
        destinationId: _currentSearchParams!['destinationId'],
        dateStart: _currentSearchParams!['dateStart'],
        dateEnd: _currentSearchParams!['dateEnd'],
        adults: _currentSearchParams!['adults'],
        rooms: _currentSearchParams!['totalRooms'],
        children: _currentSearchParams!['children'],
        page: page,
      );

      return hotels;

    } catch (e) {
      debugPrint("Error loading search simple page $page: $e");
      return [];
    }
  }

// 🚀 MANUAL LOAD MORE (Optional - for user-triggered loading)
  Future<void> loadMoreSearchResults() async {
    if (!_isLoadingMoreResults && _hasMoreSearchResults) {
      await _loadNextBatchSilently();
      notifyListeners(); // Only notify when user explicitly requests more
    }
  }

// 🚀 RESET SEARCH
  void resetSearch() {
    _searchResults.clear();
    _currentSearchParams = null;
    _hasMoreSearchResults = true;
    _isInitialSearchLoading = false;
    _isLoadingMoreResults = false;
    _searchDisponibilityPage = 1;
    _searchSimplePage = 1;
    notifyListeners();
  }

}