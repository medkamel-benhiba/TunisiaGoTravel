import 'package:flutter/material.dart';
import '../models/hotel.dart';
import '../models/hotelBhr.dart';
import '../models/mouradi.dart';
import '../theme/color.dart';
import '../services/api_service.dart'; // Assuming your API service is here

class HotelReservationFormScreen extends StatefulWidget {
  final String hotelName;
  final String hotelId;
  final Map<String, dynamic> searchCriteria;
  final double totalPrice;
  final String currency;
  final Map<String, dynamic> selectedRoomsData;
  final String hotelType; // 'mouradi' or 'bhr'

  const HotelReservationFormScreen({
    super.key,
    required this.hotelName,
    required this.hotelId,
    required this.searchCriteria,
    required this.totalPrice,
    required this.currency,
    required this.selectedRoomsData,
    required this.hotelType,
  });

  @override
  State<HotelReservationFormScreen> createState() =>
      _HotelReservationFormScreenState();
}

class _HotelReservationFormScreenState extends State<HotelReservationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService(); // Your API service instance

  // List to store all traveler form controllers
  List<Map<String, TextEditingController>> travelerControllers = [];
  List<Map<String, dynamic>> roomsWithTravelers = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeTravelerData();
  }

  void _initializeTravelerData() {
    final rooms = widget.searchCriteria['rooms'] as List<Map<String, dynamic>>? ?? [];

    for (int roomIndex = 0; roomIndex < rooms.length; roomIndex++) {
      final room = rooms[roomIndex];
      final adults = int.tryParse(room['adults']?.toString() ?? '0') ?? 0;
      final children = int.tryParse(room['children']?.toString() ?? '0') ?? 0;

      List<Map<String, dynamic>> travelers = [];

      // Add adults
      for (int i = 0; i < adults; i++) {
        final controllers = {
          'name': TextEditingController(),
          'email': TextEditingController(),
          'phone': TextEditingController(),
          'city': TextEditingController(),
          'country': TextEditingController(),
          'cin': TextEditingController(),
        };
        travelerControllers.add(controllers);
        travelers.add({
          'type': 'adult',
          'index': i + 1,
          'controllerIndex': travelerControllers.length - 1,
        });
      }

      // Add children
      for (int i = 0; i < children; i++) {
        final controllers = {
          'name': TextEditingController(),
          'email': TextEditingController(),
          'phone': TextEditingController(),
          'city': TextEditingController(),
          'country': TextEditingController(),
          'cin': TextEditingController(),
        };
        travelerControllers.add(controllers);
        travelers.add({
          'type': 'child',
          'index': i + 1,
          'controllerIndex': travelerControllers.length - 1,
        });
      }

      roomsWithTravelers.add({
        'roomNumber': roomIndex + 1,
        'adults': adults,
        'children': children,
        'travelers': travelers,
      });
    }
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (var controllerMap in travelerControllers) {
      controllerMap.values.forEach((controller) => controller.dispose());
    }
    super.dispose();
  }

  String _getTravelersSummary() {
    final rooms = widget.searchCriteria['rooms'] as List<Map<String, dynamic>>? ?? [];
    final totalAdults = rooms.fold<int>(
        0, (s, r) => s + int.tryParse(r['adults']?.toString() ?? '0')!);
    final totalChildren = rooms.fold<int>(
        0, (s, r) => s + int.tryParse(r['children']?.toString() ?? '0')!);
    return "$totalAdults adultes, $totalChildren enfants";
  }

  List<Map<String, dynamic>> _generatePaxList() {
    List<Map<String, dynamic>> paxList = [];

    for (int roomIndex = 0; roomIndex < roomsWithTravelers.length; roomIndex++) {
      final roomData = roomsWithTravelers[roomIndex];
      final travelers = roomData['travelers'] as List<Map<String, dynamic>>;

      for (var traveler in travelers) {
        final controllerIndex = traveler['controllerIndex'] as int;
        final controllers = travelerControllers[controllerIndex];

        paxList.add({
          'room_number': roomIndex + 1,
          'type': traveler['type'],
          'name': controllers['name']?.text ?? '',
          'email': controllers['email']?.text ?? '',
          'phone': controllers['phone']?.text ?? '',
          'city': controllers['city']?.text ?? '',
          'country': controllers['country']?.text ?? '',
          'cin': controllers['cin']?.text ?? '',
        });
      }
    }

    return paxList;
  }

  List<String> _getAccommodationIds() {
    List<String> ids = [];
    if (widget.selectedRoomsData.containsKey('boardingIds')) {
      ids = List<String>.from(widget.selectedRoomsData['boardingIds'] ?? []);
    }
    return ids;
  }

  List<String> _getRoomIds() {
    List<String> ids = [];
    if (widget.selectedRoomsData.containsKey('roomIds')) {
      ids = List<String>.from(widget.selectedRoomsData['roomIds'] ?? []);
    }
    return ids;
  }

  List<int> _getQuantities() {
    List<int> quantities = [];
    if (widget.selectedRoomsData.containsKey('quantities')) {
      quantities = List<int>.from(widget.selectedRoomsData['quantities'] ?? []);
    }
    return quantities;
  }

  String _getSelectedRoomsSummary() {
    final selectedRooms = widget.selectedRoomsData['selectedRoomsSummary'] as String? ?? 'Chambres sélectionnées';
    return selectedRooms;
  }

  Future<void> _submitReservation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final rooms = widget.searchCriteria['rooms'] as List<Map<String, dynamic>>? ?? [];
      final totalAdults = rooms.fold<int>(
          0, (s, r) => s + int.tryParse(r['adults']?.toString() ?? '0')!);
      final totalChildren = rooms.fold<int>(
          0, (s, r) => s + int.tryParse(r['children']?.toString() ?? '0')!);

      final response = await _apiService.postHotelReservation(
        widget.hotelId,
        widget.searchCriteria['checkIn'],
        widget.searchCriteria['checkOut'],
        totalAdults,
        totalChildren,
        0, // babies
        travelerControllers.first['name']?.text ?? '', // Main contact name
        travelerControllers.first['email']?.text ?? '', // Main contact email
        travelerControllers.first['phone']?.text ?? '', // Main contact phone
        travelerControllers.first['city']?.text ?? '', // Main contact city
        travelerControllers.first['country']?.text ?? '', // Main contact country
        travelerControllers.first['cin']?.text ?? '', // Main contact cin
        _getAccommodationIds(),
        _getRoomIds(),
        _getQuantities(),
        widget.totalPrice,
        _generatePaxList(),
      );

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Réservation confirmée'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              'Votre réservation pour ${widget.hotelName} a été confirmée avec succès!',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text("Retour à l'accueil"),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Erreur'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error,
              color: Colors.red,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              'Une erreur s\'est produite lors de la réservation:\n$error',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Widget _buildTravelerForm(Map<String, TextEditingController> controllers, String travelerType, int travelerIndex, int roomNumber) {
    final isAdult = travelerType == 'adult';
    final title = isAdult ? 'Adulte $travelerIndex' : 'Enfant $travelerIndex';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColorstatic.primary,
            ),
          ),
          const SizedBox(height: 16),

          // Name field
          TextFormField(
            controller: controllers['name'],
            decoration: InputDecoration(
              labelText: 'Nom complet*',
              prefixIcon: const Icon(Icons.person, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: AppColorstatic.primary),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Le nom est requis';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          // Email field (only for adults or first traveler)
          if (isAdult) ...[
            TextFormField(
              controller: controllers['email'],
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email*',
                prefixIcon: const Icon(Icons.email, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: AppColorstatic.primary),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'L\'email est requis';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                  return 'Email invalide';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Phone field
            TextFormField(
              controller: controllers['phone'],
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Téléphone*',
                prefixIcon: const Icon(Icons.phone, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: AppColorstatic.primary),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le téléphone est requis';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
          ],

          // City field
          TextFormField(
            controller: controllers['city'],
            decoration: InputDecoration(
              labelText: 'Ville*',
              prefixIcon: const Icon(Icons.location_city, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: AppColorstatic.primary),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'La ville est requise';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          // Country field
          TextFormField(
            controller: controllers['country'],
            decoration: InputDecoration(
              labelText: 'Pays*',
              prefixIcon: const Icon(Icons.public, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: AppColorstatic.primary),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Le pays est requis';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),

          // CIN field (only for adults)
          if (isAdult)
            TextFormField(
              controller: controllers['cin'],
              decoration: InputDecoration(
                labelText: 'CIN*',
                prefixIcon: const Icon(Icons.credit_card, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: AppColorstatic.primary),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le CIN est requis';
                }
                return null;
              },
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Finaliser la réservation',
          style: TextStyle(
            color: AppColorstatic.lightTextColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColorstatic.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hotel summary card
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.hotelName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColorstatic.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.searchCriteria['dateStart']} - ${widget.searchCriteria['dateEnd']}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.people, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Text(
                        _getTravelersSummary(),
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.hotel, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _getSelectedRoomsSummary(),
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Prix total:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${widget.totalPrice.toStringAsFixed(2)} ${widget.currency}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColorstatic.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Form section
            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Generate forms for each room
                  for (int roomIndex = 0; roomIndex < roomsWithTravelers.length; roomIndex++)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chambre ${roomIndex + 1} - ${roomsWithTravelers[roomIndex]['adults']} adulte(s), ${roomsWithTravelers[roomIndex]['children']} enfant(s)',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColorstatic.primary,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Generate forms for each traveler in this room
                          for (var traveler in roomsWithTravelers[roomIndex]['travelers'])
                            _buildTravelerForm(
                              travelerControllers[traveler['controllerIndex']],
                              traveler['type'],
                              traveler['index'],
                              roomIndex + 1,
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '* Champs obligatoires\n* Email et téléphone requis uniquement pour les adultes\n* CIN requis uniquement pour les adultes',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 100), // Space for bottom button
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitReservation,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColorstatic.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : Text(
                'Confirmer la réservation • ${widget.totalPrice.toStringAsFixed(2)} ${widget.currency}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}