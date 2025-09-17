import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tunisiagotravel/theme/color.dart';
import '../../providers/destination_provider.dart';

class CityDropdown extends StatelessWidget {
  final String label;
  final String? selectedValue;
  final String? selectedId;
  final Function(String? name, String? id) onChanged;

  const CityDropdown({
    super.key,
    required this.label,
    this.selectedValue,
    this.selectedId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);

    return Consumer<DestinationProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return _buildDropdownField(
            context,
            enabled: false,
            child: Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                    AlwaysStoppedAnimation<Color>(AppColorstatic.primary),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'loading_destinations'.tr(),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        if (provider.error != null) {
          return _buildDropdownField(
            context,
            enabled: false,
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'error_loading'.tr(),
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                TextButton(
                  onPressed: () => provider.fetchDestinations(),
                  child: Text(
                    'retry'.tr(),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColorstatic.primary,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (provider.destinations.isEmpty) {
          return _buildDropdownField(
            context,
            enabled: false,
            child: Row(
              children: [
                Icon(Icons.location_off, color: Colors.grey, size: 16),
                SizedBox(width: 8),
                Text(
                  'no_destinations'.tr(),
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return Theme(
          data: Theme.of(context).copyWith(
            scrollbarTheme: ScrollbarThemeData(
              thumbColor: MaterialStateProperty.all(AppColorstatic.primary),
              trackColor: MaterialStateProperty.all(
                  AppColorstatic.primary.withOpacity(0.5)),
              thumbVisibility: MaterialStateProperty.all(true),
              trackVisibility: MaterialStateProperty.all(true),
              thickness: MaterialStateProperty.all(8.0),
              radius: const Radius.circular(30),
            ),
          ),
          child: SizedBox(
            width: double.infinity,
            child: DropdownButtonFormField<String>(
              value: selectedId,
              decoration: InputDecoration(
                labelText: label,
                prefixIcon: const Icon(Icons.location_on, size: 20, color: AppColorstatic.primary),
                filled: true,
                fillColor: AppColorstatic.cardColor,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              ),
              items: provider.destinations
                  .map((d) => DropdownMenuItem(
                value: d.id, // unique ID
                child: Text(d.getName(locale)),
              ))
                  .toList(),
              onChanged: (id) {
                final selectedDestination = provider.destinations.firstWhere((d) => d.id == id);
                onChanged(selectedDestination.getName(locale), selectedDestination.id);
              },
              menuMaxHeight: 250,
            )

          ),
        );
      },
    );
  }

  Widget _buildDropdownField(BuildContext context,
      {required bool enabled, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: enabled ? AppColorstatic.cardColor : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: enabled ? Colors.transparent : Colors.grey[300]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColorstatic.mainColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
