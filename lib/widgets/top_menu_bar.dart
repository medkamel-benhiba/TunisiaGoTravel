import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/global_provider.dart';
import '../screens/map_screen.dart';
import '../theme/color.dart';
import '../theme/styletext.dart';
import 'drop_section/destination_drop_section.dart';

class TopMenuBar1 extends StatefulWidget {
  const TopMenuBar1({super.key});

  @override
  State<TopMenuBar1> createState() => _TopMenuBar1State();
}

class _TopMenuBar1State extends State<TopMenuBar1> {
  bool isDestinationOpen = false;

  void toggleDestination() {
    setState(() {
      isDestinationOpen = !isDestinationOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GlobalProvider>(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        double iconButtonHeight = constraints.maxWidth < 600 ? 40 : 48;
        double horizontalPadding = constraints.maxWidth < 600 ? 6 : 8;
        double spacing = constraints.maxWidth < 600 ? 6 : 8;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // First Row
            Container(
              color: AppColorstatic.primary,
              padding: EdgeInsets.symmetric(
                  vertical: horizontalPadding, horizontal: horizontalPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: toggleDestination,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding,
                              vertical: horizontalPadding),
                          height: iconButtonHeight,
                          decoration: BoxDecoration(
                            color: AppColorstatic.secondary,
                            border: const Border(
                              left:
                              BorderSide(color: AppColorstatic.primary2, width: 3),
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              Text(
                                "Destination",
                                style: Appstylestatic.textStyletitle2,
                              ),
                              Icon(
                                isDestinationOpen
                                    ? Icons.arrow_drop_up
                                    : Icons.arrow_drop_down,
                                color: Colors.orange,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: spacing),
                      GestureDetector(
                        onTap: () {
                          provider.setPage(AppPage.circuits);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding,
                              vertical: horizontalPadding),
                          height: iconButtonHeight,
                          decoration: BoxDecoration(
                            color: AppColorstatic.secondary,
                            border: const Border(
                              left:
                              BorderSide(color: AppColorstatic.primary2, width: 3),
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              Text(
                                "Circuits",
                                style: Appstylestatic.textStyletitle2,
                              ),
                              const Icon(
                                Icons.arrow_drop_down,
                                color: Colors.orange,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Right buttons
                  Row(
                    children: [
                      Container(
                        height: iconButtonHeight,
                        width: iconButtonHeight,
                        decoration: BoxDecoration(
                          color: AppColorstatic.secondary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.chat_outlined, color: Colors.white),
                          onPressed: () {
                            provider.setPage(AppPage.chatbot);

                          },
                        ),
                      ),
                      SizedBox(width: spacing),
                      Container(
                        height: iconButtonHeight,
                        width: iconButtonHeight,
                        decoration: BoxDecoration(
                          color: AppColorstatic.secondary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.account_circle, color: Colors.white),
                          onPressed: () {
                            provider.setPage(AppPage.login);
                          },
                        ),
                      ),

                    ],
                  ),
                ],
              ),
            ),

            // Destination dropdown
            if (isDestinationOpen) ...[
              Container(
                color: AppColorstatic.white80,
                child: const DestinationDropSection(),
              ),
            ],

            // Second row
            const TopMenuBar2(),
          ],
        );
      },
    );
  }
}

class TopMenuBar2 extends StatelessWidget {
  const TopMenuBar2({super.key});

  PopupMenuItem<AppPage> _buildStyledMenuItem(
      AppPage value, String text, double width) {
    return PopupMenuItem<AppPage>(
      value: value,
      child: SizedBox(
        child: Row(
          children: [
            const Icon(Icons.arrow_right, color: AppColorstatic.yellow),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: AppColorstatic.lightTextColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<GlobalProvider>(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        double boxHeight = constraints.maxWidth < 600 ? 40 : 48;
        double spacing = constraints.maxWidth < 600 ? 4 : 4;
        final double menuWidth = constraints.maxWidth - (boxHeight * 2 + spacing * 2);

        return Container(
          color: AppColorstatic.primary,
          padding: EdgeInsets.symmetric(vertical: spacing, horizontal: spacing),
          child: Row(
            children: [
              Container(
                height: boxHeight,
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: const BoxDecoration(
                  color: AppColorstatic.secondary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(6),
                    bottomLeft: Radius.circular(6),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.white, size: 24),
                    SizedBox(width: 6),
                    Text(
                      "Tunisie",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              SizedBox(width: spacing),

              Expanded(
                child: SizedBox(
                  height: boxHeight,
                  child: PopupMenuButton<AppPage>(
                    color: AppColorstatic.secondary,
                    elevation: 7,
                    offset: Offset(0, boxHeight),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    onSelected: (value) {
                      provider.setPage(value);
                      if (value == AppPage.hotels) {
                        provider.setSelectedCityForHotels(null);
                      }
                    },
                    itemBuilder: (_) => [
                      _buildStyledMenuItem(AppPage.home, 'Accueil', menuWidth),
                      _buildStyledMenuItem(AppPage.hotels, 'Hôtels', menuWidth),
                      _buildStyledMenuItem(AppPage.restaurants, 'Restaurants', menuWidth),
                      _buildStyledMenuItem(AppPage.maisonsHotes, "Maison d'hôtes", menuWidth),
                      _buildStyledMenuItem(AppPage.activites, "Activités", menuWidth),
                      _buildStyledMenuItem(AppPage.evenement, "Événement", menuWidth),
                      _buildStyledMenuItem(AppPage.circuits, 'Tous les circuits', menuWidth),
                      _buildStyledMenuItem(AppPage.circuitsPredefini, 'Circuits prédéfini', menuWidth),
                      _buildStyledMenuItem(AppPage.circuitsManuel, 'Circuit Manuel', menuWidth),
                      _buildStyledMenuItem(AppPage.circuitsAuto, 'Circuit Automatique', menuWidth),
                      _buildStyledMenuItem(AppPage.cultures, 'Cultures', menuWidth),
                      _buildStyledMenuItem(AppPage.agil, 'Agil', menuWidth),
                      _buildStyledMenuItem(AppPage.guide, 'Guide', menuWidth),
                    ],
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: const BoxDecoration(color: AppColorstatic.secondary),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _getPageLabel(provider.currentPage),
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500),
                          ),
                          const Icon(Icons.arrow_drop_down, color: Colors.white, size: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(width: spacing),

              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MapScreen()),
                  );
                },
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(6),
                  bottomRight: Radius.circular(6),
                ),
                child: Container(
                  height: boxHeight,
                  width: boxHeight,
                  decoration: const BoxDecoration(
                    color: AppColorstatic.secondary,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(6),
                      bottomRight: Radius.circular(6),
                    ),
                  ),
                  child: const Icon(Icons.map_outlined, color: Colors.white, size: 28),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

String _getPageLabel(AppPage page) {
  switch (page) {
    case AppPage.home:
      return 'Accueil';
    case AppPage.hotels:
      return 'Hôtels';
    case AppPage.restaurants:
      return 'Restaurants';
    case AppPage.maisonsHotes:
      return "Maison d'hôtes";
    case AppPage.activites:
      return "Activités";
    case AppPage.evenement:
      return "Événement";
    case AppPage.circuits:
      return 'Circuits';
    case AppPage.circuitsPredefini:
      return 'Circuits prédéfini';
    case AppPage.circuitsManuel:
      return 'Circuits Manuel';
    case AppPage.circuitsAuto:
      return 'Circuits Automatique';
    case AppPage.cultures:
      return 'Cultures';
    case AppPage.agil:
      return 'Agil';
    case AppPage.guide:
      return 'Guide';
    case AppPage.login:
      return "Connexion";
    case AppPage.signup:
      return "Connexion";
    case AppPage.chatbot:
      return "ChatBot";

  }
}
