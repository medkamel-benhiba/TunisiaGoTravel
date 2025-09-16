import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import 'circuits/city_dropdown.dart';
import '../providers/global_provider.dart';
import '../screens/map_screen.dart';
import '../theme/color.dart';

class SearchSection extends StatefulWidget {
  const SearchSection({super.key});

  @override
  State<SearchSection> createState() => _SearchSectionState();
}

class _SearchSectionState extends State<SearchSection> {
  String? _selectedCityName;
  String? _selectedCityId;

  @override
  Widget build(BuildContext context) {
    // Read locale to trigger rebuild when language changes
    final locale = context.locale;

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      height: screenHeight * 0.57,
      width: double.infinity,
      child: Stack(
        children: [
          // Background image
          SizedBox(
            width: double.infinity,
            child: Image.asset(
              'assets/images/back1.png',
              fit: BoxFit.cover,
            ),
          ),
          // Blur overlay
          Positioned.fill(
            top: 10,
            bottom: 10,
            left: 10,
            right: 10,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                ),
              ),
            ),
          ),
          // Content
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    tr('whereAreYouGoing'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),

                  CityDropdown(
                    label: tr('chooseDestination'),
                    onChanged: (name, id) {
                      setState(() {
                        _selectedCityName = name;
                        _selectedCityId = id;
                      });
                    },
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColorstatic.secondary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        if (_selectedCityName != null) {
                          final globalProvider =
                          Provider.of<GlobalProvider>(context, listen: false);
                          globalProvider.setPage(AppPage.hotels);
                          globalProvider.setAvailableHotels([]);
                          globalProvider.setSelectedCityForHotels(_selectedCityName!);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(tr('selectCity')),
                            ),
                          );
                        }
                      },
                      child: Text(tr('search')),
                    ),
                  ),

                  const SizedBox(height: 20),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MapScreen()),
                      );
                    },
                    child: Column(
                      children: [
                        SizedBox(
                          height: screenHeight * 0.26,
                          width: screenWidth * 0.8,
                          child: SvgPicture.asset(
                            'assets/images/map.svg',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          tr('openMap'),
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
