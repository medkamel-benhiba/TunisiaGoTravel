import 'package:flutter/material.dart';
import '../../models/restaurant.dart';
import '../screens/restaurant_details_screen.dart';

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantCard({super.key, required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RestaurantDetailsScreen(restaurant: restaurant),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: restaurant.cover != null
                  ? Image.network(
                restaurant.cover!,
                height: 140,
                width: double.infinity,
                fit: BoxFit.cover,
              )
                  : Container(
                height: 140,
                color: Colors.grey[300],
                child: const Icon(Icons.restaurant, size: 50),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (restaurant.crtDescription != null)
                    Row(
                      children: [
                        Expanded(
                          child: restaurant.crtDescription != null && restaurant.crtDescription!.isNotEmpty
                              ? Text(
                            restaurant.crtDescription!,
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          )
                              : Row(
                            children: [
                              const Icon(Icons.location_on, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  restaurant.address ?? '',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),


                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.orange),
                          const SizedBox(width: 4),
                          Text(
                            restaurant.rate != null
                                ? (restaurant.rate! as num).toDouble().toStringAsFixed(1)
                                : 'N/A',
                            style: const TextStyle(fontSize: 12),
                          ),

                        ],
                      ),

                      if (restaurant.startingPrice != null)
                        Text(
                          'À partir de ${restaurant.startingPrice} TND',
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
