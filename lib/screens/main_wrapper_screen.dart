import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tunisiagotravel/screens/activities_screen.dart';
import 'package:tunisiagotravel/screens/agil_screen.dart';
import 'package:tunisiagotravel/screens/circuit_predifini_screen.dart';
import 'package:tunisiagotravel/screens/event_screen.dart';
import 'package:tunisiagotravel/screens/guide_screen.dart';
import 'package:tunisiagotravel/screens/restaurants_screen.dart';
import 'package:tunisiagotravel/screens/signup_screen.dart';
import '../providers/destination_provider.dart';
import '../providers/global_provider.dart';
import '../providers/hotel_provider.dart';
import '../providers/maisondhote_provider.dart';
import '../providers/restaurant_provider.dart';
import '../theme/color.dart';
import '../widgets/top_menu_bar.dart';
import 'automatic_circuit_screen.dart';
import 'chatbot_screen.dart';
import 'culture_screen.dart';
import 'home_screen.dart';
import 'circuits_screen.dart';
import 'hotels_screen.dart';
import 'login_screen.dart';
import 'maisonDhote_screen.dart';
import 'manual_circuit_screen.dart';

class MainWrapperScreen extends StatefulWidget {
  const MainWrapperScreen({super.key});

  @override
  State<MainWrapperScreen> createState() => _MainWrapperScreenState();
}

class _MainWrapperScreenState extends State<MainWrapperScreen> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<DestinationProvider>(context, listen: false).fetchDestinations();
        Provider.of<HotelProvider>(context, listen: false).fetchAllHotels();
        Provider.of<RestaurantProvider>(context, listen: false).fetchAllRestaurants();
        Provider.of<MaisonProvider>(context, listen: false).fetchMaisons();
      });
      _initialized = true;
    }
  }

  Future<bool> _onWillPop() async {
    final provider = Provider.of<GlobalProvider>(context, listen: false);

    if (provider.currentPage != AppPage.home) {
      provider.setPage(AppPage.home);
      return false;
    } else {
      final shouldExit = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Quitter l’application ?'),
          content: const Text('Voulez-vous vraiment quitter ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Quitter'),
            ),
          ],
        ),
      );
      return shouldExit ?? false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColorstatic.primary,
          centerTitle: true,
          title: Image.asset(
            'assets/images/logo-white.png',
            height: 40,
          ),
        ),
        backgroundColor: Colors.white,
        body: Column(
          children: [
            const TopMenuBar1(),
            Expanded(
              child: Consumer<GlobalProvider>(
                builder: (context, provider, child) {
                  Widget screen;
                  switch (provider.currentPage) {
                    case AppPage.home:
                      screen = HomeScreenContent();
                      break;
                    case AppPage.circuits:
                      screen = CircuitsScreenContent();
                      break;
                    case AppPage.hotels:
                      screen = HotelsScreenContent();
                      break;
                    case AppPage.restaurants:
                      screen = RestaurantsScreenContent();
                      break;
                    case AppPage.maisonsHotes:
                      screen = MaisonsScreenContent();
                      break;
                    case AppPage.activites:
                      screen = ActivitiesScreenContent();
                      break;
                    case AppPage.evenement:
                      screen = EventScreenContent();
                      break;
                    case AppPage.circuitsPredefini:
                      screen = CircuitPreScreen();
                      break;
                    case AppPage.circuitsManuel:
                      screen = ManualCircuitScreen();
                      break;
                    case AppPage.circuitsAuto:
                      screen = AutoCircuitScreen();
                      break;
                    case AppPage.cultures:
                      screen = CulturesScreen();
                      break;
                    case AppPage.agil:
                      screen = AgilScreen();
                      break;
                    case AppPage.guide:
                      screen = GuideScreen();
                      break;
                    case AppPage.login:
                      screen = LoginScreen();
                      break;
                    case AppPage.signup:
                      screen = SignUpScreen();
                      break;
                    case AppPage.chatbot:
                      final initialMessage = provider.chatbotInitialMessage;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        provider.clearChatbotInitialMessage();
                      });
                      screen = ChatBotScreen(
                        apiResponse: {},
                        initialMessage: initialMessage,
                      );
                      break;
                  }
                  return KeyedSubtree(
                    key: ValueKey(provider.rebuildCounter),
                    child: screen,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

