import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/hotel.dart';
import '../models/hotelAvailabilityResponse.dart';
import '../models/hotelTgt.dart';
import '../models/hotel_details.dart';
import '../models/mouradi.dart';
import '../services/api_service.dart';

class HotelProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  /// Cached hotels per destination
  final Map<String, List<Hotel>> _hotelsByDestination = {};

  /// All fetched hotels
  List<Hotel> _allHotels = [];

  //All hotels Cached
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
      _availableHotels = hotels;
    } catch (e) {
      _errorAvailableHotels = e.toString();
      _availableHotels = [];
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

    List<Hotel> allHotels = [];
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

        // Filter hotels to only include those with IDs matching filteredHotelIds
        final filteredHotels = response.where((hotel) {
          return filteredHotelIds.contains(hotel.id);
        }).toList();

        allHotels.addAll(filteredHotels);
        remainingIds.removeAll(filteredHotels.map((hotel) => hotel.id));

        // Check if response contains pagination info (e.g., 'last_page')
        // Assuming getAvailableHotels returns a Map with 'data' and 'last_page'
        final rawResponse = await http.post(
          Uri.parse('https://test.tunisiagotravel.com/utilisateur/hoteldisponible?page=$page'),
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
          } else {
            if (response.length < 13) {
              hasMorePages = false;
            }
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
      _availableHotels = [];
      debugPrint("Error fetching all available hotels: $e");
    }

    _isLoadingAvailableHotels = false;
    notifyListeners();
  }

  // ======================================================
  // 🔹 Disponibility avec pontion (pagination)
  // ======================================================
  HotelAvailabilityResponse? _hotelDisponibilityPontion;
  HotelAvailabilityResponse? get hotelDisponibilityPontion =>
      _hotelDisponibilityPontion;

  bool _isLoadingDisponibilityPontion = false;
  bool get isLoadingDisponibilityPontion => _isLoadingDisponibilityPontion;

  String? _errorDisponibilityPontion;
  String? get errorDisponibilityPontion => _errorDisponibilityPontion;

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

      if (page == 1) {
        _hotelDisponibilityPontion = res;
      } else {
        _hotelDisponibilityPontion = HotelAvailabilityResponse(
          currentPage: res.currentPage,
          data: [...?_hotelDisponibilityPontion?.data, ...res.data],
          lastPage: res.lastPage,
          nextPageUrl: res.nextPageUrl,
        );
      }
    } catch (e) {
      _errorDisponibilityPontion = e.toString();
      if (page == 1) _hotelDisponibilityPontion = null;
      debugPrint("Error fetching hotel disponibility pontion: $e");
    }

    _isLoadingDisponibilityPontion = false;
    notifyListeners();
  }

  // 🔹 Fetch ALL pages for pontion availability
  Future<void> fetchAllHotelDisponibilityPontion({
    required String destinationId,
    required String dateStart,
    required String dateEnd,
    required List<Map<String, dynamic>> rooms,
    int maxPages = 12,
  }) async {
    _isLoadingDisponibilityPontion = true;
    _errorDisponibilityPontion = null;
    notifyListeners();

    List<HotelData> allHotelData = [];
    int page = 1;
    bool hasMorePages = true;
    int? totalPages;

    try {
      while (hasMorePages && page <= maxPages) {
        debugPrint("Fetching hotel disponibility pontion page $page");

        final res = await _apiService.getHotelDisponibilityPontion(
          destinationId: destinationId,
          dateStart: dateStart,
          dateEnd: dateEnd,
          rooms: rooms,
          page: page,
        );

        final filteredHotels = res.data.where((hotel) {
          final dispo = hotel.disponibility;
          final hotelName = hotel.name?.toLowerCase() ?? '';
          bool hasValidPensions = false;

          // Check if pensions is non-empty
          if (dispo != null && dispo.pensions != null) {
            if (dispo.pensions is List) {
              hasValidPensions = dispo.pensions.isNotEmpty;
            } else if (dispo.pensions is Map) {
              // Check if pensions has rooms with boarding options
              final pensionsMap = dispo.pensions as Map<String, dynamic>;
              hasValidPensions = pensionsMap.containsKey('rooms') &&
                  pensionsMap['rooms'] != null &&
                  (pensionsMap['rooms']['room'] is List
                      ? pensionsMap['rooms']['room'].isNotEmpty
                      : pensionsMap['rooms']['room'] != null);
            }
          }

          // Keep hotel if:
          // 1. disponibilitytype is 'bhr' or 'tgt', OR
          // 2. Hotel name contains 'mouradi', AND
          // 3. Pensions is non-empty
          return (dispo != null &&
              (dispo.disponibilityType == 'bhr' ||
                  dispo.disponibilityType == 'tgt' ||
                  hotelName.contains('mouradi')));
        }).toList();

        allHotelData.addAll(filteredHotels);
        totalPages = res.lastPage;

        if (page >= res.lastPage || res.data.isEmpty) {
          hasMorePages = false;
        } else {
          page++;
        }
      }

      _hotelDisponibilityPontion = HotelAvailabilityResponse(
        currentPage: totalPages ?? 1,
        data: allHotelData,
        lastPage: totalPages ?? 1,
        nextPageUrl: null,
      );

      debugPrint("Fetched ${allHotelData.length} hotels with availability across ${page - 1} pages");
    } catch (e) {
      _errorDisponibilityPontion = e.toString();
      _hotelDisponibilityPontion = null;
      debugPrint("Error fetching all hotel disponibility pontion: $e");
    }

    _isLoadingDisponibilityPontion = false;
    notifyListeners();
  }

  // 🔹 Fetch next page only (for manual pagination)
  Future<void> fetchMoreHotelDisponibilityPontion({
    required String destinationId,
    required String dateStart,
    required String dateEnd,
    required List<Map<String, dynamic>> rooms,
  }) async {
    if (_hotelDisponibilityPontion == null ||
        (_hotelDisponibilityPontion!.currentPage >=
            _hotelDisponibilityPontion!.lastPage)) {
      return;
    }

    _isLoadingDisponibilityPontion = true;
    notifyListeners();

    try {
      final res = await _apiService.getHotelDisponibilityPontion(
        destinationId: destinationId,
        dateStart: dateStart,
        dateEnd: dateEnd,
        rooms: rooms,
        page: _hotelDisponibilityPontion!.currentPage + 1,
      );

      _hotelDisponibilityPontion = HotelAvailabilityResponse(
        currentPage: res.currentPage,
        data: [..._hotelDisponibilityPontion!.data, ...res.data],
        lastPage: res.lastPage,
        nextPageUrl: res.nextPageUrl,
      );
    } catch (e) {
      _errorDisponibilityPontion = e.toString();
      debugPrint("Error fetching more hotel disponibility pontion: $e");
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
  // ======================================================
  // 🔹 PROGRESSIVE LOADING - Available Hotels
  // ======================================================


  bool _hasMoreAvailablePages = true;
  bool get hasMoreAvailablePages => _hasMoreAvailablePages;


  int _currentAvailablePage = 1;
  Set<String> _targetHotelIds = {};

  // 🔹 Start progressive loading - shows first results immediately
  Future<void> startProgressiveAvailableHotels({
    required String destinationId,
    required String dateStart,
    required String dateEnd,
    required String adults,
    required String rooms,
    required String children,
    int babies = 0,
    required List<String> filteredHotelIds,
    int batchSize = 3, // Load 3 pages at a time
  }) async {
    // Reset state
    _availableHotels.clear();
    _currentAvailablePage = 1;
    _hasMoreAvailablePages = true;
    _targetHotelIds = Set.from(filteredHotelIds);
    _isLoadingAvailableHotels = true;
    _errorAvailableHotels = null;
    notifyListeners();

    // Load first batch
    await _loadAvailableHotelsBatch(
      destinationId: destinationId,
      dateStart: dateStart,
      dateEnd: dateEnd,
      adults: adults,
      rooms: rooms,
      children: children,
      babies: babies,
      batchSize: batchSize,
    );
  }

  // 🔹 Load more hotels (for infinite scroll or "Load More" button)
  Future<void> loadMoreAvailableHotels({
    required String destinationId,
    required String dateStart,
    required String dateEnd,
    required String adults,
    required String rooms,
    required String children,
    int babies = 0,
    int batchSize = 3,
  }) async {
    if (!_hasMoreAvailablePages || _isLoadingAvailableHotels) return;

    _isLoadingAvailableHotels = true;
    notifyListeners();

    await _loadAvailableHotelsBatch(
      destinationId: destinationId,
      dateStart: dateStart,
      dateEnd: dateEnd,
      adults: adults,
      rooms: rooms,
      children: children,
      babies: babies,
      batchSize: batchSize,
    );
  }

  // 🔹 Internal method to load a batch of pages
  Future<void> _loadAvailableHotelsBatch({
    required String destinationId,
    required String dateStart,
    required String dateEnd,
    required String adults,
    required String rooms,
    required String children,
    int babies = 0,
    int batchSize = 3,
  }) async {
    try {
      List<Hotel> batchHotels = [];
      int pagesLoaded = 0;

      while (pagesLoaded < batchSize && _hasMoreAvailablePages && _targetHotelIds.isNotEmpty) {
        debugPrint("Loading available hotels page $_currentAvailablePage");

        final response = await _apiService.getAvailableHotels(
          destinationId: destinationId,
          dateStart: dateStart,
          dateEnd: dateEnd,
          adults: adults,
          rooms: rooms,
          children: children,
          babies: babies,
          page: _currentAvailablePage,
        );

        // Filter hotels to only include those matching target IDs
        final filteredHotels = response.where((hotel) {
          return _targetHotelIds.contains(hotel.id);
        }).toList();

        batchHotels.addAll(filteredHotels);
        _targetHotelIds.removeAll(filteredHotels.map((hotel) => hotel.id));

        // Check if we have more pages
        final hasMore = await _checkHasMorePages(
            destinationId, dateStart, dateEnd, adults, rooms, children, babies, _currentAvailablePage
        );

        if (!hasMore || response.length < 10) { // Adjust threshold as needed
          _hasMoreAvailablePages = false;
        }

        _currentAvailablePage++;
        pagesLoaded++;

        // Break early if we found all target hotels
        if (_targetHotelIds.isEmpty) {
          _hasMoreAvailablePages = false;
          break;
        }
      }

      // Add new hotels to the list
      _availableHotels.addAll(batchHotels);

      debugPrint("Loaded ${batchHotels.length} new hotels. Total: ${_availableHotels.length}");

    } catch (e) {
      _errorAvailableHotels = e.toString();
      debugPrint("Error loading available hotels batch: $e");
    }

    _isLoadingAvailableHotels = false;
    notifyListeners();
  }

  // 🔹 Check if more pages exist
  Future<bool> _checkHasMorePages(String destinationId, String dateStart, String dateEnd,
      String adults, String rooms, String children, int babies, int currentPage) async {
    try {
      final rawResponse = await http.post(
        Uri.parse('https://test.tunisiagotravel.com/utilisateur/hoteldisponible?page=$currentPage'),
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
          return currentPage < (jsonData['last_page'] as int);
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // ======================================================
  // 🔹 PROGRESSIVE LOADING - Hotel Disponibility Pontion
  // ======================================================
  List<HotelData> _hotelDisponibilityData = [];
  List<HotelData> get hotelDisponibilityData => _hotelDisponibilityData;

  bool _hasMoreDisponibilityPages = true;
  bool get hasMoreDisponibilityPages => _hasMoreDisponibilityPages;

  int _currentDisponibilityPage = 1;
  int? _totalDisponibilityPages;

  // 🔹 Start progressive loading for disponibility
  Future<void> startProgressiveHotelDisponibility({
    required String destinationId,
    required String dateStart,
    required String dateEnd,
    required List<Map<String, dynamic>> rooms,
    int batchSize = 3,
  }) async {
    // Reset state
    _hotelDisponibilityData.clear();
    _currentDisponibilityPage = 1;
    _hasMoreDisponibilityPages = true;
    _totalDisponibilityPages = null;
    _isLoadingDisponibilityPontion = true;
    _errorDisponibilityPontion = null;
    notifyListeners();

    // Load first batch
    await _loadDisponibilityBatch(
      destinationId: destinationId,
      dateStart: dateStart,
      dateEnd: dateEnd,
      rooms: rooms,
      batchSize: batchSize,
    );
  }

  // 🔹 Load more disponibility data
  Future<void> loadMoreDisponibility({
    required String destinationId,
    required String dateStart,
    required String dateEnd,
    required List<Map<String, dynamic>> rooms,
    int batchSize = 3,
  }) async {
    if (!_hasMoreDisponibilityPages || _isLoadingDisponibilityPontion) return;

    _isLoadingDisponibilityPontion = true;
    notifyListeners();

    await _loadDisponibilityBatch(
      destinationId: destinationId,
      dateStart: dateStart,
      dateEnd: dateEnd,
      rooms: rooms,
      batchSize: batchSize,
    );
  }

  // 🔹 Internal method to load disponibility batch
  Future<void> _loadDisponibilityBatch({
    required String destinationId,
    required String dateStart,
    required String dateEnd,
    required List<Map<String, dynamic>> rooms,
    int batchSize = 3,
  }) async {
    try {
      List<HotelData> batchData = [];
      int pagesLoaded = 0;

      while (pagesLoaded < batchSize && _hasMoreDisponibilityPages) {
        debugPrint("Loading disponibility page $_currentDisponibilityPage");

        final res = await _apiService.getHotelDisponibilityPontion(
          destinationId: destinationId,
          dateStart: dateStart,
          dateEnd: dateEnd,
          rooms: rooms,
          page: _currentDisponibilityPage,
        );

        // Apply filtering logic
        final filteredHotels = res.data.where((hotel) {
          final dispo = hotel.disponibility;
          final hotelName = hotel.name?.toLowerCase() ?? '';
          bool hasValidPensions = false;

          if (dispo != null && dispo.pensions != null) {
            if (dispo.pensions is List) {
              hasValidPensions = dispo.pensions.isNotEmpty;
            } else if (dispo.pensions is Map) {
              final pensionsMap = dispo.pensions as Map<String, dynamic>;
              hasValidPensions = pensionsMap.containsKey('rooms') &&
                  pensionsMap['rooms'] != null &&
                  (pensionsMap['rooms']['room'] is List
                      ? pensionsMap['rooms']['room'].isNotEmpty
                      : pensionsMap['rooms']['room'] != null);
            }
          }

          return (dispo != null &&
              (dispo.disponibilityType == 'bhr' ||
                  dispo.disponibilityType == 'tgt' ||
                  hotelName.contains('mouradi')));
        }).toList();

        batchData.addAll(filteredHotels);
        _totalDisponibilityPages = res.lastPage;

        if (_currentDisponibilityPage >= res.lastPage || res.data.isEmpty) {
          _hasMoreDisponibilityPages = false;
        }

        _currentDisponibilityPage++;
        pagesLoaded++;
      }

      // Add new data to the main list
      _hotelDisponibilityData.addAll(batchData);

      debugPrint("Loaded ${batchData.length} new disponibility entries. Total: ${_hotelDisponibilityData.length}");

    } catch (e) {
      _errorDisponibilityPontion = e.toString();
      debugPrint("Error loading disponibility batch: $e");
    }

    _isLoadingDisponibilityPontion = false;
    notifyListeners();
  }

  // ======================================================
  // 🔹 HELPER METHODS
  // ======================================================

  // Get current disponibility as HotelAvailabilityResponse for backward compatibility
  HotelAvailabilityResponse? get hotelAvailabilityResponse {
    if (_hotelDisponibilityData.isEmpty) return null;

    return HotelAvailabilityResponse(
      currentPage: _currentDisponibilityPage - 1,
      data: _hotelDisponibilityData,
      lastPage: _totalDisponibilityPages ?? 1,
      nextPageUrl: _hasMoreDisponibilityPages ? "has_more" : null,
    );
  }

  // Reset progressive loading state
  void resetProgressiveLoading() {
    _availableHotels.clear();
    _hotelDisponibilityData.clear();
    _currentAvailablePage = 1;
    _currentDisponibilityPage = 1;
    _hasMoreAvailablePages = true;
    _hasMoreDisponibilityPages = true;
    _targetHotelIds.clear();
    _totalDisponibilityPages = null;
    notifyListeners();
  }
}