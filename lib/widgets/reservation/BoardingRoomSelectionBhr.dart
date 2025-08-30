import 'package:flutter/material.dart';
import '../../models/hotelBhr.dart';
import '../../theme/color.dart';
import 'CounterButton.dart';

class BoardingRoomSelectionBhr extends StatefulWidget {
  final List<RoomBhr> rooms;
  final Map<String, Map<String, int>> selectedRoomsByBoarding;
  final int maxRooms;
  final int totalSelected;
  final Function(String boardingId, String roomId, int qty) onUpdate;

  const BoardingRoomSelectionBhr({
    super.key,
    required this.rooms,
    required this.selectedRoomsByBoarding,
    required this.maxRooms,
    required this.totalSelected,
    required this.onUpdate,
  });

  @override
  State<BoardingRoomSelectionBhr> createState() =>
      _BoardingRoomSelectionBhrState();
}

class _BoardingRoomSelectionBhrState extends State<BoardingRoomSelectionBhr>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final allBoardings = _getAllBoardingTitles();
    _tabController = TabController(length: allBoardings.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<String> _getAllBoardingTitles() => widget.rooms
      .expand((room) => room.boardings)
      .map((boarding) => boarding.title)
      .toSet()
      .toList();

  List<RoomBhr> _getRoomsForBoarding(String title) => widget.rooms
      .where((room) =>
      room.boardings.any((boarding) => boarding.title == title))
      .toList();

  BoardingBhr? _getBoardingForRoom(RoomBhr room, String title) {
    try {
      return room.boardings.firstWhere((b) => b.title == title);
    } catch (_) {
      return null;
    }
  }

  int _getTotalForBoarding(String title) {
    int total = 0;
    final seenRoomIds = <String>{};

    for (var room in widget.rooms) {
      if (seenRoomIds.contains(room.id)) continue;
      seenRoomIds.add(room.id);

      final boarding = _getBoardingForRoom(room, title);
      if (boarding != null) {
        final selected = widget.selectedRoomsByBoarding[boarding.id] ?? {};
        final roomTotal = selected[room.id] ?? 0;
        total += roomTotal;
      }
    }
    return total;
  }

  // --- Build ---
  @override
  Widget build(BuildContext context) {
    final boardingTitles = _getAllBoardingTitles();

    if (boardingTitles.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _Header(
            totalSelected: widget.totalSelected,
            maxRooms: widget.maxRooms,
          ),
          _buildBoardingTabs(boardingTitles),
          _buildTabViews(boardingTitles),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: const Text('Aucune option de pension disponible'),
    );
  }

  BoxDecoration _cardDecoration() => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(18),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );

  Widget _buildBoardingTabs(List<String> titles) {
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      labelPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      labelColor: AppColorstatic.primary,
      unselectedLabelColor: Colors.grey[600],
      indicatorColor: AppColorstatic.primary,
      tabs: titles.map((title) {
        final total = _getTotalForBoarding(title);
        return _BoardingTab(title: title, total: total);
      }).toList(),
    );
  }

  Widget _buildTabViews(List<String> titles) {
    return SizedBox(
      height: 450,
      child: TabBarView(
        controller: _tabController,
        children: titles.map((title) {
          final rooms = _getRoomsForBoarding(title);
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: rooms.length,
            itemBuilder: (_, i) {
              final room = rooms[i];
              final boarding = _getBoardingForRoom(room, title);
              if (boarding == null) return const SizedBox.shrink();

              final qty =
                  widget.selectedRoomsByBoarding[boarding.id]?[room.id] ?? 0;
              final canAdd = widget.totalSelected < widget.maxRooms;

              return _RoomCard(
                room: room,
                boarding: boarding,
                qty: qty,
                canAdd: canAdd,
                onUpdate: widget.onUpdate,
              );
            },
          );
        }).toList(),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final int totalSelected;
  final int maxRooms;

  const _Header({required this.totalSelected, required this.maxRooms});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chambres & Pension',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A)),
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
              color: totalSelected > 0
                  ? AppColorstatic.primary.withOpacity(0.1)
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$totalSelected/$maxRooms',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color:
                totalSelected > 0 ? AppColorstatic.primary : Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BoardingTab extends StatelessWidget {
  final String title;
  final int total;

  const _BoardingTab({required this.title, required this.total});

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Row(
        children: [
          const Icon(Icons.restaurant, size: 18),
          const SizedBox(width: 6),
          Text(title),
          if (total > 0) ...[
            const SizedBox(width: 2),
            CircleAvatar(
              radius: 10,
              backgroundColor: AppColorstatic.primary,
              child: Text(
                total.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  final RoomBhr room;
  final BoardingBhr boarding;
  final int qty;
  final bool canAdd;
  final Function(String boardingId, String roomId, int qty) onUpdate;

  const _RoomCard({
    required this.room,
    required this.boarding,
    required this.qty,
    required this.canAdd,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
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
      child: Column(
        children: [
          Row(
            children: [
              _buildIcon(),
              const SizedBox(width: 12),
              _buildRoomInfo(),
              _buildCounter(),
            ],
          ),
          if (boarding.cancellationPolicy.fee > 0) _buildCancellationInfo(),
        ],
      ),
    );
  }

  Widget _buildIcon() => Container(
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: AppColorstatic.primary.withOpacity(0.15),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Icon(Icons.bed, color: AppColorstatic.primary),
  );

  Widget _buildRoomInfo() => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          room.title,
          style:
          const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text(
          'Capacité: ${room.adults} adultes, ${room.children} enfants',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          "${boarding.rate.toStringAsFixed(2)} TND",
          style: TextStyle(
            color: AppColorstatic.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (boarding.nonRefundable)
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding:
            const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'Non remboursable',
              style: TextStyle(
                color: Colors.red,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    ),
  );

  Widget _buildCounter() => Row(
    children: [
      CounterButton(
        icon: Icons.remove,
        onTap: qty > 0
            ? () => onUpdate(boarding.id, room.id, qty - 1)
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
            color: qty > 0 ? AppColorstatic.primary : Colors.grey,
          ),
        ),
      ),
      CounterButton(
        icon: Icons.add,
        onTap: canAdd && qty < room.availableQuantity
            ? () => onUpdate(boarding.id, room.id, qty + 1)
            : null,
        color: AppColorstatic.primary,
      ),
    ],
  );

  Widget _buildCancellationInfo() => Container(
    margin: const EdgeInsets.only(top: 12),
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.orange.withOpacity(0.1),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: Colors.orange.withOpacity(0.3)),
    ),
    child: Row(
      children: [
        const Icon(Icons.info_outline, color: Colors.orange, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Frais d\'annulation: ${boarding.cancellationPolicy.fee.toStringAsFixed(2)} TND',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.orange,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
}
