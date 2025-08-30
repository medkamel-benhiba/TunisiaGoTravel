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
    return Consumer<DestinationProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(child: Text('Erreur: ${provider.error}'));
        }

        if (provider.destinations.isEmpty) {
          return const Text('Aucune destination disponible');
        }

        return Theme(
          data: Theme.of(context).copyWith(
            scrollbarTheme: ScrollbarThemeData(
              thumbColor: MaterialStateProperty.all(AppColorstatic.primary),
              trackColor: MaterialStateProperty.all(AppColorstatic.primary.withOpacity(0.5)),
              thumbVisibility: MaterialStateProperty.all(true),
              trackVisibility: MaterialStateProperty.all(true),
              thickness: MaterialStateProperty.all(8.0),
              radius: const Radius.circular(30),
            ),
          ),
          child: SizedBox(
            width: double.infinity,
            child: DropdownButtonFormField<String>(
              value: selectedValue,
              decoration: InputDecoration(
                labelText: label,
                labelStyle: const TextStyle(fontSize: 12, color: AppColorstatic.mainColor),
                filled: true,
                fillColor: AppColorstatic.cardColor ,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: provider.destinations
                  .map((d) => DropdownMenuItem(
                value: d.name,
                child: Text(d.name),
              ))
                  .toList(),
              onChanged: (value) {
                final selectedDestination = provider.destinations.firstWhere(
                      (d) => d.name == value,
                  orElse: () => provider.destinations.first,
                );
                onChanged(selectedDestination.name, selectedDestination.id);
              },
              menuMaxHeight: 250,
            ),
          ),
        );
      },
    );
  }
}
