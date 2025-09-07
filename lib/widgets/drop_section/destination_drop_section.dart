import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tunisiagotravel/theme/color.dart';
import 'package:tunisiagotravel/widgets/circuits/city_dropdown.dart';
import '../../providers/global_provider.dart';
import '../../providers/hotel_provider.dart';

class DestinationDropSection extends StatefulWidget {
  const DestinationDropSection({super.key});

  @override
  State<DestinationDropSection> createState() => _DestinationDropSectionState();
}

class _DestinationDropSectionState extends State<DestinationDropSection> {
  String? _selectedCityName;
  String? _selectedCityId;
  DateTime? _startDate;
  DateTime? _endDate;

  bool _isVisible = true; // Flag pour masquer la section après recherche

  // Updated room data structure to include child ages
  List<Map<String, dynamic>> roomsData = [
    {
      "adults": 2,
      "children": 0,
      "childAges": <int>[] // List of child ages for this room
    }, // Default room
  ];

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    int totalRooms = roomsData.length;
    int totalAdults = roomsData.fold(0, (sum, room) => sum + (room["adults"] as int));
    int totalChildren = roomsData.fold(0, (sum, room) => sum + (room["children"] as int));

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
              // City dropdown
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

              // Date pickers
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

              // Room/Adults/Children summary
              _buildSectionTitle("Voyageurs", Icons.group_outlined),
              const SizedBox(height: 8),
              _buildGuestSummary(totalRooms, totalAdults, totalChildren),
              const SizedBox(height: 16),

              // Validate button
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

                      // Validate child ages
                      bool hasIncompleteChildAges = false;
                      for (var room in roomsData) {
                        int children = room['children'] as int;
                        List<int> childAges = List<int>.from(room['childAges'] ?? []);
                        if (children > 0 && childAges.length != children) {
                          hasIncompleteChildAges = true;
                          break;
                        }
                      }

                      if (hasIncompleteChildAges) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Veuillez sélectionner l\'âge de tous les enfants!'),
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

                        // Prepare rooms data for disponibility pention
                        List<Map<String, dynamic>> roomsForApi = roomsData.map((room) => {
                          'adults': room['adults'],
                          'children': room['children'],
                          'childAges': room['childAges'],
                        }).toList();

                        // Store search criteria
                        final searchCriteria = {
                          'destinationId': _selectedCityId!,
                          'destinationName': _selectedCityName,
                          'dateStart': dateStart,
                          'dateEnd': dateEnd,
                          'adults': totalAdults.toString(),
                          'rooms': roomsForApi,
                          'children': totalChildren.toString(),
                          'roomsCount': totalRooms.toString(),
                        };

                        globalProvider.setSearchCriteria(searchCriteria);

                        // Fetch detailed availability first to get filtered hotel IDs
                        await hotelProvider.fetchAllHotelDisponibilityPontion(
                          destinationId: _selectedCityId!,
                          dateStart: dateStart,
                          dateEnd: dateEnd,
                          rooms: roomsForApi,
                        );

                        // Get filtered hotel IDs
                        final filteredHotelIds = hotelProvider.hotelDisponibilityPontion?.data.map((hotel) => hotel.id).toList() ?? [];

                        // Fetch simple availability, passing filtered IDs
                        await hotelProvider.fetchAllAvailableHotels(
                          destinationId: _selectedCityId!,
                          dateStart: dateStart,
                          dateEnd: dateEnd,
                          adults: totalAdults.toString(),
                          rooms: totalRooms.toString(),
                          children: totalChildren.toString(),
                          filteredHotelIds: filteredHotelIds,
                        );

                        // Debug prints
                        print("DEBUG - Simple hotels fetched: ${hotelProvider.availableHotels.length}");
                        print("DEBUG - Pension hotels fetched: ${hotelProvider.hotelDisponibilityPontion?.data.length ?? 0}");

                        // Update GlobalProvider with filtered simple hotels for listing
                        globalProvider.setSelectedCityForHotels(_selectedCityName);
                        globalProvider.setAvailableHotels(hotelProvider.availableHotels);

                        // Hide the section after search
                        setState(() {
                          _isVisible = false;
                        });

                        // Navigate to HotelsScreenContent
                        globalProvider.setPage(AppPage.hotels);
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

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColorstatic.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
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

  void _openRoomSelectionBottomSheet(BuildContext context) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7, // Increased height for child age selectors
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
                        const Text(
                          "Sélectionner les chambres",
                          style: TextStyle(
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
                        itemCount: roomsData.length,
                        itemBuilder: (context, index) {
                          final room = roomsData[index];
                          return _buildRoomCard(
                            context,
                            index,
                            room,
                            setModalState,
                          );
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
      setState(() {
        roomsData = List<Map<String, dynamic>>.from(result);
      });
    }
  }

  Widget _buildRoomCard(
      BuildContext context, int index, Map<String, dynamic> room, Function setModalState) {
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
                  "Chambre ${index + 1}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (roomsData.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () {
                      setModalState(() {
                        roomsData.removeAt(index);
                      });
                    },
                  ),
              ],
            ),
            const Divider(height: 16),
            _buildCounterRow(
              icon: Icons.person_outline,
              label: "Adultes",
              count: room["adults"] as int,
              onIncrement: () {
                setModalState(() {
                  if ((room["adults"] as int) < 5) room["adults"]++;
                });
              },
              onDecrement: () {
                setModalState(() {
                  if ((room["adults"] as int) > 1) room["adults"]--;
                });
              },
            ),
            _buildCounterRow(
              icon: Icons.child_friendly,
              label: "Enfants",
              count: room["children"] as int,
              onIncrement: () {
                setModalState(() {
                  if ((room["children"] as int) < 5) {
                    room["children"]++;
                    // Add a default age (2 years) for the new child
                    List<int> childAges = List<int>.from(room["childAges"] ?? []);
                    childAges.add(2);
                    room["childAges"] = childAges;
                  }
                });
              },
              onDecrement: () {
                setModalState(() {
                  if ((room["children"] as int) > 0) {
                    room["children"]--;
                    // Remove the last child age
                    List<int> childAges = List<int>.from(room["childAges"] ?? []);
                    if (childAges.isNotEmpty) {
                      childAges.removeLast();
                    }
                    room["childAges"] = childAges;
                  }
                });
              },
            ),

            // Child age selectors - show when there are children
            if ((room["children"] as int) > 0) ...[
              const SizedBox(height: 12),
              _buildChildAgeSelectors(room, setModalState),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChildAgeSelectors(Map<String, dynamic> room, Function setModalState) {
    int childrenCount = room["children"] as int;
    List<int> childAges = List<int>.from(room["childAges"] ?? []);

    // Ensure we have the right number of age entries
    while (childAges.length < childrenCount) {
      childAges.add(2); // Default age
    }
    while (childAges.length > childrenCount) {
      childAges.removeLast();
    }

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
              const Text(
                "Âge des enfants",
                style: TextStyle(
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
              return Container(
                width: 80,
                child: Column(
                  children: [
                    Text(
                      "Enfant ${childIndex + 1}",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                          items: List.generate(13, (age) {
                            return DropdownMenuItem<int>(
                              value: age,
                              child: Text(
                                age == 0 ? "< 1 an" : "$age ans",
                                style: const TextStyle(fontSize: 13),
                              ),
                            );
                          }),
                          onChanged: (int? newAge) {
                            if (newAge != null) {
                              setModalState(() {
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
                roomsData.add({
                  "adults": 2,
                  "children": 0,
                  "childAges": <int>[]
                });
              });
            },
            icon: const Icon(Icons.add_circle_outline, color: AppColorstatic.lightTextColor),
            label: const Text("Ajouter une chambre", style: TextStyle(color: AppColorstatic.lightTextColor)),
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