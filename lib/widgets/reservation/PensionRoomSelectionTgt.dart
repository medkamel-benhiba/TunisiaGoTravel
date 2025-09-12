import 'package:flutter/material.dart';
import '../../models/hotelTgt.dart';
import '../../theme/color.dart';
import 'CounterButton.dart';

class PensionRoomSelectionTgt extends StatefulWidget {
  final List<PensionTgt> pensions;
  final Map<String, Map<String, int>> selectedRoomsByPension;
  final int maxRooms;
  final int totalSelected;
  final Function(String pensionId, String roomId, int qty) onUpdate;
  final double Function(String pensionId, String roomId, {required int numberOfAdults}) calculateRoomPrice;
  final int nights;

  const PensionRoomSelectionTgt({
    super.key,
    required this.pensions,
    required this.selectedRoomsByPension,
    required this.maxRooms,
    required this.totalSelected,
    required this.onUpdate,
    required this.calculateRoomPrice,
    required this.nights,
  });

  @override
  State<PensionRoomSelectionTgt> createState() =>
      _PensionRoomSelectionTgtState();
}

class _PensionRoomSelectionTgtState extends State<PensionRoomSelectionTgt>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: widget.pensions.length, vsync: this);
  }

  @override
  void didUpdateWidget(covariant PensionRoomSelectionTgt oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pensions.length != oldWidget.pensions.length) {
      _tabController.dispose();
      _tabController = TabController(length: widget.pensions.length, vsync: this);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.pensions.isEmpty) {
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
            nights: widget.nights,
          ),
          _buildPensionTabs(),
          _buildTabViews(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: const Text('Aucune pension disponible'),
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

  Widget _buildPensionTabs() {
    return TabBar(
      controller: _tabController,
      isScrollable: true,
      labelPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      labelColor: AppColorstatic.primary,
      unselectedLabelColor: Colors.grey[600],
      indicatorColor: AppColorstatic.primary,
      tabs: widget.pensions.map((pension) {
        final total = widget.selectedRoomsByPension[pension.id]?.values.fold<int>(0, (sum, item) => sum + item) ?? 0;
        return _PensionTab(pension: pension, total: total);
      }).toList(),
    );
  }

  Widget _buildTabViews() {
    return SizedBox(
      height: 450,
      child: TabBarView(
        controller: _tabController,
        children: widget.pensions.map((pension) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: pension.rooms.length,
            itemBuilder: (_, i) {
              final room = pension.rooms[i];
              final qty = widget.selectedRoomsByPension[pension.id]?[room.id] ?? 0;
              final canAdd = widget.totalSelected < widget.maxRooms;

              return _RoomTgtCard(
                room: room,
                pension: pension,
                qty: qty,
                canAdd: canAdd,
                onUpdate: widget.onUpdate,
                calculateRoomPrice: widget.calculateRoomPrice,
                nights: widget.nights,
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
  final int nights;

  const _Header({
    required this.totalSelected,
    required this.maxRooms,
    required this.nights,
  });

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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chambres & Pension',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A)),
                ),
                const SizedBox(height: 2),
                Text(
                  'Choisissez votre pension et vos chambres',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
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

class _PensionTab extends StatelessWidget {
  final PensionTgt pension;
  final int total;

  const _PensionTab({required this.pension, required this.total});

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Row(
        children: [
          const Icon(Icons.restaurant, size: 18),
          const SizedBox(width: 6),
          Text(pension.name),
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

class _RoomTgtCard extends StatelessWidget {
  final RoomTgt room;
  final PensionTgt pension;
  final int qty;
  final bool canAdd;
  final Function(String pensionId, String roomId, int qty) onUpdate;
  final double Function(String pensionId, String roomId, {required int numberOfAdults}) calculateRoomPrice;
  final int nights;

  const _RoomTgtCard({
    required this.room,
    required this.pension,
    required this.qty,
    required this.canAdd,
    required this.onUpdate,
    required this.calculateRoomPrice,
    required this.nights,
  });

  @override
  Widget build(BuildContext context) {
    final singleAdultPrice = calculateRoomPrice(pension.id, room.id, numberOfAdults: 1);

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
              _buildRoomInfo(singleAdultPrice),
              _buildCounter(),
            ],
          ),
          if (pension.description.isNotEmpty) _buildPensionDescription(),
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

  Widget _buildRoomInfo(double displayedPrice) {
    final capacity = room.capacity.isNotEmpty
        ? room.capacity.first
        : Capacity(adults: 0, children: 0, babies: 0);

    // Change: Use capacity.adults instead of 1
    final displayAdults = capacity.adults;
    final displayedPrice = calculateRoomPrice(pension.id, room.id, numberOfAdults: displayAdults);

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            room.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Capacité: ${capacity.adults} adultes, ${capacity.children} enfants',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          const SizedBox(height: 6),
          if (calculateRoomPrice != null) ...[
            Text(
              "${displayedPrice.toStringAsFixed(2)} TND",
              style: TextStyle(
                color: AppColorstatic.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            // Add label for clarity (optional but recommended)
            Text(
              "pour ${displayAdults} adulte${displayAdults > 1 ? 's' : ''}",
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ] else ...[
            Text(
              "${pension.devise}",
              style: TextStyle(
                color: AppColorstatic.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCounter() => Row(
    children: [
      CounterButton(
        icon: Icons.remove,
        onTap: qty > 0
            ? () => onUpdate(pension.id, room.id, qty - 1)
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
        onTap: canAdd && qty < room.stillAvailable
            ? () => onUpdate(pension.id, room.id, qty + 1)
            : null,
        color: AppColorstatic.primary,
      ),
    ],
  );

  Widget _buildPensionDescription() => Container(
    margin: const EdgeInsets.only(top: 12),
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: Colors.blue.withOpacity(0.1),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: Colors.blue.withOpacity(0.3)),
    ),
    child: Row(
      children: [
        const Icon(Icons.info_outline, color: Colors.blue, size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            pension.description,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.blue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
}