import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tunisiagotravel/models/hotelBhr.dart';
import 'package:tunisiagotravel/models/hotelTgt.dart';
import 'package:tunisiagotravel/models/mouradi.dart';
import 'package:tunisiagotravel/screens/hotelBhr_reservation_screen.dart';
import 'package:tunisiagotravel/screens/hotelTgt_reservation_screen.dart';
import 'package:tunisiagotravel/screens/mouradi_reservation_screen.dart';
import 'package:tunisiagotravel/services/api_service.dart';
import 'package:tunisiagotravel/theme/color.dart';

class ItemDetail extends StatefulWidget {
  final Map<String, dynamic> item;
  final DateTime? startDate;
  final List<Map<String, dynamic>>? selectedRooms;
  final int dayIndex;

  const ItemDetail({
    super.key,
    required this.item,
    this.startDate,
    this.selectedRooms,
    required this.dayIndex,
  });

  @override
  State<ItemDetail> createState() => _ItemDetailState();
}

class _ItemDetailState extends State<ItemDetail> {
  bool _isCheckingAvailability = false;
  DateTime? _checkIn;
  DateTime? _checkOut;
  List<Map<String, dynamic>>? _rooms;
  bool _isConfirmed = false;

  @override
  void initState() {
    super.initState();
    _loadDatesAndRooms();
    _loadConfirmation(); // load saved confirmation state
  }

  Future<void> _loadDatesAndRooms() async {
    final prefs = await SharedPreferences.getInstance();

    final savedBaseDate = prefs.getString('manual_start_date');
    final baseDate = savedBaseDate != null
        ? DateTime.tryParse(savedBaseDate)
        : widget.startDate ?? DateTime.now().add(const Duration(days: 1));

    setState(() {
      _checkIn = baseDate?.add(Duration(days: widget.dayIndex));
      _checkOut = _checkIn!.add(const Duration(days: 1));

      final roomsJson = prefs.getString('manual_rooms_data');
      _rooms = widget.selectedRooms ??
          (roomsJson != null
              ? (jsonDecode(roomsJson) as List<dynamic>)
              .map((e) => Map<String, dynamic>.from(e))
              .toList()
              : [
            {"adults": 2, "children": 0, "childAges": []}
          ]);
    });
  }

  // Load saved confirmation state
  Future<void> _loadConfirmation() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'confirmed_${widget.item['id'] ?? widget.item['slug']}';
    final confirmed = prefs.getBool(key) ?? false;
    setState(() {
      _isConfirmed = confirmed;
    });
  }

  // Confirm button handler
  void _confirm() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'confirmed_${widget.item['id'] ?? widget.item['slug']}';
    await prefs.setBool(key, true);

    setState(() {
      _isConfirmed = true;
    });
  }

  Future<void> _saveDatesAndRooms(
      DateTime checkIn, DateTime checkOut, List<Map<String, dynamic>> rooms) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('manual_start_date', checkIn.toIso8601String());
    await prefs.setString('manual_end_date', checkOut.toIso8601String());
    await prefs.setString('manual_rooms_data', jsonEncode(rooms));
  }

  bool _isHotel() =>
      widget.item['category'] == 'hotel' || widget.item['type'] == 'hotel';

  bool _isMouradiHotel() {
    final name = widget.item['Name'] ?? widget.item['name'] ?? '';
    return name.toLowerCase().contains('mouradi');
  }

  Widget _buildInfoRow(String title, String content, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: const Color(0xFF6B7280)),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(content, style: const TextStyle(color: Color(0xFF6B7280))),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildGallery(List<dynamic> images) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          final imgUrl = images[index];
          return Container(
            margin: const EdgeInsets.only(right: 12),
            width: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey.shade200,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imgUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleHotelReservation() async {
    if (!_isHotel()) return;
    setState(() => _isCheckingAvailability = true);

    try {
      final checkIn = _checkIn!;
      final checkOut = _checkOut!;
      final rooms = _rooms!;

      final dateFormat = DateFormat("dd-MM-yyyy");
      final start = dateFormat.format(checkIn);
      final end = dateFormat.format(checkOut);

      final api = ApiService();

      if (_isMouradiHotel()) {
        final mouradiId = widget.item['idHotelMouradi']?.toString();
        final cityId = widget.item['idCityMouradi']?.toString();
        if (mouradiId == null || cityId == null) {
          _showError('Informations manquantes pour cet hôtel Mouradi');
          return;
        }

        final mouradiResponse = await api.showMouradiDisponibility(
          hotelId: mouradiId,
          city: cityId,
          dateStart: DateFormat('yyyy-MM-dd').format(checkIn),
          dateEnd: DateFormat('yyyy-MM-dd').format(checkOut),
          rooms: rooms,
        );

        if (mouradiResponse == null || mouradiResponse.isEmpty) {
          _showError('Aucune disponibilité trouvée pour ces dates');
          return;
        }

        final mouradiHotel = MouradiHotel.fromJson(mouradiResponse);
        final searchCriteria = {
          'dateStart': DateFormat('yyyy-MM-dd').format(checkIn),
          'dateEnd': DateFormat('yyyy-MM-dd').format(checkOut),
          'rooms': rooms,
          'hotelId': mouradiId,
          'cityId': cityId,
        };

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MouradiReservationScreen(
              hotel: mouradiHotel,
              searchCriteria: searchCriteria,
            ),
          ),
        );
        return;
      }

      // BHR / TGT
      final slug = widget.item['slug']?.toString();
      if (slug == null || slug.isEmpty) {
        _showError('Slug manquant pour cet hôtel');
        return;
      }

      final rawResponse = await api.checkDisponibilityRaw(slug, start, end, rooms);
      if (rawResponse == null ||
          (rawResponse.containsKey('pensions') && rawResponse['pensions'].isEmpty)) {
        _showError('Aucune disponibilité trouvée pour ces dates');
        return;
      }

      final searchCriteria = {
        'dateStart': DateFormat('yyyy-MM-dd').format(checkIn),
        'dateEnd': DateFormat('yyyy-MM-dd').format(checkOut),
        'rooms': rooms,
        'hotelSlug': slug,
      };

      if (rawResponse.containsKey('disponibilitytype')) {
        final disponibilityType = rawResponse['disponibilitytype'] as String;
        if (disponibilityType == 'tgt') {
          final hotelTgt = HotelTgt.fromAvailabilityJson(rawResponse, widget.item);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => HotelTgtReservationScreen(
                hotelTgt: hotelTgt,
                searchCriteria: searchCriteria,
              ),
            ),
          );
        } else if (disponibilityType == 'bhr') {
          final hotelBhr = HotelBhr.fromAvailabilityJson(rawResponse, widget.item);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => HotelBhrReservationScreen(
                hotelBhr: hotelBhr,
                allHotels: [],
                searchCriteria: searchCriteria,
              ),
            ),
          );
        }
      } else {
        _showSuccess('Disponibilité trouvée! Veuillez utiliser la recherche détaillée.');
      }
    } catch (e) {
      _showError('Erreur lors de la vérification: $e');
    } finally {
      setState(() => _isCheckingAvailability = false);
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  void _showSuccess(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic>? gallery = widget.item['images'] ?? widget.item['gallery'];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.item['Situation'] != null)
            _buildInfoRow("Situation", widget.item['Situation'], Icons.location_on),
          if (widget.item['Horaires_d_ouverture'] != null)
            _buildInfoRow(
                "Horaires",
                (widget.item['Horaires_d_ouverture'] as List).join(', '),
                Icons.access_time),
          if (widget.item['Droits_d_entre'] != null)
            _buildInfoRow("Tarif", widget.item['Droits_d_entre'], Icons.payments),
          const SizedBox(height: 12),
          if (gallery != null && gallery.isNotEmpty) ...[
            Text(
              "images".tr(),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            _buildGallery(gallery),
          ],
          if (_isHotel()) ...[
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: _isConfirmed ? null : _confirm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isConfirmed ? Colors.grey : AppColorstatic.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _isConfirmed
                      ? tr('reservation_confirmed')
                      : tr('confirm_reservation'),
                  style: const TextStyle(fontSize: 15, color: Colors.white),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
