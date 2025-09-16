import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../models/restaurant.dart';
import '../../theme/color.dart';
import '../../services/api_service.dart';
import '../widgets/base_card.dart';

class RestaurantReservationScreen extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantReservationScreen({super.key, required this.restaurant});

  @override
  State<RestaurantReservationScreen> createState() =>
      _RestaurantReservationScreenState();
}

class _RestaurantReservationScreenState
    extends State<RestaurantReservationScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _countryController =
  TextEditingController(text: "Tunisia");
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _numberOfPeople = 1;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    // Set default country based on locale
    _countryController.text = 'default_country'.tr();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _submitReservation() async {
    if (!_formKey.currentState!.validate()) {
      _showValidationError();
      return;
    }

    if (_selectedDate == null) {
      _showSnackBar('please_select_date'.tr(), isError: true);
      return;
    }

    if (_selectedTime == null) {
      _showSnackBar('please_select_time'.tr(), isError: true);
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final apiService = ApiService();

      final response = await apiService.postreservationrestau(
        widget.restaurant.id,
        DateFormat('yyyy-MM-dd').format(_selectedDate!),
        _selectedTime!.format(context),
        _numberOfPeople.toString(),
        _nameController.text,
        _emailController.text,
        _phoneController.text,
        _countryController.text,
        _cityController.text,
      );

      if (response.success) {
        _showSnackBar('reservation_confirmed'.tr(), isError: false);
        await Future.delayed(const Duration(seconds: 1));
        Navigator.pop(context, true);
      } else {
        _showSnackBar('reservation_failed'.tr(), isError: true);
      }
    } catch (e) {
      _showSnackBar('${'connection_error'.tr()}: ${e.toString()}', isError: true);
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red[600] : Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showValidationError() {
    _showSnackBar('please_fill_required_fields'.tr(), isError: true);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColorstatic.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColorstatic.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Widget _buildAnimatedTextField({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    IconData? prefixIcon,
    Function(String)? onChanged,
    String? initialValue,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: initialValue == null ? controller : null,
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppColorstatic.primary) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColorstatic.primary, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        keyboardType: keyboardType,
        validator: validator,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDateTimeButton({
    required String text,
    required VoidCallback onPressed,
    required IconData icon,
    bool isSelected = false,
  }) {
    return Expanded(
      child: Container(
        height: 56,
        child: OutlinedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, color: isSelected ? Colors.white : AppColorstatic.primary),
          label: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : AppColorstatic.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: OutlinedButton.styleFrom(
            backgroundColor: isSelected ? AppColorstatic.primary : Colors.transparent,
            side: BorderSide(color: AppColorstatic.primary, width: 2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.locale;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'reserve_restaurant'.tr(),
          style: const TextStyle(
            color: AppColorstatic.lightTextColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColorstatic.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: BaseCard(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColorstatic.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.restaurant_menu,
                          size: 18,
                          color: AppColorstatic.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.restaurant.getName(locale),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'reservation_form_description'.tr(),
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Personal Information Section
                  Row(
                    children: [
                      Icon(Icons.person_outline, color: AppColorstatic.primary2, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'personal_information'.tr(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildAnimatedTextField(
                    controller: _nameController,
                    label: 'full_name'.tr(),
                    prefixIcon: Icons.person,
                    validator: (v) => v == null || v.isEmpty ? 'field_required'.tr() : null,
                  ),

                  _buildAnimatedTextField(
                    controller: _emailController,
                    label: 'email'.tr(),
                    prefixIcon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'field_required'.tr();
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
                        return 'invalid_email'.tr();
                      }
                      return null;
                    },
                  ),

                  _buildAnimatedTextField(
                    controller: _phoneController,
                    label: 'phone'.tr(),
                    prefixIcon: Icons.phone,
                    keyboardType: TextInputType.phone,
                    validator: (v) => v == null || v.isEmpty ? 'field_required'.tr() : null,
                  ),

                  Row(
                    children: [
                      Expanded(
                        child: _buildAnimatedTextField(
                          controller: _cityController,
                          label: 'city'.tr(),
                          prefixIcon: Icons.location_city,
                          validator: (v) => v == null || v.isEmpty ? 'field_required'.tr() : null,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildAnimatedTextField(
                          controller: _countryController,
                          label: 'country'.tr(),
                          prefixIcon: Icons.flag,
                          validator: (v) => v == null || v.isEmpty ? 'field_required'.tr() : null,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Reservation Details Section
                  Row(
                    children: [
                      Icon(Icons.schedule, color: AppColorstatic.primary2, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'reservation_details'.tr(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      _buildDateTimeButton(
                        text: _selectedDate != null
                            ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                            : 'choose_date'.tr(),
                        onPressed: _pickDate,
                        icon: Icons.calendar_today,
                        isSelected: _selectedDate != null,
                      ),
                      const SizedBox(width: 12),
                      _buildDateTimeButton(
                        text: _selectedTime != null
                            ? _selectedTime!.format(context)
                            : 'choose_time'.tr(),
                        onPressed: _pickTime,
                        icon: Icons.access_time,
                        isSelected: _selectedTime != null,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  _buildAnimatedTextField(
                    initialValue: _numberOfPeople.toString(),
                    controller: TextEditingController(),
                    label: 'number_of_people'.tr(),
                    prefixIcon: Icons.group,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'field_required'.tr();
                      final num = int.tryParse(v);
                      if (num == null || num < 1) return 'invalid_number'.tr();
                      if (num > 20) return 'maximum_20_people'.tr();
                      return null;
                    },
                    onChanged: (v) {
                      final n = int.tryParse(v) ?? 1;
                      setState(() => _numberOfPeople = n);
                    },
                  ),

                  const SizedBox(height: 24),

                  // Submit Button
                  Container(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitReservation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColorstatic.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: _isSubmitting ? 0 : 4,
                        shadowColor: AppColorstatic.primary.withOpacity(0.3),
                      ),
                      child: _isSubmitting
                          ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'reservation_in_progress'.tr(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                          : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_outline, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            'confirm_reservation'.tr(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Terms notice
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'terms_notice'.tr(),
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}