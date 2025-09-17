import 'dart:math';
import 'package:flutter/material.dart';
import '../../models/mouradi.dart';
import '../../theme/color.dart';
import 'CounterButton.dart';

class BoardingRoomSelection extends StatefulWidget {
  final List<BoardingOption> boardings;
  final Map<int, Map<String, int>> selectedRoomsByBoarding;
  final int maxRooms;
  final int totalSelected;
  final Function(int boardingId, int paxAdults, int roomId, int qty) onUpdate;

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
                            final roomKey = '${pax.adults}_${room.id}';
                            final qty = widget.selectedRoomsByBoarding[boarding.id]?[roomKey] ?? 0;
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
                                          "${(room.price*1.1).toStringAsFixed(2)} TND",
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
                                            ? () => widget.onUpdate(boarding.id, pax.adults, room.id, qty - 1)
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
                                            ? () => widget.onUpdate(boarding.id, pax.adults, room.id, qty + 1)
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