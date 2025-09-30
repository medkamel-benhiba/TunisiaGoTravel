import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import '../providers/global_provider.dart';
import '../theme/color.dart';
import '../widgets/menu_card.dart';
import '../widgets/search_section.dart';
import '../widgets/chatbot_overlay.dart';

class HomeScreenContent extends StatefulWidget {
  const HomeScreenContent({super.key});

  @override
  State<HomeScreenContent> createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  @override
  Widget build(BuildContext context) {
    final menuItems = [
      {'title': tr('circuits'), 'image': 'assets/images/card/circuit.jpg', 'color': AppColorstatic.primary, 'page': AppPage.circuits},
      {'title': tr('guide'), 'image': 'assets/images/card/guide.jpg', 'color': AppColorstatic.primary, 'page': AppPage.guide},
      {'title': tr('hotels'), 'image': 'assets/images/card/hotel.png', 'color': AppColorstatic.secondary, 'page': AppPage.hotels},
      {'title': tr('guestHouses'), 'image': 'assets/images/card/maisondhote.png', 'color': AppColorstatic.secondary, 'page': AppPage.maisonsHotes},
      {'title': tr('restaurants'), 'image': 'assets/images/card/resterant.png', 'color': AppColorstatic.primary2, 'page': AppPage.restaurants},
      {'title': tr('events'), 'image': 'assets/images/card/event.png', 'color': AppColorstatic.primary2, 'page': AppPage.evenement},
      {'title': tr('activities'), 'image': 'assets/images/card/activite.png', 'color': AppColorstatic.secondary, 'page': AppPage.activites},
      {'title': tr('transport'), 'image': 'assets/images/card/transport.png', 'color': AppColorstatic.secondary},
      {'title': tr('cultures'), 'image': 'assets/images/card/cultures.png', 'color': AppColorstatic.primary, 'page': AppPage.cultures},
      {'title': tr('handicraft'), 'image': 'assets/images/card/artisanat.png', 'color': AppColorstatic.primary, 'page': AppPage.cultures, 'initialCategory': 'artisanat'},
    ];

    return Stack(
      children: [
        ListView(
          children: [
            const SearchSection(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1.1,
                ),
                itemCount: menuItems.length,
                itemBuilder: (context, index) {
                  final item = menuItems[index];
                  return MenuCard(
                    title: item['title'] as String,
                    imagePath: item['image'] as String,
                    backgroundColor: item['color'] as Color,
                    onTap: item.containsKey('page')
                        ? () {
                      final provider = Provider.of<GlobalProvider>(context, listen: false);
                      provider.setPage(item['page'] as AppPage);
                      if (item['page'] == AppPage.cultures &&
                          item.containsKey('initialCategory')) {
                        provider.setCulturesInitialCategory(item['initialCategory'] as String?);
                      }
                    }
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
        // Chatbot overlay component
        const ChatbotOverlay(),
      ],
    );
  }
}