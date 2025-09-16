import 'package:flutter/material.dart';
import 'package:tunisiagotravel/theme/color.dart';
import 'package:easy_localization/easy_localization.dart';

class GuestSummary extends StatefulWidget {
  final List<Map<String, dynamic>> initialRoomsData;
  final ValueChanged<List<Map<String, dynamic>>>? onRoomsChanged;

  const GuestSummary({
    super.key,
    required this.initialRoomsData,
    this.onRoomsChanged,
  });

  @override
  State<GuestSummary> createState() => _GuestSummaryState();
}

class _GuestSummaryState extends State<GuestSummary> {
  late List<Map<String, dynamic>> roomsData;

  @override
  void initState() {
    super.initState();
    roomsData = List<Map<String, dynamic>>.from(widget.initialRoomsData);
  }

  @override
  Widget build(BuildContext context) {
    int totalAdults = roomsData.fold(0, (sum, room) => sum + (room["adults"] as int));
    int totalChildren = roomsData.fold(0, (sum, room) => sum + (room["children"] as int));
    int totalRooms = roomsData.length;

    return _buildGuestSummary(totalRooms, totalAdults, totalChildren);
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
              "$rooms ${tr('room')}${rooms > 1 ? 's' : ''}",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const Text(" • ", style: TextStyle(color: Colors.grey)),
            Text(
              "$adults ${tr('adults')}",
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            if (children > 0) ...[
              const Text(" • ", style: TextStyle(color: Colors.grey)),
              Text(
                "$children ${tr('children')}${children > 1 ? 's' : ''}",
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _openRoomSelectionBottomSheet(BuildContext context) async {
    final result = await showModalBottomSheet<List<Map<String, dynamic>>>(
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
                          tr('select_rooms'),
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
      setState(() {
        roomsData = List<Map<String, dynamic>>.from(result);
      });
      widget.onRoomsChanged?.call(roomsData);
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
                  "${tr('room')} ${index + 1}",
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
              label: tr('adults'),
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
              label: tr('children'),
              count: room["children"] as int,
              onIncrement: () {
                setModalState(() {
                  if ((room["children"] as int) < 5) {
                    room["children"]++;
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
                    List<int> childAges = List<int>.from(room["childAges"] ?? []);
                    if (childAges.isNotEmpty) childAges.removeLast();
                    room["childAges"] = childAges;
                  }
                });
              },
            ),
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
                tr('children_age'),
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
                      "${tr('child')} ${childIndex + 1}",
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
                                age == 0 ? tr('less_than_one_year') : "$age ${tr('years')}",
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
              _buildCounterButton(icon: Icons.remove, onPressed: onDecrement),
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

  Widget _buildCounterButton({required IconData icon, required VoidCallback onPressed}) {
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
            label: Text(tr('room'), style: const TextStyle(color: AppColorstatic.lightTextColor)),
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
            child: Text(tr('done')),
          ),
        ),
      ],
    );
  }
}
