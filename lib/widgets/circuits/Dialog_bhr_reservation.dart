import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tunisiagotravel/services/Bhr_reservation_calcul.dart';
import 'package:tunisiagotravel/widgets/reservation/CounterButton.dart';
import '../../models/hotelBhr.dart';
import '../../theme/color.dart';

class BhrBoardingRoomDialog extends StatefulWidget {
  final List<RoomBhr> rooms;
  final Map<String, dynamic> searchCriteria;
  final Map<String, Map<String, int>> initialSelection;
  final Function(Map<String, Map<String, int>> selectedRooms, double total) onConfirm;

  const BhrBoardingRoomDialog({
    super.key,
    required this.rooms,
    required this.searchCriteria,
    required this.initialSelection,
    required this.onConfirm,
  });

  @override
  State<BhrBoardingRoomDialog> createState() => _BhrBoardingRoomDialogState();

  static Future<void> show({
    required BuildContext context,
    required List<RoomBhr> rooms,
    required Map<String, dynamic> searchCriteria,
    required Map<String, Map<String, int>> initialSelection,
    required Function(Map<String, Map<String, int>> selectedRooms, double total) onConfirm,
  }) {
    return showDialog(
      context: context,
      builder: (context) => BhrBoardingRoomDialog(
        rooms: rooms,
        searchCriteria: searchCriteria,
        initialSelection: initialSelection,
        onConfirm: onConfirm,
      ),
    );
  }
}

class _BhrBoardingRoomDialogState extends State<BhrBoardingRoomDialog>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late Map<String, Map<String, int>> selectedRoomsByBoarding;
  late int maxRooms;
  late List<String> boardingTitles;

  @override
  void initState() {
    super.initState();
    selectedRoomsByBoarding = Map.from(widget.initialSelection);
    maxRooms = BhrReservationCalculator.getMaxRoomsAllowed(widget.searchCriteria);
    boardingTitles = BhrReservationCalculator.getAllBoardingTitles(widget.rooms);
    _tabController = TabController(length: boardingTitles.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int get totalSelected => BhrReservationCalculator.getTotalSelectedRooms(selectedRoomsByBoarding);

  double get totalPrice => BhrReservationCalculator.calculateTotal(
    selectedRoomsByBoarding,
    widget.rooms,
  );

  void _updateRoomSelection(String boardingId, String roomId, int newQty) {
    if (BhrReservationCalculator.canUpdateRoomQuantity(
        selectedRoomsByBoarding, boardingId, roomId, newQty, maxRooms)) {
      setState(() {
        final boardingRooms = selectedRoomsByBoarding[boardingId] ?? {};
        if (newQty > 0) {
          boardingRooms[roomId] = newQty;
        } else {
          boardingRooms.remove(roomId);
        }
        selectedRoomsByBoarding[boardingId] = boardingRooms;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Maximum $maxRooms chambres autorisées'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    final isLandscape = screenWidth > screenHeight;

    return Dialog(
      insetPadding: EdgeInsets.all(isTablet ? 40 : 16),
      backgroundColor: Colors.transparent,
      child: Container(
        width: isTablet ? screenWidth * 0.8 : screenWidth - 32,
        height: isLandscape ? screenHeight * 0.9 : screenHeight * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildHeader(isTablet),
            if (boardingTitles.isEmpty)
              _buildEmptyState()
            else ...[
              _buildBoardingTabs(isTablet),
              Expanded(child: _buildTabViews(isTablet)),
            ],
            _buildBottomBar(isTablet),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isTablet) {
    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColorstatic.primary.withOpacity(0.1), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isTablet ? 12 : 8),
            decoration: BoxDecoration(
              color: AppColorstatic.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.hotel,
              color: AppColorstatic.primary,
              size: isTablet ? 28 : 22,
            ),
          ),
          SizedBox(width: isTablet ? 16 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Chambres & Pension',
                  style: TextStyle(
                    fontSize: isTablet ? 22 : 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Choisissez votre formule et vos chambres',
                  style: TextStyle(
                    fontSize: isTablet ? 15 : 13,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 16 : 12,
              vertical: isTablet ? 8 : 6,
            ),
            decoration: BoxDecoration(
              color: totalSelected > 0
                  ? AppColorstatic.primary.withOpacity(0.1)
                  : Colors.grey[100],
              borderRadius: BorderRadius.circular(25),
            ),
            child: Text(
              '$totalSelected/$maxRooms',
              style: TextStyle(
                fontSize: isTablet ? 14 : 12,
                fontWeight: FontWeight.w600,
                color: totalSelected > 0 ? AppColorstatic.primary : Colors.grey[600],
              ),
            ),
          ),
          SizedBox(width: isTablet ? 16 : 12),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.close,
              color: Colors.grey[600],
              size: isTablet ? 28 : 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.hotel_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucune option de pension disponible',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoardingTabs(bool isTablet) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelPadding: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 16),
        labelColor: AppColorstatic.primary,
        unselectedLabelColor: Colors.grey[600],
        indicatorColor: AppColorstatic.primary,
        indicatorWeight: 3,
        tabs: boardingTitles.map((title) {
          final total = BhrReservationCalculator.getTotalForBoarding(
            widget.rooms,
            title,
            selectedRoomsByBoarding,
          );
          return _ResponsiveBoardingTab(
            title: title,
            total: total,
            isTablet: isTablet,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTabViews(bool isTablet) {
    return TabBarView(
      controller: _tabController,
      children: boardingTitles.map((title) {
        final rooms = BhrReservationCalculator.getRoomsForBoarding(widget.rooms, title);
        return ListView.builder(
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          itemCount: rooms.length,
          itemBuilder: (_, i) {
            final room = rooms[i];
            final boarding = BhrReservationCalculator.getBoardingForRoom(room, title);
            if (boarding == null) return const SizedBox.shrink();

            final qty = selectedRoomsByBoarding[boarding.id]?[room.id] ?? 0;
            final canAdd = totalSelected < maxRooms;

            return _ResponsiveRoomCard(
              room: room,
              boarding: boarding,
              qty: qty,
              canAdd: canAdd,
              onUpdate: _updateRoomSelection,
              isTablet: isTablet,
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildBottomBar(bool isTablet) {
    final validation = BhrReservationCalculator.validateSelection(
      selectedRoomsByBoarding,
      widget.searchCriteria,
    );

    return Container(
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  tr('total_price_label'),
                  style: TextStyle(
                    fontSize: isTablet ? 16 : 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  tr('total_price_value', args: [totalPrice.toStringAsFixed(2)]),
                  style: TextStyle(
                    fontSize: isTablet ? 24 : 20,
                    fontWeight: FontWeight.bold,
                    color: AppColorstatic.primary,
                  ),
                )

              ],
            ),
          ),
          SizedBox(width: isTablet ? 20 : 16),
          ElevatedButton(
            onPressed: validation['isValid']
                ? () {
              widget.onConfirm(selectedRoomsByBoarding, totalPrice);
              Navigator.of(context).pop();
            }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColorstatic.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 32 : 24,
                vertical: isTablet ? 16 : 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: Text(
              tr('confirm'),
              style: TextStyle(
                fontSize: isTablet ? 16 : 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResponsiveBoardingTab extends StatelessWidget {
  final String title;
  final int total;
  final bool isTablet;

  const _ResponsiveBoardingTab({
    required this.title,
    required this.total,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.restaurant, size: isTablet ? 22 : 18),
          SizedBox(width: isTablet ? 8 : 6),
          Text(
            title,
            style: TextStyle(fontSize: isTablet ? 16 : 14),
          ),
          if (total > 0) ...[
            SizedBox(width: isTablet ? 6 : 4),
            CircleAvatar(
              radius: isTablet ? 12 : 10,
              backgroundColor: AppColorstatic.primary,
              child: Text(
                total.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isTablet ? 14 : 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ResponsiveRoomCard extends StatelessWidget {
  final RoomBhr room;
  final BoardingBhr boarding;
  final int qty;
  final bool canAdd;
  final Function(String boardingId, String roomId, int qty) onUpdate;
  final bool isTablet;

  const _ResponsiveRoomCard({
    required this.room,
    required this.boarding,
    required this.qty,
    required this.canAdd,
    required this.onUpdate,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final displayRate = BhrReservationCalculator.calculateRoomPrice(boarding);
    final cancellationFee = BhrReservationCalculator.calculateCancellationFee(boarding);

    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 20 : 16),
      padding: EdgeInsets.all(isTablet ? 24 : 20),
      decoration: BoxDecoration(
        color: qty > 0
            ? AppColorstatic.primary.withOpacity(0.08)
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
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
              SizedBox(width: isTablet ? 16 : 12),
              Expanded(child: _buildRoomInfo(displayRate)),
              _buildCounter(),
            ],
          ),
          if (boarding.cancellationPolicy.fee > 0)
            _buildCancellationInfo(cancellationFee),
        ],
      ),
    );
  }

  Widget _buildIcon() => Container(
    padding: EdgeInsets.all(isTablet ? 12 : 8),
    decoration: BoxDecoration(
      color: AppColorstatic.primary.withOpacity(0.15),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Icon(
      Icons.bed,
      color: AppColorstatic.primary,
      size: isTablet ? 28 : 24,
    ),
  );

  Widget _buildRoomInfo(double displayRate) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        room.title,
        style: TextStyle(
          fontSize: isTablet ? 18 : 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      SizedBox(height: isTablet ? 6 : 4),
      Text(
        'capacity'.tr(args: [room.adults.toString(), room.children.toString()]),
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: isTablet ? 14 : 12,
        ),
      ),
      SizedBox(height: isTablet ? 6 : 4),
      Text(
        "${displayRate.toStringAsFixed(2)} TND",
        style: TextStyle(
          color: AppColorstatic.primary,
          fontWeight: FontWeight.bold,
          fontSize: isTablet ? 18 : 16,
        ),
      ),
      if (boarding.nonRefundable)
        Container(
          margin: EdgeInsets.only(top: isTablet ? 6 : 4),
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 8 : 6,
            vertical: isTablet ? 3 : 2,
          ),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            tr('non_refundable'),
            style: TextStyle(
              color: Colors.red,
              fontSize: isTablet ? 12 : 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
    ],
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
        padding: EdgeInsets.symmetric(horizontal: isTablet ? 16 : 12),
        child: Text(
          qty.toString(),
          style: TextStyle(
            fontSize: isTablet ? 18 : 16,
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

  Widget _buildCancellationInfo(double cancellationFee) => Container(
    margin: EdgeInsets.only(top: isTablet ? 16 : 12),
    padding: EdgeInsets.all(isTablet ? 12 : 8),
    decoration: BoxDecoration(
      color: Colors.orange.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.orange.withOpacity(0.3)),
    ),
    child: Row(
      children: [
        Icon(
          Icons.info_outline,
          color: Colors.orange,
          size: isTablet ? 20 : 16,
        ),
        SizedBox(width: isTablet ? 12 : 8),
        Expanded(
          child: Text(
            tr('cancellation_fee', args: [cancellationFee.toStringAsFixed(2)]),
            style: TextStyle(
              fontSize: isTablet ? 14 : 12,
              color: Colors.orange,
              fontWeight: FontWeight.w500,
            ),
          )

        ),
      ],
    ),
  );
}