import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tunisiagotravel/providers/destination_provider.dart';
import '../models/restaurant.dart';
import '../providers/restaurant_provider.dart';
import '../widgets/screen_title.dart';
import '../widgets/restaurant/restaurant_card.dart';
import '../widgets/destinations_list.dart';

class RestaurantsScreenContent extends StatefulWidget {
  final String? initialDestinationId;
  const RestaurantsScreenContent({super.key, this.initialDestinationId});

  @override
  State<RestaurantsScreenContent> createState() =>
      _RestaurantsScreenState();
}

class _RestaurantsScreenState extends State<RestaurantsScreenContent> {
  String? selectedDestinationId;
  String? selectedDestinationTitle;

  @override
  void initState() {
    super.initState();
    if (widget.initialDestinationId != null) {
      selectedDestinationId = widget.initialDestinationId;
      // Update provider's current restaurants list
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<RestaurantProvider>(context, listen: false)
            .setRestaurantsByDestination(widget.initialDestinationId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RestaurantProvider>(context);

    // Filter restaurants by selected destination from cache
    final filteredRestaurants = selectedDestinationId != null
        ? provider.getRestaurantsByDestination(selectedDestinationId!)
        : <Restaurant>[];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Screen title
          Padding(
            padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0.0),
            child: Builder(builder: (context) {
              final destinationProvider =
              Provider.of<DestinationProvider>(context, listen: false);

              // Get the localized destination name if selected
              String displayDestination = '';
              if (selectedDestinationId != null) {
                displayDestination = destinationProvider
                    .getDestinationName(selectedDestinationId!, context.locale);
              }

              return ScreenTitle(
                icon: selectedDestinationId == null
                    ? Icons.location_on
                    : Icons.restaurant,
                title: selectedDestinationId == null
                    ? 'restaurantsScreen.destinations'.tr()
                    : 'restaurantsScreen.restaurantsInDestination'.tr(
                  args: [displayDestination],
                ),
              );
            }),
          ),

          // Back button
          if (selectedDestinationId != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        selectedDestinationId = null;
                        selectedDestinationTitle = null;
                      });
                    },
                    icon: const Icon(Icons.arrow_back, size: 16),
                    label: Text('restaurantsScreen.destinations'.tr()),
                  ),
                ],
              ),
            ),

          // Main content: Destinations list or filtered restaurants
          Expanded(
            child: selectedDestinationId == null
                ? DestinationsList(
              onDestinationSelected: (destination) {
                setState(() {
                  selectedDestinationId = destination.id;
                  selectedDestinationTitle = destination.name;
                });
                // Update provider's current restaurants list
                provider.setRestaurantsByDestination(destination.id);
              },
            )
                : _buildRestaurants(filteredRestaurants, provider.isLoading),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurants(List<Restaurant> restaurants, bool isLoading) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (restaurants.isEmpty) {
      return Center(
        child: Text(
          'restaurantsScreen.noRestaurants'.tr(),
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 12.0),
      itemCount: restaurants.length,
      itemBuilder: (context, index) {
        return RestaurantCard(restaurant: restaurants[index]);
      },
    );
  }
}