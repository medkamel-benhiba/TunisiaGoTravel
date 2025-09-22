import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tunisiagotravel/models/hotelBhr.dart';
import 'package:tunisiagotravel/models/hotelTgt.dart';
import 'package:tunisiagotravel/models/mouradi.dart';
import 'package:tunisiagotravel/services/Bhr_reservation_calcul.dart';
import 'package:tunisiagotravel/services/Tgt_reservation_calcul.dart';
import 'package:tunisiagotravel/services/api_service.dart';
import 'package:tunisiagotravel/theme/color.dart';
import 'package:tunisiagotravel/widgets/circuits/Dialog_bhr_reservation.dart';
import 'package:tunisiagotravel/widgets/circuits/Dialog_tgt_reservation.dart';
import 'package:tunisiagotravel/widgets/reservation/boarding_selection.dart';

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
  bool _availabilityChecked = false;
  DateTime? _checkIn;
  DateTime? _checkOut;
  List<Map<String, dynamic>>? _rooms;
  bool _isConfirmed = false;

  // Hotel availability data
  MouradiHotel? _mouradiHotel;
  HotelBhr? _hotelBhr;
  HotelTgt? _hotelTgt;
  Map<String, dynamic>? _searchCriteria;

  // Room selections for each hotel type
  Map<int, Map<String, int>> _selectedRoomsByBoarding = {};
  Map<String, Map<String, int>> _selectedRoomsByPension = {};

  int get _totalSelectedRooms {
    if (_mouradiHotel != null) {
      return _selectedRoomsByBoarding.values
          .expand((rooms) => rooms.values)
          .fold(0, (sum, qty) => sum + qty);
    } else if (_hotelBhr != null) {
      return BhrReservationCalculator.getTotalSelectedRooms(_selectedRoomsByPension);
    } else if (_hotelTgt != null) {
      return TgtReservationCalculator.getTotalSelectedRooms(_selectedRoomsByPension);
    }
    return 0;
  }

  double get _totalPrice {
    if (_hotelTgt != null && _searchCriteria != null) {
      return TgtReservationCalculator.calculateTotal(
        _selectedRoomsByPension,
        _hotelTgt!.disponibility.pensions,
        _searchCriteria!,
      );
    } else if (_hotelBhr != null && _searchCriteria != null) {
      return BhrReservationCalculator.calculateTotal(
        _selectedRoomsByPension,
        _hotelBhr!.disponibility.rooms,
      );
    }
    return 0.0;
  }

  @override
  void initState() {
    super.initState();
    _loadDatesAndRooms();
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

  Future<void> _saveDatesAndRooms(DateTime checkIn, DateTime checkOut, List<Map<String, dynamic>> rooms) async {
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

        setState(() {
          _mouradiHotel = mouradiHotel;
          _searchCriteria = searchCriteria;
          _availabilityChecked = true;
        });
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
        'checkIn': DateFormat('yyyy-MM-dd').format(checkIn),
        'checkOut': DateFormat('yyyy-MM-dd').format(checkOut),
        'rooms': rooms,
        'hotelSlug': slug,
      };

      if (rawResponse.containsKey('disponibilitytype')) {
        final disponibilityType = rawResponse['disponibilitytype'] as String;
        if (disponibilityType == 'tgt') {
          final hotelTgt = HotelTgt.fromAvailabilityJson(rawResponse, widget.item);
          setState(() {
            _hotelTgt = hotelTgt;
            _searchCriteria = searchCriteria;
            _availabilityChecked = true;
            // Initialize pension maps
            for (var pension in hotelTgt.disponibility.pensions) {
              _selectedRoomsByPension[pension.id] = {};
            }
          });
          print("DEBUG → SearchCriteria (TGT): $_searchCriteria");

        } else if (disponibilityType == 'bhr') {
          final hotelBhr = HotelBhr.fromAvailabilityJson(rawResponse, widget.item);
          setState(() {
            _hotelBhr = hotelBhr;
            _searchCriteria = searchCriteria;
            _availabilityChecked = true;
            // Initialize pension maps for BHR
            for (var room in hotelBhr.disponibility.rooms) {
              for (var boarding in room.boardings) {
                if (!_selectedRoomsByPension.containsKey(boarding.id)) {
                  _selectedRoomsByPension[boarding.id] = {};
                }
              }
            }
          });
          print("DEBUG → SearchCriteria (BHR): $_searchCriteria");
        }
      } else {
        _showSuccess('Disponibilité trouvée! Veuillez utiliser la recherche détaillée.');
        setState(() {
          _availabilityChecked = true;
        });
      }
    } catch (e) {
      _showError('Erreur lors de la vérification: $e');
    } finally {
      setState(() => _isCheckingAvailability = false);
    }
  }

  // Room selection handlers for each hotel type
  void _handleMouradiRoomUpdate(int boardingId, int paxAdults, int roomId, int qty) {
    setState(() {
      if (!_selectedRoomsByBoarding.containsKey(boardingId)) {
        _selectedRoomsByBoarding[boardingId] = {};
      }
      final roomKey = '${paxAdults}_$roomId';
      _selectedRoomsByBoarding[boardingId]![roomKey] = qty;

      // Remove empty entries
      if (qty == 0) {
        _selectedRoomsByBoarding[boardingId]!.remove(roomKey);
        if (_selectedRoomsByBoarding[boardingId]!.isEmpty) {
          _selectedRoomsByBoarding.remove(boardingId);
        }
      }
    });
  }

  void _proceedToReservation() {
    if (_totalSelectedRooms == 0) {
      _showError('select_at_least_one_room'.tr());
      return;
    }

    if (_mouradiHotel != null) {
      // Handle Mouradi reservation
    } else if (_hotelBhr != null) {
      // Handle BHR reservation
      final selectedData = BhrReservationCalculator.prepareSelectedRoomsData(
        _selectedRoomsByPension,
        _hotelBhr!.disponibility.rooms,
      );
      print("BHR Selected Rooms: ${selectedData['selectedRoomsSummary']}");
      print("BHR Total Price: ${_totalPrice.toStringAsFixed(2)} TND");
    } else if (_hotelTgt != null) {
      // Handle TGT reservation
    }

    // Navigate to confirmation or payment
    _showSuccess('reservation_confirmed_message'.tr());
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

  Widget _buildRoomSelectionSection() {
    if (_mouradiHotel != null) {
      return Column(
        children: [
          const SizedBox(height: 16),
          BoardingRoomSelection(
            boardings: _mouradiHotel!.boardings,
            selectedRoomsByBoarding: _selectedRoomsByBoarding,
            maxRooms: _rooms?.length ?? 1,
            totalSelected: _totalSelectedRooms,
            onUpdate: _handleMouradiRoomUpdate,
          ),
          const SizedBox(height: 16),
          _buildReservationButton(),
        ],
      );
    } else if (_hotelBhr != null) {
      return Column(
        children: [
          const SizedBox(height: 16),
          _buildBhrRoomSelectionButton(),
          if (_totalSelectedRooms > 0) ...[
            const SizedBox(height: 12),
            _buildBhrSelectionSummary(),
          ],
          const SizedBox(height: 16),
          _buildReservationButton(),
        ],
      );
    } else if (_hotelTgt != null) {
      return Column(
        children: [
          const SizedBox(height: 16),
          _buildTgtRoomSelectionButton(),
          if (_totalSelectedRooms > 0) ...[
            const SizedBox(height: 12),
            _buildTgtSelectionSummary(),
          ],
          const SizedBox(height: 16),
          _buildReservationButton(),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  // BHR Room Selection Button
  Widget _buildBhrRoomSelectionButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton.icon(
        onPressed: () => _showBhrRoomSelectionDialog(),
        icon: const Icon(Icons.hotel, color: Colors.white),
        label: Text(
          _totalSelectedRooms > 0
              ? tr('edit_select_rooms', args: [_totalSelectedRooms.toString()])
              : tr('select_rooms_default'),
          style: const TextStyle(color: Colors.white, fontSize: 15),
          textAlign: TextAlign.center,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColorstatic.primary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // BHR Selection Summary
  Widget _buildBhrSelectionSummary() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColorstatic.primary.withOpacity(0.1),
            AppColorstatic.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColorstatic.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: AppColorstatic.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'selection_confirmed',
                style: TextStyle(
                  color: AppColorstatic.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'selected_rooms'.tr(),
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    tr('room_count', args: [_totalSelectedRooms.toString()]),
                    style: TextStyle(
                      color: AppColorstatic.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  )
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    tr('total_price_label'),
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    tr('total_price_value', args: [_totalPrice.toStringAsFixed(2)]),
                    style: TextStyle(
                      color: AppColorstatic.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // BHR Room Selection Dialog
  Future<void> _showBhrRoomSelectionDialog() async {
    if (_hotelBhr == null || _searchCriteria == null) return;

    await BhrBoardingRoomDialog.show(
      context: context,
      rooms: _hotelBhr!.disponibility.rooms,
      searchCriteria: _searchCriteria!,
      initialSelection: _selectedRoomsByPension,
      onConfirm: (selectedRooms, total) {
        setState(() {
          _selectedRoomsByPension = selectedRooms;
        });

        // Show success feedback
        _showSuccess(
          tr(
            'selection_updated',
            args: [
              BhrReservationCalculator.getTotalSelectedRooms(selectedRooms).toString(),
              total.toStringAsFixed(2)
            ],
          ),
        );
      },
    );
  }

  // TGT Room Selection Button
  Widget _buildTgtRoomSelectionButton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton.icon(
        onPressed: () => _showTgtRoomSelectionDialog(),
        icon: const Icon(Icons.hotel, color: Colors.white),
        label: Text(
          _totalSelectedRooms > 0
              ? tr('edit_select_rooms', args: [_totalSelectedRooms.toString()])
              : tr('select_rooms_default'),
          style: const TextStyle(color: Colors.white, fontSize: 15),
          textAlign: TextAlign.center,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColorstatic.primary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // TGT Selection Summary (existing)
  Widget _buildTgtSelectionSummary() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColorstatic.primary.withOpacity(0.1),
            AppColorstatic.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColorstatic.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: AppColorstatic.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                tr('selection_confirmed'),
                style: TextStyle(
                  color: AppColorstatic.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr('selected_rooms'),
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    tr('room_count', args: [_totalSelectedRooms.toString()]),
                    style: TextStyle(
                      color: AppColorstatic.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  )
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    tr('total_price_label'),
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    tr('total_price_value', args: [_totalPrice.toStringAsFixed(2)]),
                    style: TextStyle(
                      color: AppColorstatic.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showTgtRoomSelectionDialog() async {
    if (_hotelTgt == null || _searchCriteria == null) return;

    await TgtBoardingRoomDialog.show(
      context: context,
      pensions: _hotelTgt!.disponibility.pensions,
      searchCriteria: _searchCriteria!,
      initialSelection: _selectedRoomsByPension,
      onConfirm: (selectedRooms, total) {
        setState(() {
          _selectedRoomsByPension = selectedRooms;
        });

        // Show success feedback
        _showSuccess(
          tr(
            'selection_updated',
            args: [
              TgtReservationCalculator.getTotalSelectedRooms(selectedRooms).toString(),
              total.toStringAsFixed(2)
            ],
          ),
        );
      },
    );
  }

  Widget _buildReservationButton() {
    final bool hasRooms = _totalSelectedRooms > 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: hasRooms && !_isConfirmed
            ? () {
          setState(() {
            _isConfirmed = true;
          });
          _proceedToReservation();
        }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isConfirmed
              ? Colors.grey
              : (hasRooms ? AppColorstatic.primary : Colors.grey),
          disabledBackgroundColor: Colors.grey,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isConfirmed) ...[
              const Icon(Icons.check, color: Colors.white, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              _isConfirmed
                  ? tr('confirmed')
                  : tr('confirm'),
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            )
          ],
        ),
      ),
    );
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
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            _buildGallery(gallery),
          ],
          if (_isHotel()) ...[
            const SizedBox(height: 16),
            if (!_availabilityChecked)
              Center(
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: ElevatedButton(
                    onPressed: _isCheckingAvailability ? null : _handleHotelReservation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColorstatic.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isCheckingAvailability
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : const Text(
                      "Vérifier la disponibilité",
                      style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
            if (_availabilityChecked) _buildRoomSelectionSection(),
          ],
        ],
      ),
    );
  }
}