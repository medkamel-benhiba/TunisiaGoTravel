import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tunisiagotravel/theme/color.dart';
import 'package:tunisiagotravel/widgets/circuits/city_dropdown.dart';
import '../../models/hotel.dart';
import '../../models/hotelAvailabilityResponse.dart';
import '../../providers/global_provider.dart';
import '../../providers/hotel_provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart'; // Import easy_localization

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

  bool _isVisible = true;

  // Updated room data structure to include child ages
  List<Map<String, dynamic>> roomsData = [
    {
      "adults": 2,
      "children": 0,
      "childAges": <int>[]
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
              _buildSectionTitle("destination".tr(), Icons.location_on_outlined),
              const SizedBox(height: 8),
              CityDropdown(
                label: "select_destinations".tr(),
                onChanged: (name, id) {
                  setState(() {
                    _selectedCityName = name;
                    _selectedCityId = id;
                  });
                },
              ),

              const SizedBox(height: 16),

              // Date pickers
              _buildSectionTitle("travel_dates".tr(), Icons.calendar_today),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildDateInput(
                      context,
                      "start_date_label".tr(),
                      _startDate,
                          (picked) {
                        setState(() {
                          _startDate = picked;
                          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
                            _endDate = null;
                          }
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildDateInput(
                      context,
                      "end_date_label".tr(),
                      _endDate,
                          (picked) => setState(() => _endDate = picked),
                      firstDate: _startDate ?? DateTime.now(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Room/Adults/Children summary
              _buildSectionTitle("travelers".tr(), Icons.group_outlined),
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
                          SnackBar(
                            content: Text('please_fill_all_fields'.tr()),
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
                          SnackBar(
                            content: Text('select_all_child_ages'.tr()),
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

                        // Clear previous data before new search
                        globalProvider.setAvailableHotels([]);
                        hotelProvider.clearAvailableHotels();

                        // Fetch page 1 of both APIs concurrently
                        await Future.wait([
                          hotelProvider.fetchHotelDisponibilityPontion(
                            destinationId: _selectedCityId!,
                            dateStart: dateStart,
                            dateEnd: dateEnd,
                            rooms: roomsForApi,
                            page: 1,
                          ),
                          hotelProvider.fetchAvailableHotels(
                            destinationId: _selectedCityId!,
                            dateStart: dateStart,
                            dateEnd: dateEnd,
                            adults: totalAdults.toString(),
                            rooms: totalRooms.toString(),
                            children: totalChildren.toString(),
                            page: 1,
                          ),
                        ]);

                        // Get filtered hotel IDs from disponibility pention
                        final filteredHotelIds = hotelProvider.hotelDisponibilityPontion?.data
                            .where((hotel) {
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
                        })
                            .map((hotel) => hotel.id)
                            .toList() ??
                            [];

                        // Filter available hotels based on filteredHotelIds
                        final filteredAvailableHotels = hotelProvider.availableHotels
                            .where((hotel) => filteredHotelIds.contains(hotel.id))
                            .toList();

                        // Update GlobalProvider with filtered simple hotels for listing
                        globalProvider.setSelectedCityForHotels(_selectedCityName);
                        globalProvider.setAvailableHotels(filteredAvailableHotels);

                        // Debug prints
                        print("DEBUG - Pention hotels fetched (page 1): ${filteredAvailableHotels.length}");
                        print("DEBUG - Simple hotels fetched (page 1): ${hotelProvider.hotelDisponibilityPontion?.data.length ?? 0}");

                        // Hide the section after search
                        setState(() {
                          _isVisible = false;
                        });

                        // Navigate to HotelsScreenContent
                        globalProvider.setPage(AppPage.hotels);

                        // Continue fetching remaining pages in the background
                        _fetchRemainingPages(
                          hotelProvider: hotelProvider,
                          globalProvider: globalProvider,
                          destinationId: _selectedCityId!,
                          dateStart: dateStart,
                          dateEnd: dateEnd,
                          rooms: roomsForApi,
                          adults: totalAdults.toString(),
                          roomsCount: totalRooms.toString(),
                          children: totalChildren.toString(),
                          selectedCityName: _selectedCityName,
                          maxPages: 12,
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("search_error".tr())),
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
                        : Text(
                      "search".tr(),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

  // Helper method to fetch remaining pages in the background
  void _fetchRemainingPages({
    required HotelProvider hotelProvider,
    required GlobalProvider globalProvider,
    required String destinationId,
    required String dateStart,
    required String dateEnd,
    required List<Map<String, dynamic>> rooms,
    required String adults,
    required String roomsCount,
    required String children,
    required String? selectedCityName,
    required int maxPages,
  }) async {
    try {
      int currentPage = 2; // Start from page 2 since page 1 is already fetched
      bool hasMorePages = true;

      // Accumulate hotels across pages
      List<Hotel> accumulatedAvailableHotels = List.from(globalProvider.availableHotels);
      List<HotelData> accumulatedPensionHotels = List.from(hotelProvider.hotelDisponibilityPontion?.data ?? []);
      Set<String> existingAvailableHotelIds = accumulatedAvailableHotels.map((hotel) => hotel.id).toSet();
      Set<String> existingPensionHotelIds = accumulatedPensionHotels.map((hotel) => hotel.id).toSet();

      while (hasMorePages && currentPage <= maxPages) {
        // Fetch next pages concurrently
        await Future.wait([
          hotelProvider.fetchHotelDisponibilityPontion(
            destinationId: destinationId,
            dateStart: dateStart,
            dateEnd: dateEnd,
            rooms: rooms,
            page: currentPage,
          ),
          hotelProvider.fetchAvailableHotels(
            destinationId: destinationId,
            dateStart: dateStart,
            dateEnd: dateEnd,
            adults: adults,
            rooms: roomsCount,
            children: children,
            page: currentPage,
          ),
        ]);

        // Get new pension hotels from the current page
        final newPensionHotels = hotelProvider.hotelDisponibilityPontion?.data ?? [];
        final uniquePensionHotels = newPensionHotels.where((hotel) => !existingPensionHotelIds.contains(hotel.id)).toList();
        accumulatedPensionHotels.addAll(uniquePensionHotels);
        existingPensionHotelIds.addAll(uniquePensionHotels.map((hotel) => hotel.id));

        // Get filtered hotel IDs from accumulated pension hotels
        final filteredHotelIds = accumulatedPensionHotels
            .where((hotel) {
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
        })
            .map((hotel) => hotel.id)
            .toList();

        // Get new available hotels from the current page
        final newAvailableHotels = hotelProvider.availableHotels;
        final uniqueAvailableHotels = newAvailableHotels
            .where((hotel) => filteredHotelIds.contains(hotel.id) && !existingAvailableHotelIds.contains(hotel.id))
            .toList();
        accumulatedAvailableHotels.addAll(uniqueAvailableHotels);
        existingAvailableHotelIds.addAll(uniqueAvailableHotels.map((hotel) => hotel.id));

        // Update GlobalProvider with accumulated filtered hotels
        globalProvider.setAvailableHotels(List.from(accumulatedAvailableHotels));

        // Debug prints
        print("DEBUG - Simple hotels accumulated (page $currentPage): ${accumulatedAvailableHotels.length}");
        print("DEBUG - Pension hotels accumulated (page $currentPage): ${accumulatedPensionHotels.length}");

        // Update HotelProvider with accumulated pension hotels
        hotelProvider.updateHotelDisponibilityPontion(
          HotelAvailabilityResponse(
            currentPage: currentPage,
            data: accumulatedPensionHotels,
            lastPage: hotelProvider.hotelDisponibilityPontion?.lastPage ?? 1,
            nextPageUrl: hotelProvider.hotelDisponibilityPontion?.nextPageUrl,
          ),
        );

        // Check if there are more pages to fetch
        final pontionLastPage = hotelProvider.hotelDisponibilityPontion?.lastPage ?? 1;
        final availableHotelsLastPage = await _getAvailableHotelsLastPage(
          destinationId: destinationId,
          dateStart: dateStart,
          dateEnd: dateEnd,
          adults: adults,
          rooms: roomsCount,
          children: children,
          page: currentPage,
        );

        hasMorePages = currentPage < pontionLastPage || currentPage < availableHotelsLastPage;

        currentPage++;
      }
    } catch (e) {
      print("Error fetching remaining pages: $e");
      // Notify user of background fetch error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("background_fetch_error".tr())),
      );
    }
  }

  // Helper method to get the last page of available hotels
  Future<int> _getAvailableHotelsLastPage({
    required String destinationId,
    required String dateStart,
    required String dateEnd,
    required String adults,
    required String rooms,
    required String children,
    required int page,
  }) async {
    try {
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
          'babies': 0,
        }),
      );

      if (rawResponse.statusCode == 200) {
        final jsonData = json.decode(rawResponse.body);
        if (jsonData is Map<String, dynamic> && jsonData.containsKey('last_page')) {
          return jsonData['last_page'] as int;
        }
      }
      return 1; // Default to 1 if no pagination info
    } catch (e) {
      print("Error fetching last page for available hotels: $e");
      return 1;
    }
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

  Widget _buildDateInput(
      BuildContext context,
      String label,
      DateTime? date,
      Function(DateTime) onDatePicked, {
        DateTime? firstDate,
      }) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? firstDate ?? DateTime.now(),
          firstDate: firstDate ?? DateTime.now(),
          lastDate: DateTime(2100),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: AppColorstatic.primary,
                  onPrimary: Colors.white,
                  onSurface: Colors.black87,
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: AppColorstatic.primary,
                  ),
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) onDatePicked(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_month, color: Colors.grey.shade700, size: 13),
            const SizedBox(width: 4),
            Text(
              date == null ? label : date.toString().split(" ")[0],
              style: TextStyle(
                color: Colors.grey.shade700,
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.person_pin, color: Colors.grey.shade600, size: 16),
            const SizedBox(width: 8),
            Text(
              rooms > 1 ? "$rooms ${'rooms'.tr()}" : "$rooms ${'room'.tr()}",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const Text(" • ", style: TextStyle(color: Colors.grey)),
            Text(
              adults > 1 ? "$adults ${'adults'.tr()}" : "$adults ${'adult'.tr()}",
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            if (children > 0) ...[
              const Text(" • ", style: TextStyle(color: Colors.grey)),
              Text(
                children > 1 ? "$children ${'children'.tr()}" : "$children ${'child'.tr()}",
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
                          "select_rooms".tr(),
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
                  "${'room'.tr()} ${index + 1}",
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
              label: "adults".tr(),
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
              label: "children".tr(),
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
              Text(
                "child_age".tr(),
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
              return Container(
                width: 80,
                child: Column(
                  children: [
                    Text(
                      "${'child'.tr()} ${childIndex + 1}",
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
                                age == 0 ? "< 1 ${'year'.tr()}" : "$age ${'years'.tr()}",
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
            label: Text("room".tr(), style: const TextStyle(color: AppColorstatic.lightTextColor)),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: AppColorstatic.primary2,
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
            child: Text("done".tr()),
          ),
        ),
      ],
    );
  }
}