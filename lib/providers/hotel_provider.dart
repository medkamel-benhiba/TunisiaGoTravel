import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
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
    int maxPages = 20, // Safety limit
  }) async {
    _isLoadingAvailableHotels = true;
    _errorAvailableHotels = null;
    notifyListeners();

    List<Hotel> allHotels = [];
    int page = 1;
    bool hasMorePages = true;

    try {
      while (hasMorePages && page <= maxPages) {
        debugPrint("Fetching available hotels page $page");

        final hotelsPage = await _apiService.getAvailableHotels(
          destinationId: destinationId,
          dateStart: dateStart,
          dateEnd: dateEnd,
          adults: adults,
          rooms: rooms,
          children: children,
          babies: babies,
          page: page,
        );

        if (hotelsPage.isEmpty) {
          hasMorePages = false;
        } else {
          allHotels.addAll(hotelsPage);

          // If less than expected page size, we've reached the end
          if (hotelsPage.length < 10) { // Adjust based on your API's page size
            hasMorePages = false;
          } else {
            page++;
          }
        }
      }

      _availableHotels = allHotels;
      debugPrint("Fetched ${allHotels.length} available hotels across $page pages");
    } catch (e) {
      _errorAvailableHotels = e.toString();
      _availableHotels = [];
      debugPrint("Error fetching all available hotels: $e");
    }

    _isLoadingAvailableHotels = false;
    notifyListeners();
  }

  // ======================================================
  // 🔹 Disponibility avec pontion (pagination) - IMPROVED
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
    int maxPages = 20, // Safety limit
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

        allHotelData.addAll(res.data);
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
  // 🔹 UTILITY METHODS FOR MIXED HOTEL HANDLING
  // ======================================================

  /// Get mixed list of hotels (Hotel + HotelTgt) based on availability
  List<dynamic> getMixedAvailableHotels() {
    List<dynamic> mixedHotels = [];

    // Add regular available hotels
    mixedHotels.addAll(_availableHotels);

    // Add TGT hotels
    mixedHotels.addAll(getTgtHotels());

    return mixedHotels;
  }

  /// Clear all availability data
  void clearAvailabilityData() {
    _availableHotels = [];
    _hotelDisponibilityPontion = null;
    _selectedMouradiHotel = null;
    notifyListeners();
  }
}