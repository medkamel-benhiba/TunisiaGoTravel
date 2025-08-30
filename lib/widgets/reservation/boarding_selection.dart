import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/mouradi.dart';
import '../../theme/color.dart';
import 'CounterButton.dart';

class BoardingRoomSelection extends StatefulWidget {
  final List<BoardingOption> boardings;
  final Map<int, Map<int, int>> selectedRoomsByBoarding;
  final int maxRooms;
  final int totalSelected;
  final Function(int boardingId, int roomId, int qty) onUpdate;

  const BoardingRoomSelection({
    super.key,
    required this.boardings,
    required this.selectedRoomsByBoarding,
    required this.maxRooms,
    required this.totalSelected,
    required this.onUpdate,
  });

  @override
  State<BoardingRoomSelection> createState() => _BoardingRoomSelectionState();
}

class _BoardingRoomSelectionState extends State<BoardingRoomSelection>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.boardings.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColorstatic.primary.withOpacity(0.1), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColorstatic.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.hotel, color: AppColorstatic.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Chambres & Pension',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Choisissez votre formule et vos chambres',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: widget.totalSelected > 0
                        ? AppColorstatic.primary.withOpacity(0.2)
                        : Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${widget.totalSelected}/${widget.maxRooms}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: widget.totalSelected > 0
                          ? AppColorstatic.primary
                          : Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Boarding Tabs
          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: AppColorstatic.primary,
            unselectedLabelColor: Colors.grey[600],
            indicatorColor: AppColorstatic.primary,
            tabs: widget.boardings.map((boarding) {
              final selectedRooms = widget.selectedRoomsByBoarding[boarding.id] ?? {};
              final totalForBoarding = selectedRooms.values.fold(0, (a, b) => a + b);

              return Tab(
                child: Row(
                  children: [
                    const Icon(Icons.restaurant, size: 18),
                    const SizedBox(width: 6),
                    Text(boarding.name),
                    if (totalForBoarding > 0) ...[
                      const SizedBox(width: 6),
                      CircleAvatar(
                        radius: 10,
                        backgroundColor: AppColorstatic.primary,
                        child: Text(
                          totalForBoarding.toString(),
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),

          // Boarding Tab Views => Rooms
          SizedBox(
            height: 400, // give enough height for room cards
            child: TabBarView(
              controller: _tabController,
              children: widget.boardings.map((boarding) {
                final roomsByPax = boarding.pax;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: roomsByPax.length,
                  itemBuilder: (_, paxIndex) {
                    final pax = roomsByPax[paxIndex];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pax.adults > 1 ? "${pax.adults} Adultes" : "${pax.adults} Adulte",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 12),
                        Column(
                          children: pax.rooms.map((room) {
                            final qty = widget.selectedRoomsByBoarding[boarding.id]?[room.id] ?? 0;
                            final canAdd = widget.totalSelected < widget.maxRooms;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: qty > 0
                                    ? AppColorstatic.primary.withOpacity(0.08)
                                    : Colors.grey[50],
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: qty > 0
                                      ? AppColorstatic.primary.withOpacity(0.3)
                                      : Colors.grey[300]!,
                                  width: qty > 0 ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Left Icon
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColorstatic.primary.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(Icons.bed, color: AppColorstatic.primary),
                                  ),
                                  const SizedBox(width: 12),

                                  // Room Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(room.name,
                                            style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600)),
                                        const SizedBox(height: 4),
                                        Text(
                                          "${room.price.toStringAsFixed(2)} TND",
                                          style: TextStyle(
                                            color: AppColorstatic.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Counter
                                  Row(
                                    children: [
                                      CounterButton(
                                        icon: Icons.remove,
                                        onTap: qty > 0
                                            ? () => widget.onUpdate(boarding.id, room.id, qty - 1)
                                            : null,
                                        color: AppColorstatic.primary,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        child: Text(
                                          qty.toString(),
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: qty > 0
                                                ? AppColorstatic.primary
                                                : Colors.grey,
                                          ),
                                        ),
                                      ),
                                      CounterButton(
                                        icon: Icons.add,
                                        onTap: canAdd
                                            ? () => widget.onUpdate(boarding.id, room.id, qty + 1)
                                            : null,
                                        color: AppColorstatic.primary,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    );
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}


/*import 'package:flutter/material.dart';
import '../../theme/color.dart';

class BoardingSelection extends StatelessWidget {
  final Map<String, dynamic> selectedRoom;
  final Map<String, dynamic>? selectedBoarding;
  final Function(Map<String, dynamic>) onBoardingSelected;

  const BoardingSelection({
    super.key,
    required this.selectedRoom,
    required this.selectedBoarding,
    required this.onBoardingSelected,
  });

  @override
  Widget build(BuildContext context) {
    // Correctly extract the 'Boarding' list from the 'Boardings' map.
    final dynamic rawBoardings = selectedRoom['Boardings']?['Boarding'];
    final List<dynamic> boardingOptions = (rawBoardings is List)
        ? rawBoardings
        : (rawBoardings != null ? [rawBoardings] : []);

    if (boardingOptions.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.restaurant, color: AppColorstatic.primary, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Type de pension',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.restaurant, color: AppColorstatic.primary, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Choisir le type de pension',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...boardingOptions.map((board) {
              final boardId = board['@attributes']?['id']?.toString() ?? board['id']?.toString() ?? '';
              final isSelected = selectedBoarding != null &&
                  (selectedBoarding!['@attributes']?['id']?.toString() == boardId ||
                      selectedBoarding!['id']?.toString() == boardId);

              final price = _getBoardingPrice(board);
              final priceText = price == '0' ? 'Inclus' : '$price TND';

              return InkWell(
                onTap: () => onBoardingSelected(board),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: isSelected ? AppColorstatic.primary : Colors.grey[300]!,
                        width: 2),
                    borderRadius: BorderRadius.circular(8),
                    color: isSelected ? AppColorstatic.primary.withOpacity(0.05) : null,
                  ),
                  child: Row(
                    children: [
                      Radio<String>(
                        value: boardId,
                        groupValue: selectedBoarding != null
                            ? (selectedBoarding!['@attributes']?['id']?.toString() ?? selectedBoarding!['id']?.toString() ?? '')
                            : null,
                        onChanged: (value) => onBoardingSelected(board),
                        activeColor: AppColorstatic.primary,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              board['Title']?.toString() ?? 'Pension complète',
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                            if (board['description'] != null)
                              Text(
                                board['description'].toString(),
                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                              ),
                          ],
                        ),
                      ),
                      Text(priceText,
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: isSelected ? AppColorstatic.primary : Colors.grey[700])),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  String _getBoardingPrice(Map<String, dynamic> boarding) {
    String? rawPrice;

    if (boarding['Rate'] != null) {
      rawPrice = boarding['Rate'].toString();
    } else if (boarding['RateWithoutPromotion'] != null) {
      rawPrice = boarding['RateWithoutPromotion'].toString();
    } else if (boarding['Price'] != null) {
      rawPrice = boarding['Price'].toString();
    } else if (boarding['@attributes']?['rate'] != null) {
      rawPrice = boarding['@attributes']['rate'].toString();
    } else if (boarding['CancellationPolicy']?['Fee'] != null) {
      rawPrice = boarding['CancellationPolicy']['Fee'].toString();
    }

    if (rawPrice == null || rawPrice.trim().isEmpty) return '0';

    // Replace comma with dot and then parse
    rawPrice = rawPrice.replaceAll(',', '.');
    final value = double.tryParse(rawPrice);

    if (value == null) return '0';

    // Format rounded to the nearest integer
    return value.toStringAsFixed(2);
  }
}*/