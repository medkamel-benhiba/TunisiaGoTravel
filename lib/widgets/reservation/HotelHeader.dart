import 'package:flutter/material.dart';
import '../../models/mouradi.dart';

class HotelHeader extends StatelessWidget {
  final MouradiHotel hotel;

  const HotelHeader({super.key, required this.hotel});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                hotel.image ?? "",
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.hotel, size: 50, color: Colors.grey),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hotel.star != null)
                  Row(
                    children: List.generate(
                      hotel.star!,
                          (index) => const Icon(Icons.star, color: Colors.amber, size: 16),
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  hotel.name,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  hotel.cityName,
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


/*import 'package:flutter/material.dart';
import 'package:tunisiagotravel/models/hotel.dart';

class HotelHeader extends StatelessWidget {
  final Hotel hotel;
  const HotelHeader({super.key, required this.hotel});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                hotel.cover,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: const Icon(Icons.hotel, size: 50, color: Colors.grey),
                  );
                },
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hotel.categoryCode != null)
                  Row(
                    children: List.generate(
                      hotel.categoryCode!,
                          (index) => const Icon(Icons.star, color: Colors.amber, size: 16),
                    ),
                  ),
                const SizedBox(height: 4),
                Text(
                  hotel.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  hotel.address,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}*/