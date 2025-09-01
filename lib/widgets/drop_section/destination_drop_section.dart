import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tunisiagotravel/theme/color.dart';
import '../../providers/global_provider.dart';
import '../../providers/hotel_provider.dart';
import '../circuits/city_dropdown.dart';

class DestinationDropSection extends StatefulWidget {
  final Function(Map<String, dynamic>)? onSearchComplete;

  const DestinationDropSection({super.key, this.onSearchComplete});

  @override
  State<DestinationDropSection> createState() => _DestinationDropSectionState();
}

class _DestinationDropSectionState extends State<DestinationDropSection> {
  String? _selectedCityName;
  String? _selectedCityId;
  DateTime? _startDate;
  DateTime? _endDate;

  bool _isVisible = true;

  List<Map<String, int>> roomsData = [
    {"adults": 1, "children": 0},
  ];

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    int totalRooms = roomsData.length;
    int totalAdults = roomsData.fold(0, (sum, room) => sum + room["adults"]!);
    int totalChildren = roomsData.fold(0, (sum, room) => sum + room["children"]!);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // City
              _buildSectionTitle("Destination", Icons.location_on_outlined),
              const SizedBox(height: 8),
              CityDropdown(
                label: "Choisir votre destination",
                onChanged: (name, id) {
                  setState(() {
                    _selectedCityName = name;
                    _selectedCityId = id;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Dates
              _buildSectionTitle("Dates de Voyage", Icons.calendar_today),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildDateInput(
                      context,
                      "Date début",
                      _startDate,
                          (picked) => setState(() => _startDate = picked),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDateInput(
                      context,
                      "Date fin",
                      _endDate,
                          (picked) => setState(() => _endDate = picked),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Rooms summary
              _buildSectionTitle("Voyageurs", Icons.group_outlined),
              const SizedBox(height: 8),
              _buildGuestSummary(totalRooms, totalAdults, totalChildren),
              const SizedBox(height: 16),

              // Search button
              Consumer<HotelProvider>(
                builder: (context, hotelProvider, child) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColorstatic.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    onPressed: hotelProvider.isLoadingAvailableHotels || hotelProvider.isLoadingDisponibilityPontion
                        ? null
                        : () async {
                      if (_selectedCityId == null || _startDate == null || _endDate == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Veuillez remplir tous les champs!'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }

                      try {
                        final globalProvider = Provider.of<GlobalProvider>(context, listen: false);

                        // Format dates
                        final dateStart = "${_startDate!.day.toString().padLeft(2, '0')}-${_startDate!.month.toString().padLeft(2, '0')}-${_startDate!.year}";
                        final dateEnd = "${_endDate!.day.toString().padLeft(2, '0')}-${_endDate!.month.toString().padLeft(2, '0')}-${_endDate!.year}";

                        List<Map<String, dynamic>> roomsForApi = roomsData.map((room) => {
                          'adults': room['adults'],
                          'children': room['children'],
                        }).toList();

                        final searchCriteria = {
                          'destinationId': _selectedCityId!,
                          'destinationName': _selectedCityName,
                          'dateStart': dateStart,
                          'dateEnd': dateEnd,
                          'adults': totalAdults.toString(),
                          'rooms': roomsForApi,
                          'children': totalChildren.toString(),
                        };

                        // Update GlobalProvider
                        globalProvider.setSearchCriteria(searchCriteria);
                        globalProvider.setSelectedCityForHotels(_selectedCityName);

                        // Fetch hotels
                        await Future.wait([
                          hotelProvider.fetchAllAvailableHotels(
                            destinationId: _selectedCityId!,
                            dateStart: dateStart,
                            dateEnd: dateEnd,
                            adults: totalAdults.toString(),
                            rooms: totalRooms.toString(),
                            children: totalChildren.toString(),
                          ),
                          hotelProvider.fetchAllHotelDisponibilityPontion(
                            destinationId: _selectedCityId!,
                            dateStart: dateStart,
                            dateEnd: dateEnd,
                            rooms: roomsForApi,
                          ),
                        ]);

                        // Hide the section
                        setState(() => _isVisible = false);

                        // **Close the dialog via the callback**
                        if (widget.onSearchComplete != null) {
                          widget.onSearchComplete!(searchCriteria);
                        }

                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Erreur lors de la recherche: $e")),
                        );
                      }
                    },
                    child: hotelProvider.isLoadingAvailableHotels || hotelProvider.isLoadingDisponibilityPontion
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : const Text(
                      "Rechercher",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widgets ---
  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColorstatic.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildDateInput(BuildContext context, String label, DateTime? date, Function(DateTime) onDatePicked) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2100),
        );
        if (picked != null) onDatePicked(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_month, color: Colors.grey.shade600, size: 18),
            const SizedBox(width: 8),
            Text(
              date == null ? label : date.toString().split(" ")[0],
              style: TextStyle(
                color: date == null ? Colors.grey[600] : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuestSummary(int rooms, int adults, int children) {
    return InkWell(
      onTap: () => _openRoomSelectionBottomSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.person_pin, color: Colors.grey.shade600, size: 18),
            const SizedBox(width: 8),
            Text(
              "$rooms Chambre${rooms > 1 ? 's' : ''}",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const Text(" • ", style: TextStyle(color: Colors.grey)),
            Text(
              "$adults Adulte${adults > 1 ? 's' : ''}",
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            if (children > 0) ...[
              const Text(" • ", style: TextStyle(color: Colors.grey)),
              Text(
                "$children Enfant${children > 1 ? 's' : ''}",
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // --- Room selection bottom sheet remains unchanged ---
  void _openRoomSelectionBottomSheet(BuildContext context) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Sélectionner les chambres", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
                        IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.pop(context)),
                      ],
                    ),
                    const Divider(height: 24),
                    Expanded(
                      child: ListView.builder(
                        itemCount: roomsData.length,
                        itemBuilder: (context, index) {
                          final room = roomsData[index];
                          return _buildRoomCard(context, index, room, setModalState);
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildFooter(context, setModalState),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (result != null) {
      setState(() => roomsData = List<Map<String, int>>.from(result));
    }
  }

  Widget _buildRoomCard(BuildContext context, int index, Map room, Function setModalState) {
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
                Text("Chambre ${index + 1}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                if (roomsData.length > 1)
                  IconButton(icon: const Icon(Icons.delete, color: Colors.redAccent), onPressed: () => setModalState(() => roomsData.removeAt(index))),
              ],
            ),
            const Divider(height: 16),
            _buildCounterRow(
              icon: Icons.person_outline,
              label: "Adultes",
              count: room["adults"],
              onIncrement: () => setModalState(() => room["adults"] < 5 ? room["adults"]++ : null),
              onDecrement: () => setModalState(() => room["adults"] > 1 ? room["adults"]-- : null),
            ),
            _buildCounterRow(
              icon: Icons.child_friendly,
              label: "Enfants",
              count: room["children"],
              onIncrement: () => setModalState(() => room["children"] < 5 ? room["children"]++ : null),
              onDecrement: () => setModalState(() => room["children"] > 0 ? room["children"]-- : null),
            ),
          ],
        ),
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
            child: Text(
              label,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
          ),
          Row(
            children: [
              _buildCounterButton(
                  icon: Icons.remove, onPressed: onDecrement),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  count.toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
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

  Widget _buildFooter(BuildContext context, Function setModalState) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              setModalState(() {
                roomsData.add({"adults": 2, "children": 0});
              });
            },
            icon: const Icon(Icons.add_circle_outline, color: AppColorstatic.lightTextColor),
            label: const Text("Ajouter une chambre",style: TextStyle(color: AppColorstatic.lightTextColor),),
            style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: AppColorstatic.primary2
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              Navigator.pop(context, roomsData);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text("Terminer"),
          ),
        ),
      ],
    );
  }
}