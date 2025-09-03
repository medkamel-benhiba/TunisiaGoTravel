import 'package:flutter/material.dart';
import '../theme/color.dart';
import '../services/api_service.dart';

class HotelReservationFormScreen extends StatefulWidget {
  final String hotelName;
  final String hotelId;
  final Map<String, dynamic> searchCriteria;
  final double totalPrice;
  final String currency;
  final Map<String, dynamic> selectedRoomsData;
  final String hotelType;

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
  final _scrollController = ScrollController();
  final ApiService _apiService = ApiService();

  // Contact principal
  final _mainNameController = TextEditingController();
  final _mainFirstNameController = TextEditingController();
  final _mainCinOrPassportController = TextEditingController();
  final _mainEmailController = TextEditingController();
  final _mainPhoneController = TextEditingController();
  final _mainCountryController = TextEditingController();
  final _mainCityController = TextEditingController();

  // Voyageurs
  Map<String, String?> _selectedGenders = {};
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

      // Champs nécessaires pour le backend BHR
      room['infant'] = room['infants'] ?? 0;
      room['offer_id'] = room['offer_id'] ?? '';

      // Récupérer le boarding_title si disponible
      final selectedRoomsList = widget.selectedRoomsData['selectedRooms'] as List? ?? [];
      final boardingTitle = roomIndex < selectedRoomsList.length
          ? selectedRoomsList[roomIndex]['boarding_title'] ?? ''
          : '';

      List<Map<String, dynamic>> travelers = [];

      for (int i = 0; i < adults; i++) {
        final controllers = _createTravelerControllers();
        travelerControllers.add(controllers);
        travelers.add({
          'type': 'adult',
          'index': i + 1,
          'controllerIndex': travelerControllers.length - 1,
        });
        _selectedGenders['room_${roomIndex + 1}_adult_${i + 1}'] = null;
      }

      for (int i = 0; i < children; i++) {
        final controllers = _createTravelerControllers();
        travelerControllers.add(controllers);
        travelers.add({
          'type': 'child',
          'index': i + 1,
          'controllerIndex': travelerControllers.length - 1,
        });
        _selectedGenders['room_${roomIndex + 1}_child_${i + 1}'] = null;
      }

      roomsWithTravelers.add({
        'roomNumber': roomIndex + 1,
        'adults': adults,
        'children': children,
        'travelers': travelers,
        'infant': room['infant'],
        'offer_id': room['offer_id'],
        'boarding_title': boardingTitle,
      });
    }
  }



  Map<String, TextEditingController> _createTravelerControllers() {
    return {
      'name': TextEditingController(),
      'firstname': TextEditingController(),
      'email': TextEditingController(),
      'phone': TextEditingController(),
      'city': TextEditingController(),
      'country': TextEditingController(),
      'cin_or_passport': TextEditingController(),
    };
  }

  @override
  void dispose() {
    _mainNameController.dispose();
    _mainFirstNameController.dispose();
    _mainCinOrPassportController.dispose();
    _mainEmailController.dispose();
    _mainPhoneController.dispose();
    _mainCountryController.dispose();
    _mainCityController.dispose();

    for (var controllers in travelerControllers) {
      controllers.values.forEach((c) => c.dispose());
    }

    _scrollController.dispose();
    super.dispose();
  }

  String _getTravelersSummary() {
    final rooms = widget.searchCriteria['rooms'] as List<Map<String, dynamic>>? ?? [];
    final totalAdults = rooms.fold<int>(0, (s, r) => s + int.tryParse(r['adults']?.toString() ?? '0')!);
    final totalChildren = rooms.fold<int>(0, (s, r) => s + int.tryParse(r['children']?.toString() ?? '0')!);
    return "$totalAdults adultes, $totalChildren enfants";
  }

  List<Map<String, dynamic>> _generatePaxList() {
    List<Map<String, dynamic>> paxList = [];
    final roomIds = _getRoomIds();
    final accommodationIds = _getAccommodationIds();

    for (int roomIndex = 0; roomIndex < roomsWithTravelers.length; roomIndex++) {
      final travelers = roomsWithTravelers[roomIndex]['travelers'] as List<Map<String, dynamic>>;

      List<Map<String, dynamic>> adults = [];
      List<Map<String, dynamic>> children = [];

      for (var traveler in travelers) {
        final cIndex = traveler['controllerIndex'] as int;
        final controllers = travelerControllers[cIndex];
        final key = 'room_${roomIndex + 1}_${traveler['type']}_${traveler['index']}';
        final gender = _selectedGenders[key] ?? '';

        // Convert gender format
        String civility = '';
        if (gender == 'M.') {
          civility = 'Mr';
        } else if (gender == 'Mme') {
          civility = 'Mme';
        }

        final paxData = {
          'Civility': civility,
          'Name': controllers['name']?.text ?? '',
          'Surname': controllers['firstname']?.text ?? '',
          'Holder': traveler['type'] == 'adult' && traveler['index'] == 1, // First adult is holder
        };

        if (traveler['type'] == 'adult') {
          adults.add(paxData);
        } else {
          children.add(paxData);
        }
      }

      // Create the room pax structure
      paxList.add({
        'Id': roomIndex < roomIds.length ? roomIds[roomIndex] : '',
        'Boarding': roomIndex < accommodationIds.length ? accommodationIds[roomIndex] : '',
        'View': [],
        'Supplement': [],
        'Pax': {
          'Adult': adults,
          'Child': children,
        }
      });
    }

    return paxList;
  }

  Future<void> _submitReservation() async {
    if (!_formKey.currentState!.validate()) return;

    for (var key in _selectedGenders.keys) {
      if (_selectedGenders[key] == null) {
        _showErrorDialog('Veuillez sélectionner le genre pour tous les voyageurs.');
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      if (widget.hotelType.toLowerCase() == "mouradi") {
        final paxList = _generatePaxList();

        final mouradiReservationData = {
          "PreBooking": false,
          "Hotel": widget.hotelId,
          "City": widget.searchCriteria['mouradi_city_id'].toString() ,
          "CheckIn": widget.searchCriteria['dateStart'] ?? '',
          "CheckOut": widget.searchCriteria['dateEnd'] ?? '',
          "Option": [],
          "Source": "local-2",
          "Rooms": paxList,
          "name": _mainFirstNameController.text,
          "lastname": _mainNameController.text,
          "email": _mainEmailController.text,
          "phone": _mainPhoneController.text,
          "city": _mainCityController.text,
          "cin": _mainCinOrPassportController.text,
          "total_price": widget.totalPrice,
          "margeProfit": widget.totalPrice - (widget.totalPrice / 1.1),
          "country": _mainCountryController.text,
        };
        print("__Search criteria: ${widget.searchCriteria}");

        print("👉 Mouradi Reservation Data: $mouradiReservationData");
        await _apiService.postHotelReservationMouradi(mouradiReservationData);

      } else {
        /// 🔹 Flux actuel BHR
        final List<Map<String, dynamic>> selectedRooms = [];
        final roomIds = _getRoomIds();
        final accommodationIds = _getAccommodationIds();
        final selectedRoomsDataList = widget.selectedRoomsData['selectedRooms'] as List? ?? [];

        for (int roomIndex = 0; roomIndex < roomsWithTravelers.length; roomIndex++) {
          final room = roomsWithTravelers[roomIndex];
          List<Map<String, String>> customers = [];

          final travelers = room['travelers'] as List? ?? [];
          for (var traveler in travelers) {
            final cIndex = traveler['controllerIndex'] as int? ?? -1;
            if (cIndex < 0 || cIndex >= travelerControllers.length) continue;

            final controllers = travelerControllers[cIndex];
            final key = 'room_${roomIndex + 1}_${traveler['type']}_${traveler['index']}';
            final gender = _selectedGenders[key];
            if (gender == null) continue;

            customers.add({
              'civility': gender == 'M.' ? 'Mr' : 'Mme',
              'first_name': controllers['firstname']?.text ?? '',
              'last_name': controllers['name']?.text ?? '',
            });
          }

          final roomTitle = roomIndex < selectedRoomsDataList.length
              ? selectedRoomsDataList[roomIndex]['title'] ?? "Chambre"
              : "Chambre";

          final boardingId = roomIndex < accommodationIds.length ? accommodationIds[roomIndex] : "1";
          final roomId = roomIndex < roomIds.length ? roomIds[roomIndex] : "36";

          final boardingTitle = roomIndex < selectedRoomsDataList.length
              ? selectedRoomsDataList[roomIndex]['boarding_title'] ?? "Logement Seul"
              : "Logement Seul";

          selectedRooms.add({
            'id': roomId,
            'title': roomTitle,
            'boarding_id': boardingId,
            'recommandation': '',
            'boarding_title': boardingTitle,
            'adult': room['adults'] ?? 1,
            'child': room['children'] ?? 0,
            'infant': room['infant'] ?? 0,
            'offer_id': room['offer_id'] ?? '',
            'customers': customers,
          });
        }

        final bhrReservationData = {
          "date_start": widget.searchCriteria['dateStart'] ?? '',
          "date_end": widget.searchCriteria['dateEnd'] ?? '',
          "hotel_id": "1860",
          "hotel_title": widget.hotelName ?? '',
          "quote_id": widget.selectedRoomsData['quoteId'] ?? '',
          "source": " ",
          "address": widget.selectedRoomsData['hotelAddress'] ?? "",
          "total_price": widget.totalPrice,
          "expected_price": widget.totalPrice / 1.1,
          "margeProfit": widget.totalPrice - (widget.totalPrice / 1.1),
          "client_first_name": _mainFirstNameController.text,
          "client_last_name": _mainNameController.text,
          "client_email": _mainEmailController.text,
          "phone": _mainPhoneController.text,
          "city": _mainCityController.text,
          "cin": _mainCinOrPassportController.text,
          "nationality": _mapCountryToCode(_mainCountryController.text),
          "customer": {"email": _mainEmailController.text},
          "selected_rooms": selectedRooms,
        };



        print("👉 BHR Reservation Data: $bhrReservationData");
        await _apiService.postHotelReservationBHR(bhrReservationData);
      }

      if (mounted) _showSuccessDialog();
    } catch (e) {
      if (mounted) _showErrorDialog(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }



  // A helper method to map country names to two-letter codes.
  // This is a simplified example and should be expanded for a production app.
  String _mapCountryToCode(String country) {
    switch (country.toLowerCase()) {
      case 'tunisia':
        return 'TN';
      default:
        return '';
    }
  }


  List<String> _getAccommodationIds() => List<String>.from(widget.selectedRoomsData['boardingIds'] ?? []);
  List<String> _getRoomIds() => List<String>.from(widget.selectedRoomsData['roomIds'] ?? []);
  List<int> _getQuantities() => List<int>.from(widget.selectedRoomsData['quantities'] ?? []);
  String _getSelectedRoomsSummary() => widget.selectedRoomsData['selectedRoomsSummary'] as String? ?? 'Chambres sélectionnées';

  void _showSuccessDialog() => showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      title: const Text('Réservation confirmée'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.check_circle, color: Colors.green, size: 60),
          SizedBox(height: 16),
          Text('Votre réservation a été confirmée avec succès!', textAlign: TextAlign.center),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
          child: const Text("Retour à l'accueil"),
        ),
      ],
    ),
  );

  void _showErrorDialog(String error) => showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Erreur'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error, color: Colors.red, size: 60),
          const SizedBox(height: 16),
          Text("error", textAlign: TextAlign.center),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
      ],
    ),
  );

  Widget _buildTextField(
      TextEditingController controller, {
        required String label,
        required String? Function(String?) validator,
        IconData? icon,
        TextInputType? keyboardType,
      }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType ?? TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, size: 20) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: AppColorstatic.primary),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      validator: validator,
    );
  }

  Widget _buildMainContactForm() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 1, blurRadius: 5)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Informations de contact', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColorstatic.primary)),
          const SizedBox(height: 16),
          _buildTextField(_mainNameController, label: 'Nom*', icon: Icons.person, validator: (v) => v!.isEmpty ? 'Le nom est requis' : null),
          const SizedBox(height: 12),
          _buildTextField(_mainFirstNameController, label: 'Prénom*', icon: Icons.person, validator: (v) => v!.isEmpty ? 'Le prénom est requis' : null),
          const SizedBox(height: 12),
          _buildTextField(_mainCinOrPassportController, label: 'CIN ou Passeport*', icon: Icons.credit_card, validator: (v) => v!.isEmpty ? 'Le CIN ou Passeport est requis' : null),
          const SizedBox(height: 12),
          _buildTextField(_mainEmailController,
              label: 'Email*', icon: Icons.email, keyboardType: TextInputType.emailAddress, validator: (v) {
                if (v!.isEmpty) return 'L\'email est requis';
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) return 'Entrez un email valide';
                return null;
              }),
          const SizedBox(height: 12),
          _buildTextField(_mainPhoneController, label: 'Téléphone*', icon: Icons.phone, keyboardType: TextInputType.phone, validator: (v) => v!.isEmpty ? 'Le téléphone est requis' : null),
          const SizedBox(height: 12),
          _buildTextField(_mainCountryController, label: 'Pays*', icon: Icons.flag, validator: (v) => v!.isEmpty ? 'Le pays est requis' : null),
          const SizedBox(height: 12),
          _buildTextField(_mainCityController, label: 'Ville*', icon: Icons.location_city, validator: (v) => v!.isEmpty ? 'La ville est requise' : null),
        ],
      ),
    );
  }

  Widget _buildTravelerForm(Map<String, TextEditingController> controllers, String travelerType, int travelerIndex, int roomNumber) {
    final isAdult = travelerType == 'adult';
    final title = isAdult ? 'Adulte $travelerIndex' : 'Enfant $travelerIndex';
    final uniqueKey = 'room_${roomNumber}_${travelerType}_$travelerIndex';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[200]!)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColorstatic.primary)),
          const SizedBox(height: 16),
          const Text('Genre*'),
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('M.'),
                  value: 'M.',
                  groupValue: _selectedGenders[uniqueKey],
                  activeColor: AppColorstatic.primary2,
                  onChanged: (value) => setState(() => _selectedGenders[uniqueKey] = value),
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Mme'),
                  value: 'Mme',
                  groupValue: _selectedGenders[uniqueKey],
                  onChanged: (value) => setState(() => _selectedGenders[uniqueKey] = value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTextField(controllers['name']!, label: 'Nom*', icon: Icons.person, validator: (v) => v!.isEmpty ? 'Le nom est requis' : null),
          const SizedBox(height: 12),
          _buildTextField(controllers['firstname']!, label: 'Prénom*', icon: Icons.person, validator: (v) => v!.isEmpty ? 'Le prénom est requis' : null),
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

            // Main Contact Form
            _buildMainContactForm(),

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

            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '* Champs obligatoires',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 40),
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