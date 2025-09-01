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

  const PensionRoomSelectionTgt({
    super.key,
    required this.pensions,
    required this.selectedRoomsByPension,
    required this.maxRooms,
    required this.totalSelected,
    required this.onUpdate,
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
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int _getTotalForPension(String pensionId) {
    final selected = widget.selectedRoomsByPension[pensionId] ?? {};
    return selected.values.fold(0, (a, b) => a + b);
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
        final total = _getTotalForPension(pension.id);
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

  const _RoomTgtCard({
    required this.room,
    required this.pension,
    required this.qty,
    required this.canAdd,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final price = room.purchasePrice.isNotEmpty
        ? room.purchasePrice.first.purchasePrice
        : 0.0;

    final capacity = room.capacity.isNotEmpty
        ? room.capacity.first
        : Capacity(adults: 0, children: 0, babies: 0);

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
              _buildRoomInfo(capacity, price),
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

  Widget _buildRoomInfo(Capacity capacity, double price) => Expanded(
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
        const SizedBox(height: 4),
        Text(
          "${price.toStringAsFixed(2)} ${pension.devise}",
          style: TextStyle(
            color: AppColorstatic.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (room.stillAvailable > 0)
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${room.stillAvailable} disponibles',
              style: const TextStyle(
                color: Colors.green,
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
/*
import 'package:flutter/material.dart';
import '../../models/hotelTgt.dart';
import '../../theme/color.dart';
import 'CounterButton.dart';

class BoardingRoomSelectionTgt extends StatefulWidget {
  final List<PensionTgt> pensions;
  final Map<String, Map<String, int>> selectedRoomsByPurchasePrice;
  final int maxRooms;
  final int totalSelected;
  final Function(String purchasePriceId, String roomId, int qty) onUpdate;
  final Map<String, dynamic> searchCriteria; // Added for date calculations

  const BoardingRoomSelectionTgt({
    super.key,
    required this.pensions,
    required this.selectedRoomsByPurchasePrice,
    required this.maxRooms,
    required this.totalSelected,
    required this.onUpdate,
    required this.searchCriteria,
  });

  @override
  State<BoardingRoomSelectionTgt> createState() => _BoardingRoomSelectionTgtState();
}

class _BoardingRoomSelectionTgtState extends State<BoardingRoomSelectionTgt>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final allPensions = _getAllPensionTitles();
    _tabController = TabController(length: allPensions.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<String> _getAllPensionTitles() =>
      widget.pensions.map((p) => p.name).toSet().toList();

  // Get unique rooms for a pension (remove duplicates)
  List<RoomTgt> _getUniqueRoomsForPension(String pensionName) {
    final pension = widget.pensions.firstWhere((p) => p.name == pensionName);
    final Map<String, RoomTgt> uniqueRooms = {};

    for (var room in pension.rooms) {
      if (!uniqueRooms.containsKey(room.id)) {
        uniqueRooms[room.id] = room;
      }
    }

    return uniqueRooms.values.toList();
  }

  // Get the best price for a room (lowest price among available options)
  PurchasePrice? _getBestPriceForRoom(RoomTgt room, String pensionName) {
    if (room.purchasePrice.isEmpty) return null;

    // Filter valid prices based on search dates
    final validPrices = room.purchasePrice.where((price) =>
        _isPriceValidForSearchDates(price)).toList();

    if (validPrices.isEmpty) return null;

    // Return the lowest price
    validPrices.sort((a, b) => a.purchasePrice.compareTo(b.purchasePrice));
    return validPrices.first;
  }

  bool _isPriceValidForSearchDates(PurchasePrice price) {
    // Add logic to check if price dates overlap with search dates
    // For now, return true - you can implement date checking logic
    return price.status;
  }

  int _getTotalForPension(String pensionName) {
    int total = 0;
    final rooms = _getUniqueRoomsForPension(pensionName);

    for (var room in rooms) {
      final bestPrice = _getBestPriceForRoom(room, pensionName);
      if (bestPrice != null) {
        final selected = widget.selectedRoomsByPurchasePrice[bestPrice.id] ?? {};
        total += selected.values.fold(0, (a, b) => a + b);
      }
    }
    return total;
  }

  int _calculateNights() {
    try {
      final checkIn = DateTime.parse(widget.searchCriteria['checkIn'] ?? '');
      final checkOut = DateTime.parse(widget.searchCriteria['checkOut'] ?? '');
      return checkOut.difference(checkIn).inDays;
    } catch (e) {
      return 1; // Default to 1 night
    }
  }

  @override
  Widget build(BuildContext context) {
    final pensionTitles = _getAllPensionTitles();
    if (pensionTitles.isEmpty) return _buildEmptyState();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          _Header(
            totalSelected: widget.totalSelected,
            maxRooms: widget.maxRooms,
            nights: _calculateNights(),
          ),
          _buildPensionTabs(pensionTitles),
          _buildTabViews(pensionTitles),
        ],
      ),
    );
  }

  Widget _buildEmptyState() => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    padding: const EdgeInsets.all(20),
    decoration: _cardDecoration(),
    child: const Text('Aucune option de pension disponible'),
  );

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

  Widget _buildPensionTabs(List<String> titles) => TabBar(
    controller: _tabController,
    isScrollable: true,
    labelPadding: const EdgeInsets.symmetric(horizontal: 16.0),
    labelColor: AppColorstatic.primary,
    unselectedLabelColor: Colors.grey[600],
    indicatorColor: AppColorstatic.primary,
    tabs: titles
        .map((title) => _PensionTab(
      title: title,
      total: _getTotalForPension(title),
    ))
        .toList(),
  );

  Widget _buildTabViews(List<String> titles) => SizedBox(
    height: 450,
    child: TabBarView(
      controller: _tabController,
      children: titles.map((pensionName) {
        final rooms = _getUniqueRoomsForPension(pensionName);
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: rooms.length,
          itemBuilder: (_, i) {
            final room = rooms[i];
            final bestPrice = _getBestPriceForRoom(room, pensionName);

            if (bestPrice == null) {
              return _UnavailableRoomCard(room: room);
            }

            final qty = widget.selectedRoomsByPurchasePrice[bestPrice.id]?[room.id] ?? 0;
            final canAdd = widget.totalSelected < widget.maxRooms;

            return _EnhancedRoomCard(
              room: room,
              price: bestPrice,
              qty: qty,
              canAdd: canAdd,
              nights: _calculateNights(),
              pensionName: pensionName,
              onUpdate: widget.onUpdate,
            );
          },
        );
      }).toList(),
    ),
  );
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
                  'Séjour de $nights nuit${nights > 1 ? 's' : ''}',
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
                color: totalSelected > 0 ? AppColorstatic.primary : Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PensionTab extends StatelessWidget {
  final String title;
  final int total;

  const _PensionTab({required this.title, required this.total});

  @override
  Widget build(BuildContext context) => Tab(
    child: Row(
      children: [
        _getPensionIcon(title),
        const SizedBox(width: 6),
        Text(title),
        if (total > 0) ...[
          const SizedBox(width: 2),
          CircleAvatar(
            radius: 10,
            backgroundColor: AppColorstatic.primary,
            child: Text(total.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ],
      ],
    ),
  );

  Widget _getPensionIcon(String pensionName) {
    if (pensionName.toLowerCase().contains('all inclusive')) {
      return const Icon(Icons.all_inclusive, size: 18);
    } else if (pensionName.toLowerCase().contains('demi')) {
      return const Icon(Icons.restaurant, size: 18);
    } else if (pensionName.toLowerCase().contains('petit')) {
      return const Icon(Icons.free_breakfast, size: 18);
    } else {
      return const Icon(Icons.bed_outlined, size: 18);
    }
  }
}

class _EnhancedRoomCard extends StatelessWidget {
  final RoomTgt room;
  final PurchasePrice price;
  final int qty;
  final bool canAdd;
  final int nights;
  final String pensionName;
  final Function(String purchasePriceId, String roomId, int qty) onUpdate;

  const _EnhancedRoomCard({
    required this.room,
    required this.price,
    required this.qty,
    required this.canAdd,
    required this.nights,
    required this.pensionName,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final totalAdults = room.capacity.fold(0, (sum, c) => sum + c.adults);
    final totalChildren = room.capacity.fold(0, (sum, c) => sum + c.children);
    final totalBabies = room.capacity.fold(0, (sum, c) => sum + c.babies);

    final pricePerNight = price.purchasePrice;
    final totalPrice = pricePerNight * nights;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: qty > 0 ? AppColorstatic.primary.withOpacity(0.08) : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: qty > 0 ? AppColorstatic.primary.withOpacity(0.3) : Colors.grey[300]!,
          width: qty > 0 ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _buildIcon(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        room.title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)
                    ),
                    const SizedBox(height: 4),
                    Text(
                        'Capacité: $totalAdults adultes, $totalChildren enfants, $totalBabies bébés',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12)
                    ),
                    const SizedBox(height: 8),
                    _buildPriceInfo(pricePerNight, totalPrice),
                  ],
                ),
              ),
              _buildCounter(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceInfo(double pricePerNight, double totalPrice) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Price per night
        Text(
            "${pricePerNight.toStringAsFixed(2)} ${price.currency}/nuit",
            style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w500
            )
        ),
        const SizedBox(height: 2),
        // Total price for the stay
        Text(
            "${totalPrice.toStringAsFixed(2)} ${price.currency} total",
            style: TextStyle(
                color: AppColorstatic.primary,
                fontWeight: FontWeight.bold,
                fontSize: 14
            )
        ),
        const SizedBox(height: 2),
        // Pension type reminder
        Text(
            pensionName,
            style: TextStyle(
                color: AppColorstatic.primary.withOpacity(0.8),
                fontSize: 11,
                fontStyle: FontStyle.italic
            )
        ),
      ],
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

  Widget _buildCounter() => Row(
    children: [
      CounterButton(
        icon: Icons.remove,
        onTap: qty > 0 ? () => onUpdate(price.id, room.id, qty - 1) : null,
        color: AppColorstatic.primary,
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(
            qty.toString(),
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: qty > 0 ? AppColorstatic.primary : Colors.grey
            )
        ),
      ),
      CounterButton(
        icon: Icons.add,
        onTap: canAdd && qty < room.stillAvailable
            ? () => onUpdate(price.id, room.id, qty + 1)
            : null,
        color: AppColorstatic.primary,
      ),
    ],
  );
}

class _UnavailableRoomCard extends StatelessWidget {
  final RoomTgt room;

  const _UnavailableRoomCard({required this.room});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(Icons.bed_outlined, color: Colors.grey[400]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    room.title,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[600]
                    )
                ),
                const SizedBox(height: 4),
                Text(
                    'Non disponible pour ces dates',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12)
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}*/