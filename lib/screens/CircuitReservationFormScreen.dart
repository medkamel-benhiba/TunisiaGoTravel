import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tunisiagotravel/screens/CircuitReservationSuccess_screen.dart';
import 'package:tunisiagotravel/widgets/CountryPicker.dart';
import '../services/api_service.dart';
import '../theme/color.dart';

class CircuitReservationFormScreen extends StatefulWidget {
  final Map<String, dynamic> circuitData;
  final bool isManualCircuit;
  final Map<String, dynamic> formData;

  const CircuitReservationFormScreen({
    super.key,
    required this.circuitData,
    required this.isManualCircuit,
    required this.formData,
  });

  @override
  State<CircuitReservationFormScreen> createState() => _CircuitReservationFormScreenState();
}

class _CircuitReservationFormScreenState extends State<CircuitReservationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  // User information controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _addressController = TextEditingController();

  // Adults information for each room
  List<List<Map<String, TextEditingController>>> _adultsControllers = [];

  // Children information for each room
  List<List<Map<String, TextEditingController>>> _childrenControllers = [];

  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeControllersForRooms();
  }

  void _initializeControllersForRooms() {
    final roomsData = widget.formData['roomsData'] as List<Map<String, dynamic>>? ??
        [{"adults": 2, "children": 0, "childAges": []}];

    // Initialize adults controllers
    _adultsControllers = roomsData.map((room) {
      int adultsCount = room['adults'] as int;
      return List.generate(adultsCount, (index) => {
        'firstName': TextEditingController(),
        'lastName': TextEditingController(),
        'email': TextEditingController(),
        'birthday': TextEditingController(),
        'title': TextEditingController(text: 'Mr'),
        'phone': TextEditingController(),
      });
    }).toList();

    // Initialize children controllers
    _childrenControllers = roomsData.map((room) {
      int childrenCount = room['children'] as int;
      List<int> childAges = List<int>.from(room['childAges'] ?? []);
      return List.generate(childrenCount, (index) => {
        'firstName': TextEditingController(),
        'lastName': TextEditingController(),
        'birthday': TextEditingController(),
        'age': TextEditingController(text: index < childAges.length ? childAges[index].toString() : ''),
      });
    }).toList();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _zipCodeController.dispose();
    _addressController.dispose();

    // Dispose adults controllers
    for (var roomAdults in _adultsControllers) {
      for (var adult in roomAdults) {
        adult.values.forEach((controller) => controller.dispose());
      }
    }

    // Dispose children controllers
    for (var roomChildren in _childrenControllers) {
      for (var child in roomChildren) {
        child.values.forEach((controller) => controller.dispose());
      }
    }
    super.dispose();
  }

  Future<void> _submitReservation() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final reservationData = _buildReservationData();

      final response = await _apiService.createCircuitReservation(reservationData);

      if (response['success'] == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const CircuitReservationSuccessScreen(),
          ),
        );
      } else {
        setState(() {
          _error = 'reservation_failed'.tr();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'reservation_error'.tr() + ': ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic> _buildReservationData() {
    // Wrap circuitData in listparjours
    final planingWithDestinations = {
      'listparjours': widget.circuitData,
      'alldestination': widget.formData['alldestination'] ?? [],
    };

    // Build rooms data
    List<Map<String, dynamic>> rooms = [];
    for (int roomIndex = 0; roomIndex < _adultsControllers.length; roomIndex++) {
      List<Map<String, dynamic>> adults = _adultsControllers[roomIndex].map((adult) => {
        'firstName': adult['firstName']!.text,
        'lastName': adult['lastName']!.text,
        'title': adult['title']!.text,
      }).toList();

      List<Map<String, dynamic>> children = roomIndex < _childrenControllers.length
          ? _childrenControllers[roomIndex].map((child) => {
        'firstName': child['firstName']!.text,
        'lastName': child['lastName']!.text,
        'age': child['age']!.text,
      }).toList()
          : [];

      rooms.add({'adults': adults, 'children': children});
    }

    return {
      'planing': planingWithDestinations,
      'hotelsReservation': [],
      'restaurantReservation': [],
      'user': {
        'nom': _lastNameController.text,
        'prenom': _firstNameController.text,
        'email': _emailController.text,
        'telephone': _phoneController.text,
        'city': _cityController.text,
        'pays': _countryController.text,
        'zip_code': _zipCodeController.text,
        'adresse': _addressController.text,
        'rooms': rooms,
      },
      'reservation': {
        'departureCity': _getDepartureCityData(),
        'arrivalCity': _getArrivalCityData(),
        'adults': widget.formData['adults'] ?? 2,
        'children': widget.formData['children'] ?? 0,
        'rooms': widget.formData['rooms'] ?? 1,
        'babies': 0,
        'budget': widget.formData['budget'] ?? 1000,
        'departureDate': widget.formData['start'] ?? '',
        'arrivalDate': widget.formData['end'] ?? '',
      },
    };
  }

  Map<String, dynamic> _getDepartureCityData() {
    return {
      'id': widget.formData['departCityId'],
      'name': widget.formData['departCityName'] ?? '',
    };
  }

  Map<String, dynamic> _getArrivalCityData() {
    return {
      'id': widget.formData['arriveCityId'],
      'name': widget.formData['arriveCityName'] ?? '',
    };
  }

  String _getTravelersSummary() {
    final totalAdults = widget.formData['adults'] is int
        ? widget.formData['adults']
        : int.tryParse(widget.formData['adults'].toString()) ?? 2;

    final totalChildren = widget.formData['children'] is int
        ? widget.formData['children']
        : int.tryParse(widget.formData['children'].toString()) ?? 0;

    return 'traveler_summary'.tr(
      namedArgs: {
        'adults_number': totalAdults.toString(),
        'children_number': totalChildren.toString(),
      },
    );
  }

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
          Text('contact_info_title'.tr(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColorstatic.primary)),
          const SizedBox(height: 16),
          _buildTextField(_lastNameController, label: 'last_name'.tr(), icon: Icons.person, validator: (v) => v!.isEmpty ? 'name_required_error'.tr() : null),
          const SizedBox(height: 12),
          _buildTextField(_firstNameController, label: 'first_name_label'.tr(), icon: Icons.person, validator: (v) => v!.isEmpty ? 'first_name_required_error'.tr() : null),
          const SizedBox(height: 12),
          _buildTextField(_emailController,
              label: 'email_label'.tr(), icon: Icons.email, keyboardType: TextInputType.emailAddress, validator: (v) {
                if (v!.isEmpty) return 'email_required_error'.tr();
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) return 'invalid_email_error'.tr();
                return null;
              }),
          const SizedBox(height: 12),
          _buildTextField(_phoneController, label: 'phone_label'.tr(), icon: Icons.phone, keyboardType: TextInputType.phone, validator: (v) => v!.isEmpty ? 'phone_required_error'.tr() : null),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(_cityController, label: 'city_label'.tr(), icon: Icons.location_city, validator: (v) => v!.isEmpty ? 'city_required_error'.tr() : null),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final selectedCountry = await showCountryPicker(
                      context: context,
                      selectedCountry: _countryController.text,
                    );
                    if (selectedCountry != null) {
                      setState(() {
                        _countryController.text = selectedCountry.name;
                      });
                    }
                  },
                  child: AbsorbPointer(
                    child: _buildTextField(
                      _countryController,
                      label: 'country_label'.tr(),
                      icon: Icons.flag,
                      validator: (v) => v!.isEmpty ? 'country_required_error'.tr() : null,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(_zipCodeController, label: 'zip_code'.tr(), icon: Icons.local_post_office, keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? 'zip_code_required_error'.tr() : null),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(_addressController, label: 'address'.tr(), icon: Icons.location_on, validator: (v) => v!.isEmpty ? 'address_required_error'.tr() : null),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdultForm(Map<String, TextEditingController> controllers, int travelerIndex, int roomNumber) {
    final title = 'adult_title'.tr(args: [travelerIndex.toString()]);

    return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!)
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColorstatic.primary,
              ),
            ),
            const SizedBox(height: 16),

            // Gender selection radios
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: Text('gender_male_short'.tr()),
                    value: 'M.',
                    groupValue: controllers['title']!.text,
                    activeColor: AppColorstatic.primary2,
                    onChanged: (value) => setState(() {
                      controllers['title']!.text = value ?? 'M.';
                    }),
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: Text('gender_female_short'.tr()),
                    value: 'Mme',
                    groupValue: controllers['title']!.text,
                    activeColor: AppColorstatic.primary2,
                    onChanged: (value) => setState(() {
                      controllers['title']!.text = value ?? 'Mme';
                    }),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            _buildTextField(
              controllers['firstName']!,
              label: 'first_name_label'.tr(),
              icon: Icons.person,
              validator: (v) => v!.isEmpty ? 'first_name_required_error'.tr() : null,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controllers['lastName']!,
              label: 'last_name'.tr(),
              icon: Icons.person,
              validator: (v) => v!.isEmpty ? 'last_name_required_error'.tr() : null,
            ),
          ],
        )
    );
  }

  Widget _buildChildForm(Map<String, TextEditingController> controllers, int childIndex, int roomNumber) {
    final title = 'child_title'.tr(args: [childIndex.toString()]);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.child_care, color: Colors.blue[600], size: 20),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.blue[600])),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(controllers['firstName']!, label: 'first_name_label'.tr(), icon: Icons.person, validator: (v) => v!.isEmpty ? 'first_name_required_error'.tr() : null),
          const SizedBox(height: 12),
          _buildTextField(controllers['lastName']!, label: 'last_name'.tr(), icon: Icons.person, validator: (v) => v!.isEmpty ? 'last_name_required_error'.tr() : null),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTextField(controllers['age']!, label: 'age_label'.tr(), icon: Icons.cake, keyboardType: TextInputType.number, validator: (v) {
                  if (v!.isEmpty) return 'age_required_error'.tr();
                  final age = int.tryParse(v);
                  if (age == null || age < 0 || age > 12) return 'invalid_child_age_error'.tr();
                  return null;
                }),
              ),
            ],
          ),
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
            // Circuit summary card
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
                    'circuit_summary_title'.tr(),
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
                        '${widget.formData['start'] ?? widget.formData['startDate'] ?? ''} - ${widget.formData['end'] ?? widget.formData['endDate'] ?? ''}',
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
                        '${widget.formData['budget'] ?? '1000'} TND',
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

            // Form section with rooms
            Form(
              key: _formKey,
              child: Column(
                children: [
                  for (int roomIndex = 0; roomIndex < _adultsControllers.length; roomIndex++)
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
                              'adults': _adultsControllers[roomIndex].length.toString(),
                              'children': roomIndex < _childrenControllers.length
                                  ? _childrenControllers[roomIndex].length.toString()
                                  : '0',
                            }),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColorstatic.primary,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Adults section
                          if (_adultsControllers[roomIndex].isNotEmpty) ...[
                            for (int adultIndex = 0; adultIndex < _adultsControllers[roomIndex].length; adultIndex++)
                              _buildAdultForm(
                                _adultsControllers[roomIndex][adultIndex],
                                adultIndex + 1,
                                roomIndex + 1,
                              ),
                          ],

                          // Children section
                          if (roomIndex < _childrenControllers.length && _childrenControllers[roomIndex].isNotEmpty) ...[
                            const SizedBox(height: 16),
                            for (int childIndex = 0; childIndex < _childrenControllers[roomIndex].length; childIndex++)
                              _buildChildForm(
                                _childrenControllers[roomIndex][childIndex],
                                childIndex + 1,
                                roomIndex + 1,
                              ),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
            ),

            if (_error != null)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: TextStyle(color: Colors.red[600]),
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
                'confirm_reservation_button'.tr(
                  namedArgs: {
                    'price': (widget.formData['budget'] ?? '1000').toString(),
                    'currency': 'TND', // or get it dynamically from your data
                  },
                ),
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