import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tunisiagotravel/widgets/language_switch/language_selector.dart';
import 'package:tunisiagotravel/widgets/search/destination_drop_section.dart';
import '../providers/global_provider.dart';
import '../screens/map_screen.dart';
import '../theme/color.dart';
import '../theme/styletext.dart';

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
    final locale = context.locale;


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
                              horizontal: horizontalPadding, vertical: horizontalPadding),
                          height: iconButtonHeight,
                          decoration: BoxDecoration(
                            color: isDestinationOpen ? Colors.white : AppColorstatic.secondary,
                            border: const Border(
                              left: BorderSide(color: AppColorstatic.primary2, width: 3),
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              Text(
                                'destination_title'.tr(),
                                style: Appstylestatic.textStyletitle2.copyWith(
                                  color: isDestinationOpen ? AppColorstatic.secondary : Appstylestatic.textStyletitle2.color,
                                ),
                              ),
                              Icon(
                                isDestinationOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
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
                                'circuits'.tr(), // Changed from hardcoded "Circuits"
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
                child: DestinationDropSection(
                    onSearchComplete: () {
                      setState(() {
                        isDestinationOpen= false;
                      });
                    },
                ),
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
    final locale = context.locale;


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
              LanguageSelector(showInTopMenu: true, height: boxHeight),      //////////////////////////////tunisie button
              /*Container(
                height: boxHeight,
                padding: EdgeInsets.symmetric(horizontal: 12),
                decoration: const BoxDecoration(
                  color: AppColorstatic.secondary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(6),
                    bottomLeft: Radius.circular(6),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.white, size: 24),
                    const SizedBox(width: 6),
                    Text(
                      'tunisia'.tr(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),*/
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
                      _buildStyledMenuItem(AppPage.home, 'home'.tr(), menuWidth), // Changed
                      _buildStyledMenuItem(AppPage.hotels, 'hotels'.tr(), menuWidth), // Changed
                      _buildStyledMenuItem(AppPage.restaurants, 'restaurants'.tr(), menuWidth), // Changed
                      _buildStyledMenuItem(AppPage.maisonsHotes, 'guestHouses'.tr(), menuWidth), // Changed
                      _buildStyledMenuItem(AppPage.activites, 'activities'.tr(), menuWidth), // Changed
                      _buildStyledMenuItem(AppPage.evenement, 'events'.tr(), menuWidth), // Changed
                      _buildStyledMenuItem(AppPage.circuits, 'allCircuits'.tr(), menuWidth), // Changed
                      _buildStyledMenuItem(AppPage.circuitsPredefini, 'predefinedCircuits'.tr(), menuWidth), // Changed
                      _buildStyledMenuItem(AppPage.circuitsManuel, 'manualCircuit'.tr(), menuWidth), // Changed
                      _buildStyledMenuItem(AppPage.circuitsAuto, 'automaticCircuit'.tr(), menuWidth), // Changed
                      _buildStyledMenuItem(AppPage.cultures, 'cultures'.tr(), menuWidth), // Changed
                      _buildStyledMenuItem(AppPage.agil, 'agil'.tr(), menuWidth), // Changed
                      _buildStyledMenuItem(AppPage.guide, 'guide'.tr(), menuWidth), // Changed
                    ],
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      decoration: const BoxDecoration(color: AppColorstatic.secondary),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _getPageLabel(provider.currentPage, context), // Modified to accept context
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

// Updated function to use translations
String _getPageLabel(AppPage page, BuildContext context) {
  switch (page) {
    case AppPage.home:
      return 'home'.tr();
    case AppPage.hotels:
      return 'hotels'.tr();
    case AppPage.restaurants:
      return 'restaurants'.tr();
    case AppPage.maisonsHotes:
      return 'guestHouses'.tr();
    case AppPage.activites:
      return 'activities'.tr();
    case AppPage.evenement:
      return 'events'.tr();
    case AppPage.circuits:
      return 'circuits'.tr();
    case AppPage.circuitsPredefini:
      return 'predefinedCircuits'.tr();
    case AppPage.circuitsManuel:
      return 'manualCircuit'.tr();
    case AppPage.circuitsAuto:
      return 'automaticCircuit'.tr();
    case AppPage.cultures:
      return 'cultures'.tr();
    case AppPage.agil:
      return 'agil'.tr();
    case AppPage.guide:
      return 'guide'.tr();
    case AppPage.login:
      return 'connection'.tr();
    case AppPage.signup:
      return 'connection'.tr();
    case AppPage.chatbot:
      return 'chatbot_title'.tr();
    case AppPage.stateScreenDetails:
      return 'stateScreenDetails'.tr();

  }

}