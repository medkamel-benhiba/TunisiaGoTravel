import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tunisiagotravel/screens/payment_screen.dart';
import 'package:tunisiagotravel/widgets/CountryPicker.dart';
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
  List<Map<String, TextEditingController>> travelerCountryControllers = [];
  List<Map<String, dynamic>> roomsWithTravelers = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeTravelerData();
  }

  void _initializeTravelerData() {
    final rooms = widget.searchCriteria['rooms'] as List<Map<String, dynamic>>? ?? [];
    final roomIds = _getRoomIds();
    final boardingIds = _getAccommodationIds();
    final quantities = _getQuantities();

    for (int roomIndex = 0; roomIndex < rooms.length; roomIndex++) {
      final room = rooms[roomIndex];
      final adults = int.tryParse(room['adults']?.toString() ?? '0') ?? 0;
      final children = int.tryParse(room['children']?.toString() ?? '0') ?? 0;

      room['infant'] = room['infants'] ?? 0;
      room['offer_id'] = room['offer_id'] ?? '';

      String roomTitle = 'room_default_title'.tr();
      String boardingTitle = 'boarding_default_title'.tr();

      final selectedRoomsSummary = widget.selectedRoomsData['selectedRoomsSummary'] as String? ?? '';
      if (selectedRoomsSummary.isNotEmpty) {
        final parts = selectedRoomsSummary.split(' (');
        if (parts.length >= 2) {
          roomTitle = parts[0].trim();
          final boardingPart = parts[1].split(')')[0].trim();
          if (boardingPart.isNotEmpty) {
            boardingTitle = boardingPart;
          }
        } else {
          roomTitle = selectedRoomsSummary.split(' x')[0].trim();
        }
      }

      List<Map<String, dynamic>> travelers = [];

      for (int i = 0; i < adults; i++) {
        final controllers = _createTravelerControllers();
        final countryController = _createCountryController();
        travelerControllers.add(controllers);
        travelerCountryControllers.add(countryController);
        travelers.add({
          'type': 'adult',
          'index': i + 1,
          'controllerIndex': travelerControllers.length - 1,
          'countryControllerIndex': travelerCountryControllers.length - 1,
        });
        _selectedGenders['room_${roomIndex + 1}_adult_${i + 1}'] = null;
      }

      for (int i = 0; i < children; i++) {
        final controllers = _createTravelerControllers();
        final countryController = _createCountryController();
        travelerControllers.add(controllers);
        travelerCountryControllers.add(countryController);
        travelers.add({
          'type': 'child',
          'index': i + 1,
          'controllerIndex': travelerControllers.length - 1,
          'countryControllerIndex': travelerCountryControllers.length - 1,
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
        'room_title': roomTitle,
        'room_id': roomIndex < roomIds.length ? roomIds[roomIndex] : '',
        'boarding_id': roomIndex < boardingIds.length ? boardingIds[roomIndex] : '',
        'quantity': roomIndex < quantities.length ? quantities[roomIndex] : 1,
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

  Map<String, TextEditingController> _createCountryController() {
    return {
      'country': TextEditingController(),
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

    for (var countryControllers in travelerCountryControllers) {
      countryControllers.values.forEach((c) => c.dispose());
    }

    _scrollController.dispose();
    super.dispose();
  }

  String _getTravelersSummary() {
    final rooms = widget.searchCriteria['rooms'] as List<Map<String, dynamic>>? ?? [];
    final totalAdults = rooms.fold<int>(0, (s, r) => s + int.tryParse(r['adults']?.toString() ?? '0')!);
    final totalChildren = rooms.fold<int>(0, (s, r) => s + int.tryParse(r['children']?.toString() ?? '0')!);

    // Use the translation keys with args
    return 'traveler_summary'.tr(namedArgs: {'adults_number': totalAdults.toString(), 'children_number': totalChildren.toString()});
  }

  List<Map<String, dynamic>> _generatePaxList() {
    List<Map<String, dynamic>> paxList = [];

    for (int roomIndex = 0; roomIndex < roomsWithTravelers.length; roomIndex++) {
      final roomData = roomsWithTravelers[roomIndex];
      final travelers = roomData['travelers'] as List<Map<String, dynamic>>;

      List<Map<String, dynamic>> adults = [];
      List<Map<String, dynamic>> children = [];

      for (var traveler in travelers) {
        final cIndex = traveler['controllerIndex'] as int;
        final controllers = travelerControllers[cIndex];
        final key = 'room_${roomIndex + 1}_${traveler['type']}_${traveler['index']}';
        final gender = _selectedGenders[key] ?? '';

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
          'Holder': traveler['type'] == 'adult' && traveler['index'] == 1,
        };

        if (traveler['type'] == 'adult') {
          adults.add(paxData);
        } else {
          children.add(paxData);
        }
      }

      paxList.add({
        'Id': roomData['room_id'] ?? '',
        'Boarding': roomData['boarding_id'] ?? '',
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
    dynamic response;
    if (!_formKey.currentState!.validate()) return;

    for (var key in _selectedGenders.keys) {
      if (_selectedGenders[key] == null) {
        _showErrorDialog('gender_required_message'.tr());
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      print("selectedRoomsData: ${widget.selectedRoomsData}");

      if (widget.hotelType.toLowerCase() == "mouradi") {
        final paxList = _generatePaxList();

        final mouradiReservationData = {
          "PreBooking": false,
          "Hotel": widget.hotelId,
          "City": widget.searchCriteria['mouradi_city_id'].toString(),
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

        response = await _apiService.postHotelReservationMouradi(mouradiReservationData);
        print("✅ Mouradi API Response: $response");

      } else if (widget.hotelType.toLowerCase() == "tgt") {
        final List<Map<String, dynamic>> paxList = [];

        int totalAdults = 0;
        int totalChildren = 0;
        final rooms = widget.searchCriteria['rooms'] as List<Map<String, dynamic>>? ?? [];
        for (var room in rooms) {
          totalAdults += int.tryParse(room['adults']?.toString() ?? '0') ?? 0;
          totalChildren += int.tryParse(room['children']?.toString() ?? '0') ?? 0;
        }

        for (int roomIndex = 0; roomIndex < roomsWithTravelers.length; roomIndex++) {
          final room = roomsWithTravelers[roomIndex];
          List<Map<String, dynamic>> adults = [];
          List<Map<String, dynamic>> children = [];

          final travelers = room['travelers'] as List? ?? [];
          for (var traveler in travelers) {
            final cIndex = traveler['controllerIndex'] as int? ?? -1;
            if (cIndex < 0 || cIndex >= travelerControllers.length) continue;

            final controllers = travelerControllers[cIndex];
            final key = 'room_${roomIndex + 1}_${traveler['type']}_${traveler['index']}';
            final gender = _selectedGenders[key];
            if (gender == null) continue;

            final paxData = {
              'Civility': gender == 'M.' ? 'Mr' : 'Mme',
              'Name': controllers['name']?.text ?? '',
              'Surname': controllers['firstname']?.text ?? '',
              'Holder': traveler['type'] == 'adult' && traveler['index'] == 1,
            };

            if (traveler['type'] == 'adult') {
              adults.add(paxData);
            } else {
              children.add(paxData);
            }
          }

          paxList.add({
            'Id': room['room_id'] ?? '',
            'Boarding': widget.selectedRoomsData['pensionIds'] ?? '',
            'View': [],
            'Supplement': [],
            'Pax': {
              'Adult': adults,
              'Child': children,
            }
          });
        }

        final tgtReservationData = {
          "name": "${_mainFirstNameController.text} ${_mainNameController.text}",
          "accommodation_id": widget.selectedRoomsData['pensionIds'] ?? '',
          "room_id": _getRoomIds(),
          "hotel_id": widget.hotelId,
          "date_start": widget.searchCriteria['dateStart'] ?? '',
          "date_end": widget.searchCriteria['dateEnd'] ?? '',
          "number": _getQuantities(),
          "email": _mainEmailController.text,
          "phone": _mainPhoneController.text,
          "city": _mainCityController.text,
          "country": _mainCountryController.text,
          "cin": _mainCinOrPassportController.text,
          "pax": paxList,
          "adults": totalAdults,
          "children": totalChildren,
          "total_price": widget.totalPrice,
        };

        print("👉 TGT Reservation Data: $tgtReservationData");

        response = await _apiService.reserveHotelTgt(tgtReservationData);
        print("✅ TGT API Response: $response");

      } else {
        final List<Map<String, dynamic>> selectedRooms = [];

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

          selectedRooms.add({
            'id': room['room_id'] ?? '36',
            'title': room['room_title'] ?? 'Chambre',
            'boarding_id': room['boarding_id'] ?? '1',
            'recommandation': '',
            'boarding_title': room['boarding_title'] ?? 'Logement Seul',
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

        response = await _apiService.postHotelReservationBHR(bhrReservationData);
        print("✅ BHR API Response: $response");
      }

      print("📌 Final API Response: $response");

      if (response != null && response['formUrl'] != null && mounted) {
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentScreen(formUrl: response["formUrl"]),
          ),
        );

        if (result == true && mounted) {
          _showSuccessDialog();
        }
      } else {
        if (mounted) _showErrorDialog("error_during_reservation".tr(args: [response.toString()]));
      }
    } catch (e) {
      print("❌ Exception during reservation: $e");
      if (mounted) _showErrorDialog('exception_during_reservation'.tr(args: [e.toString()]));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
  String _getSelectedRoomsSummary() => widget.selectedRoomsData['selectedRoomsSummary'] as String? ?? 'selected_rooms_default'.tr();

  void _showSuccessDialog() => showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      title: Text('reservation_confirmed_title'.tr()),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 60),
          const SizedBox(height: 16),
          Text('reservation_confirmed_message'.tr(), textAlign: TextAlign.center),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
          child: Text("back_to_home".tr()),
        ),
      ],
    ),
  );

  void _showErrorDialog(String error) => showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('error_title'.tr()),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error, color: Colors.red, size: 60),
          const SizedBox(height: 16),
          Text(error, textAlign: TextAlign.center),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text("ok".tr())),
      ],
    ),
  );

  Widget _buildTextField(
      TextEditingController controller, {
        required String label,
        required String? Function(String?) validator,
        IconData? icon,
        TextInputType? keyboardType,
        bool isCountryField = false,
        int? countryControllerIndex,
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
      readOnly: isCountryField,
      onTap: isCountryField && countryControllerIndex != null
          ? () async {
        final selectedCountry = await showCountryPicker(
          context: context,
          selectedCountry: controller.text,
        );
        if (selectedCountry != null) {
          setState(() {
            controller.text = selectedCountry.name;
          });
        }
      }
          : null,
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
          Text('contact_info_title'.tr(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColorstatic.primary)),
          const SizedBox(height: 16),
          _buildTextField(_mainNameController, label: 'name_label'.tr(), icon: Icons.person, validator: (v) => v!.isEmpty ? 'name_required_error'.tr() : null),
          const SizedBox(height: 12),
          _buildTextField(_mainFirstNameController, label: 'first_name_label'.tr(), icon: Icons.person, validator: (v) => v!.isEmpty ? 'first_name_required_error'.tr() : null),
          const SizedBox(height: 12),
          _buildTextField(_mainCinOrPassportController, label: 'cin_passport_label'.tr(), icon: Icons.credit_card, validator: (v) => v!.isEmpty ? 'cin_passport_required_error'.tr() : null),
          const SizedBox(height: 12),
          _buildTextField(_mainEmailController,
              label: 'email_label'.tr(), icon: Icons.email, keyboardType: TextInputType.emailAddress, validator: (v) {
                if (v!.isEmpty) return 'email_required_error'.tr();
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) return 'invalid_email_error'.tr();
                return null;
              }),
          const SizedBox(height: 12),
          _buildTextField(_mainPhoneController, label: 'phone_label'.tr(), icon: Icons.phone, keyboardType: TextInputType.phone, validator: (v) => v!.isEmpty ? 'phone_required_error'.tr() : null),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(_mainCityController, label: 'city_label'.tr(), icon: Icons.location_city, validator: (v) => v!.isEmpty ? 'city_required_error'.tr() : null),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  _mainCountryController,
                  label: 'country_label'.tr(),
                  icon: Icons.flag,
                  validator: (v) => v!.isEmpty ? 'country_required_error'.tr() : null,
                  isCountryField: true,
                  countryControllerIndex: -1, // Main contact country
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTravelerForm(Map<String, TextEditingController> controllers, Map<String, TextEditingController> countryControllers, String travelerType, int travelerIndex, int roomNumber) {
    final isAdult = travelerType == 'adult';
    final title = isAdult ? 'adult_title'.tr(args: [travelerIndex.toString()]) : 'child_title'.tr(args: [travelerIndex.toString()]);
    final uniqueKey = 'room_${roomNumber}_${travelerType}_$travelerIndex';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey[200]!)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColorstatic.primary)),
          const SizedBox(height: 16),
          Text('gender_label'.tr()),
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: Text('gender_male_short'.tr()),
                  value: 'M.',
                  groupValue: _selectedGenders[uniqueKey],
                  activeColor: AppColorstatic.primary2,
                  onChanged: (value) => setState(() => _selectedGenders[uniqueKey] = value),
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: Text('gender_female_short'.tr()),
                  value: 'Mme',
                  groupValue: _selectedGenders[uniqueKey],
                  onChanged: (value) => setState(() => _selectedGenders[uniqueKey] = value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTextField(controllers['name']!, label: 'name_label'.tr(), icon: Icons.person, validator: (v) => v!.isEmpty ? 'name_required_error'.tr() : null),
          const SizedBox(height: 12),
          _buildTextField(controllers['firstname']!, label: 'first_name_label'.tr(), icon: Icons.person, validator: (v) => v!.isEmpty ? 'first_name_required_error'.tr() : null),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'finalize_reservation_title'.tr(),
          style: const TextStyle(
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
                      Text(
                        'total_price_label'.tr(),
                        style: const TextStyle(
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
                            'room_summary_title'.tr(namedArgs: {
                              'room_number': (roomIndex + 1).toString(),
                              'adults': roomsWithTravelers[roomIndex]['adults'].toString(),
                              'children': roomsWithTravelers[roomIndex]['children'].toString(),
                            }),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColorstatic.primary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          for (var traveler in roomsWithTravelers[roomIndex]['travelers'])
                            _buildTravelerForm(
                              travelerControllers[traveler['controllerIndex']],
                              travelerCountryControllers[traveler['countryControllerIndex']],
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
                'required_fields_note'.tr(),
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
                'confirm_reservation_button'.tr(namedArgs: {'price': widget.totalPrice.toStringAsFixed(2), 'currency': widget.currency}),
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