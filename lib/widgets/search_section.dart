import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:tunisiagotravel/theme/color.dart';
import '../providers/global_provider.dart';
import '../providers/hotel_provider.dart';
import 'drop_section/destination_drop_section.dart';

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
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return SizedBox(
      height: screenHeight * 0.55,
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
                  const Text(
                    'Où partez-vous ?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),

                InkWell(
                    onTap: () async {
                      final result = await showDialog<Map<String, dynamic>>(
                        context: context,
                        builder: (context) => Dialog(
                          insetPadding: const EdgeInsets.all(16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.5,
                            child: DestinationDropSection(
                              onSearchComplete: (searchResult) {
                                setState(() {
                                  _selectedCityId = searchResult['destinationId'];
                                  _selectedCityName = searchResult['destinationName'];
                                });
                                Navigator.of(context).pop(searchResult); // closes the dialog
                              },
                            ),
                          ),
                        ),
                      );

                      if (result != null) {
                        setState(() {
                          _selectedCityId = result['destinationId'];
                          _selectedCityName = result['destinationName'];
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on_outlined, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            _selectedCityName ?? 'Choisissez votre destination',
                            style: TextStyle(
                              color: _selectedCityName != null ? Colors.black87 : Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.arrow_drop_down, color: Colors.grey),
                        ],
                      ),
                    ),
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
                          globalProvider.setSelectedCityForHotels(_selectedCityName!);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Veuillez sélectionner une ville'),
                            ),
                          );
                        }
                      },
                      child: const Text('Rechercher'),
                    ),
                  ),

                  const SizedBox(height: 30),
                  SizedBox(
                    height: screenHeight * 0.26,
                    width: screenWidth * 0.9,
                    child: SvgPicture.asset(
                      'assets/images/map.svg',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Ouvrir la carte',
                    style: TextStyle(color: Colors.white, fontSize: 14),
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
