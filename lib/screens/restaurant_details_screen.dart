import 'package:flutter/material.dart';
import 'package:tunisiagotravel/theme/color.dart';
import '../../models/restaurant.dart';
import '../widgets/gallery.dart';
import '../widgets/restaurant/restaurant_contact_card.dart';
import '../widgets/restaurant/restaurant_description_card.dart';
import '../widgets/restaurant/restaurant_info_card.dart';

class RestaurantDetailsScreen extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantDetailsScreen({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          restaurant.name,
          style: const TextStyle(
            color: AppColorstatic.lightTextColor,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: AppColorstatic.primary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (restaurant.images.isNotEmpty)
              ImageGridPreview(images: restaurant.images),
            const SizedBox(height: 12),
            RestaurantInfoCard(restaurant: restaurant),
            RestaurantDescriptionCard(restaurant: restaurant),
            RestaurantContactCard(restaurant: restaurant),
          ],
        ),
      ),
    );
  }
}
