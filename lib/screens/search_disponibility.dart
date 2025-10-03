import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../models/hotel_details.dart';
import '../models/hotelAvailabilityResponse.dart';
import '../models/hotelTgt.dart';
import '../models/hotelBhr.dart';
import '../models/mouradi.dart';
import '../services/api_service.dart';
import '../theme/color.dart';
import 'hotelTgt_reservation_screen.dart';
import 'hotelBhr_reservation_screen.dart';
import 'mouradi_reservation_screen.dart';

class SearchDisponibilityScreen extends StatefulWidget {
  final HotelDetail hotel;

  const SearchDisponibilityScreen({super.key, required this.hotel});

  @override
  State<SearchDisponibilityScreen> createState() =>
      _SearchDisponibilityScreenState();
}

class _SearchDisponibilityScreenState extends State<SearchDisponibilityScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  List<Map<String, dynamic>> _rooms = [
    {"adults": 2, "children": 0, "childAges": []},
  ];
  bool _isLoading = false;
  List<Disponibility> _results = [];

  // --- Date Picker ---
  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? DateTime.now().add(const Duration(days: 1))
          : _startDate != null
          ? _startDate!.add(const Duration(days: 1))
          : DateTime.now().add(const Duration(days: 1)),
      firstDate: isStart
          ? DateTime.now()
          : _startDate != null
          ? _startDate!.add(const Duration(days: 1))
          : DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    print("picked: $picked");
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          print("_startDate set: $_startDate");
          if (_endDate != null && _endDate!.isBefore(picked)) {
            _endDate = null;
          }
        } else {
          _endDate = picked;
          print("_endDate set: $_endDate");
          if (_startDate != null && _startDate!.isAfter(picked)) {
            _startDate = null;
          }
        }
      });
    }
  }

  // --- Helper method to check if hotel is Mouradi ---
  bool _isMouradiHotel() {
    return widget.hotel.name?.toLowerCase().contains('mouradi') ?? false;
  }

  // --- Updated Search API Call with Navigation Logic ---
  Future<void> _searchDisponibility() async {
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('no_date_selected_snackbar'.tr())),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _results.clear();
    });

    try {
      final dateFormat = DateFormat("dd-MM-yyyy");
      final start = dateFormat.format(_startDate!);
      final end = dateFormat.format(_endDate!);

      final api = ApiService();

      // Check if this is a Mouradi hotel
      if (_isMouradiHotel()) {
        // Call Mouradi-specific API
        final mouradiResponse = await api.showMouradiDisponibility(
          hotelId: widget.hotel.idHotelMouradi ?? "",
          city: widget.hotel.idCityMouradi ?? "",
          dateStart: DateFormat('yyyy-MM-dd').format(_startDate!),
          dateEnd: DateFormat('yyyy-MM-dd').format(_endDate!),
          rooms: _rooms,
        );

        // Check for empty response
        if (mouradiResponse == null || mouradiResponse.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('no_availability_snackbar'.tr()),
            ),
          );
          return;
        }

        // Convert the API response to MouradiHotel model
        try {
          final mouradiHotel = MouradiHotel.fromJson(mouradiResponse);

          // Prepare search criteria for the reservation screen
          final searchCriteria = {
            'dateStart': DateFormat('yyyy-MM-dd').format(_startDate!),
            'dateEnd': DateFormat('yyyy-MM-dd').format(_endDate!),
            'rooms': _rooms,
            'hotelId': widget.hotel.idHotelMouradi,
            'cityId': widget.hotel.idCityMouradi,
          };

          // Navigate to Mouradi reservation screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MouradiReservationScreen(
                hotel: mouradiHotel,
                searchCriteria: searchCriteria,
              ),
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("${'error_processing_data_snackbar'.tr()} $e"),
            ),
          );
        }

        return; // Important: return here to prevent further execution
      }

      // Regular hotel availability check
      final rawResponse = await api.checkDisponibilityRaw(
        widget.hotel.slug ?? "",
        start,
        end,
        _rooms,
      );

      // Check for empty response
      if (rawResponse != null && rawResponse['pensions'].isEmpty) {
        // Display the snackbar for no availability
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('no_availability_snackbar'.tr()),
          ),
        );
        return;
      }

      if (rawResponse != null && rawResponse.containsKey('disponibilitytype')) {
        final disponibilityType = rawResponse['disponibilitytype'] as String;

        final searchCriteria = {
          'dateStart': DateFormat('yyyy-MM-dd').format(_startDate!),
          'dateEnd': DateFormat('yyyy-MM-dd').format(_endDate!),
          'rooms': _rooms,
          'hotelSlug': widget.hotel.slug,
        };

        if (disponibilityType == 'tgt') {
          final hotelTgt =
          HotelTgt.fromAvailabilityJson(rawResponse, widget.hotel);

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HotelTgtReservationScreen(
                hotelTgt: hotelTgt,
                searchCriteria: searchCriteria,
              ),
            ),
          );
        } else if (disponibilityType == 'bhr') {
          final hotelBhr = HotelBhr.fromAvailabilityJson(
            rawResponse,
            widget.hotel,
            idHotelBbx: widget.hotel.idHotelBbx,
          );

          print("hotelBhr: $hotelBhr");
          print("✅ Parsed BHR hotel ID: ${hotelBhr.id}");
          print("Name: ${hotelBhr.name}");
          print("id: ${hotelBhr.id}");
          print("idbbx: ${hotelBhr.id_hotel_bbx}");

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HotelBhrReservationScreen(
                hotelBhr: hotelBhr,
                allHotels: [],
                searchCriteria: searchCriteria,
              ),
            ),
          );
        } else {
          final results = await api.checkdispo(
            widget.hotel.slug ?? "",
            start,
            end,
            _rooms,
          );
          setState(() => _results = results);
        }
      } else {
        final results = await api.checkdispo(
          widget.hotel.slug ?? "",
          start,
          end,
          _rooms,
        );
        setState(() => _results = results);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${'error_general_snackbar'.tr()} $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // --- Bottom Sheet ---
  void _openRoomSelectionBottomSheet() async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RoomSelectionBottomSheet(
        rooms: _rooms,
      ),
    );

    if (result != null) {
      setState(() => _rooms = List<Map<String, dynamic>>.from(result));
    }
  }

  // --- Helper Widgets ---
  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColorstatic.buttonbg, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColorstatic.mainColor),
        ),
      ],
    );
  }

  Widget _buildDateInput(
      BuildContext context,
      String label,
      DateTime? date,
      VoidCallback onTap,
      ) {
    final dateFormat = DateFormat('dd MMM yyyy');
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today,
                size: 14, color: AppColorstatic.primary2),
            const SizedBox(width: 5),
            Text(
              date == null ? label : dateFormat.format(date),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: date == null ? Colors.black : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.locale;
    int totalRooms = _rooms.length;
    int totalAdults =
    _rooms.fold(0, (sum, room) => sum + (room["adults"] as int));
    int totalChildren =
    _rooms.fold(0, (sum, room) => sum + (room["children"] as int));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${'search_disponibility_screen_title'.tr()} ${widget.hotel.getName(locale)}",
          style: TextStyle(
            color: AppColorstatic.lightTextColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColorstatic.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14.0),
        child: Card(
          elevation: 4,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Section: Dates de Voyage
                _buildSectionTitle('travel_dates_section_title'.tr(),
                    Icons.calendar_today),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildDateInput(
                        context,
                        'start_date_label'.tr(),
                        _startDate,
                            () => _selectDate(context, true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDateInput(
                        context,
                        'end_date_label'.tr(),
                        _endDate,
                            () => _selectDate(context, false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Section: Voyageurs
                _buildSectionTitle(
                    'guests_section_title'.tr(), Icons.group_outlined),
                const SizedBox(height: 8),
                _buildGuestSummary(totalRooms, totalAdults, totalChildren,
                    _openRoomSelectionBottomSheet),
                const SizedBox(height: 16),

                // Search Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _searchDisponibility,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColorstatic.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                      : Text(
                    'search_button'.tr(),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Guest summary widget
  Widget _buildGuestSummary(
      int totalRooms, int totalAdults, int totalChildren, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.person_pin, color: AppColorstatic.primary2, size: 16),
            const SizedBox(width: 4),
            Text(
              "$totalRooms ${totalRooms > 1 ? 'rooms_label'.tr() : 'room_label'.tr()}",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const Text(" • ", style: TextStyle(color: Colors.grey)),
            Text(
              "$totalAdults ${totalAdults > 1 ? 'adults_label'.tr() : 'adult_label'.tr()}",
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            if (totalChildren > 0) ...[
              const Text(" • ", style: TextStyle(color: Colors.grey)),
              Text(
                "$totalChildren ${totalChildren > 1 ? 'children_label'.tr() : 'child_label'.tr()}",
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
            const Spacer(),
            Icon(Icons.edit, color: Colors.blueAccent, size: 16),
          ],
        ),
      ),
    );
  }
}

// ------------------------ WIDGETS (as they are) ------------------------

class DatePickers extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final VoidCallback onStartTap;
  final VoidCallback onEndTap;

  const DatePickers({
    super.key,
    required this.startDate,
    required this.endDate,
    required this.onStartTap,
    required this.onEndTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onStartTap,
            child: Text(startDate == null
                ? 'start_date_label'.tr()
                : DateFormat("dd/MM/yyyy").format(startDate!)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: onEndTap,
            child: Text(endDate == null
                ? 'end_date_label'.tr()
                : DateFormat("dd/MM/yyyy").format(endDate!)),
          ),
        ),
      ],
    );
  }
}

class GuestSummary extends StatelessWidget {
  final int totalRooms;
  final int totalAdults;
  final int totalChildren;
  final VoidCallback onTap;

  const GuestSummary({
    super.key,
    required this.totalRooms,
    required this.totalAdults,
    required this.totalChildren,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.person_pin, color: Colors.grey.shade600, size: 16),
            const SizedBox(width: 8),
            Text(
                "$totalRooms ${totalRooms > 1 ? 'rooms_label'.tr() : 'room_label'.tr()}",
                style: const TextStyle(fontWeight: FontWeight.w600)),
            const Text(" • ", style: TextStyle(color: Colors.grey)),
            Text(
                "$totalAdults ${totalAdults > 1 ? 'adults_label'.tr() : 'adult_label'.tr()}",
                style: const TextStyle(fontWeight: FontWeight.w500)),
            if (totalChildren > 0) ...[
              const Text(" • ", style: TextStyle(color: Colors.grey)),
              Text(
                  "$totalChildren ${totalChildren > 1 ? 'children_label'.tr() : 'child_label'.tr()}",
                  style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ],
        ),
      ),
    );
  }
}

class RoomSelectionBottomSheet extends StatefulWidget {
  final List<Map<String, dynamic>> rooms;

  const RoomSelectionBottomSheet({super.key, required this.rooms});

  @override
  State<RoomSelectionBottomSheet> createState() =>
      _RoomSelectionBottomSheetState();
}

class _RoomSelectionBottomSheetState extends State<RoomSelectionBottomSheet> {
  late List<Map<String, dynamic>> _rooms;

  @override
  void initState() {
    super.initState();
    _rooms = List<Map<String, dynamic>>.from(widget.rooms);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'select_rooms_title'.tr(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(height: 24),
            Expanded(
              child: ListView.builder(
                itemCount: _rooms.length,
                itemBuilder: (context, index) {
                  final room = _rooms[index];
                  return _buildRoomCard(context, index, room);
                },
              ),
            ),
            const SizedBox(height: 16),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomCard(
      BuildContext context, int index, Map<String, dynamic> room) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${'room_label'.tr()} ${index + 1}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (_rooms.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => setState(() => _rooms.removeAt(index)),
                  ),
              ],
            ),
            const Divider(height: 16),
            _buildCounterRow(
              icon: Icons.person_outline,
              label: 'adults_label'.tr(),
              count: room["adults"] as int,
              onIncrement: () {
                setState(() {
                  if ((room["adults"] as int) < 5) room["adults"]++;
                });
              },
              onDecrement: () {
                setState(() {
                  if ((room["adults"] as int) > 1) room["adults"]--;
                });
              },
            ),
            _buildCounterRow(
              icon: Icons.child_friendly,
              label: 'children_label'.tr(),
              count: room["children"] as int,
              onIncrement: () {
                setState(() {
                  if ((room["children"] as int) < 5) {
                    room["children"]++;
                    List<int> childAges =
                    List<int>.from(room["childAges"] ?? []);
                    childAges.add(2);
                    room["childAges"] = childAges;
                  }
                });
              },
              onDecrement: () {
                setState(() {
                  if ((room["children"] as int) > 0) {
                    room["children"]--;
                    List<int> childAges =
                    List<int>.from(room["childAges"] ?? []);
                    if (childAges.isNotEmpty) childAges.removeLast();
                    room["childAges"] = childAges;
                  }
                });
              },
            ),
            if ((room["children"] as int) > 0)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: _buildChildAgeSelectors(room),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildAgeSelectors(Map<String, dynamic> room) {
    int childrenCount = room["children"] as int;
    List<int> childAges = List<int>.from(room["childAges"] ?? []);

    while (childAges.length < childrenCount) childAges.add(2);
    while (childAges.length > childrenCount) childAges.removeLast();
    room["childAges"] = childAges;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.cake, color: Colors.orange.shade600, size: 18),
              const SizedBox(width: 8),
              Text(
                'child_age_label'.tr(),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: List.generate(childrenCount, (childIndex) {
              return SizedBox(
                width: 70,
                child: Column(
                  children: [
                    Text(
                      "${'child_label_with_number'.tr()} ${childIndex + 1}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: childAges[childIndex],
                          isDense: true,
                          isExpanded: true,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          items: List.generate(12, (index) {
                            final age = index + 1; // start from 1
                            return DropdownMenuItem<int>(
                              value: age,
                              child: Text(
                                "$age",
                                style: const TextStyle(fontSize: 13),
                              ),
                            );
                          }),
                          onChanged: (int? newAge) {
                            if (newAge != null) {
                              setState(() {
                                childAges[childIndex] = newAge;
                                room["childAges"] = childAges;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCounterRow({
    required IconData icon,
    required String label,
    required int count,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blueAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: const TextStyle(fontSize: 15, color: Colors.black87)),
          ),
          Row(
            children: [
              _buildCounterButton(icon: Icons.remove, onPressed: onDecrement),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  count.toString(),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              _buildCounterButton(icon: Icons.add, onPressed: onIncrement),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCounterButton(
      {required IconData icon, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColorstatic.white80,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColorstatic.primary2),
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _rooms.add(
                    {"adults": 2, "children": 0, "childAges": <int>[]});
              });
            },
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
            label: Text('add_room_button'.tr(),
                style: const TextStyle(color: Colors.white)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              backgroundColor: AppColorstatic.primary2,
              side: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context, _rooms),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('done_button'.tr()),
          ),
        ),
      ],
    );
  }
}