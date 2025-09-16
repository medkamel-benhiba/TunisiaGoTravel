import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/destination.dart';
import '../providers/destination_provider.dart';
import 'destination_card.dart';

enum DestinationsViewType { list, grid }

class DestinationsList extends StatelessWidget {
  final void Function(Destination) onDestinationSelected;
  final DestinationsViewType viewType;
  final String? category;

  const DestinationsList({
    super.key,
    required this.onDestinationSelected,
    this.viewType = DestinationsViewType.grid,
    this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<DestinationProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(
            child: Text(tr('destinations.error', args: [provider.error!])),
          );
        }

        if (provider.destinations.isEmpty) {
          return Center(child: Text(tr('destinations.empty')));
        }

        final destinations = category == null
            ? provider.destinations
            : provider.destinations.toList();

        if (destinations.isEmpty) {
          return Center(
            child: Text(tr('destinations.empty_category', args: [category!])),
          );
        }

        if (viewType == DestinationsViewType.list) {
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            physics: const BouncingScrollPhysics(),
            itemCount: destinations.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final destination = destinations[index];
              return DestinationCard(
                destination: destination,
                onTap: () => onDestinationSelected(destination),
              );
            },
          );
        }

        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = 2;
              double width = constraints.maxWidth;

              if (width >= 1200) {
                crossAxisCount = 4;
              } else if (width >= 800) {
                crossAxisCount = 3;
              }

              double childAspectRatio = (width / crossAxisCount) / 260;

              return GridView.builder(
                itemCount: destinations.length,
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: childAspectRatio,
                ),
                itemBuilder: (context, index) {
                  final destination = destinations[index];
                  return DestinationCard(
                    destination: destination,
                    onTap: () => onDestinationSelected(destination),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
