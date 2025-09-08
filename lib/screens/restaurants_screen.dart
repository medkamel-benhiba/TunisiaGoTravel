import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/restaurant.dart';
import '../providers/restaurant_provider.dart';
import '../widgets/screen_title.dart';
import '../widgets/restaurant/restaurant_card.dart';
import '../widgets/destinations_list.dart';

class RestaurantsScreenContent extends StatefulWidget {
  const RestaurantsScreenContent({super.key});

  @override
  State<RestaurantsScreenContent> createState() =>
      _RestaurantsScreenState();
}

class _RestaurantsScreenState extends State<RestaurantsScreenContent> {
  String? selectedDestinationId;
  String? selectedDestinationTitle;

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
            padding:
            const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
            child: ScreenTitle(
              icon: selectedDestinationId == null
                  ? Icons.location_on
                  : Icons.restaurant,
              title: selectedDestinationId == null
                  ? 'Destinations'
                  : 'Restaurants à $selectedDestinationTitle',
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
                // Optional: update provider's current restaurants list
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
      return const Center(
          child: Text('Aucun restaurant disponible pour cette destination'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: restaurants.length,
      itemBuilder: (context, index) {
        return RestaurantCard(restaurant: restaurants[index]);
      },
    );
  }
}