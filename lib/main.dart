import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tunisiagotravel/providers/activity_provider.dart';
import 'package:tunisiagotravel/providers/artisanat_provider.dart';
import 'package:tunisiagotravel/providers/auth_provider.dart';
import 'package:tunisiagotravel/providers/auto_circuit_provider.dart';
import 'package:tunisiagotravel/providers/event_provider.dart';
import 'package:tunisiagotravel/providers/festival_provider.dart';
import 'package:tunisiagotravel/providers/guide_provider.dart';
import 'package:tunisiagotravel/providers/maisondhote_provider.dart';
import 'package:tunisiagotravel/providers/manual_circuit_provider.dart';
import 'package:tunisiagotravel/providers/monument_provider.dart';
import 'package:tunisiagotravel/providers/musee_provider.dart';
import 'package:tunisiagotravel/providers/restaurant_provider.dart';
import 'package:tunisiagotravel/providers/voyage_provider.dart';
import 'package:tunisiagotravel/screens/circuit_predifini_screen.dart';
import 'package:tunisiagotravel/screens/main_wrapper_screen.dart';
import 'package:tunisiagotravel/services/api_service.dart';
import 'providers/global_provider.dart';
import 'providers/destination_provider.dart';
import 'providers/hotel_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GlobalProvider()),
        ChangeNotifierProvider(create: (_) => DestinationProvider()),
        ChangeNotifierProvider(create: (_) => HotelProvider()),
        ChangeNotifierProvider(create: (_) => RestaurantProvider()),
        ChangeNotifierProvider(create: (_) => MaisonProvider()),
        ChangeNotifierProvider(create: (_) => ActivityProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => GuideProvider()),
        ChangeNotifierProvider(create: (_) => MuseeProvider(apiService: ApiService())),
        ChangeNotifierProvider(create: (_) => FestivalProvider()),
        ChangeNotifierProvider(create: (_) => MonumentProvider(apiService: ApiService()),),
        ChangeNotifierProvider(create: (_) => ArtisanatProvider(apiService: ApiService())),
        ChangeNotifierProvider(create: (_) => ManualCircuitProvider()),
        ChangeNotifierProvider(create: (_) => AutoCircuitProvider()),
        ChangeNotifierProvider(create: (_) => VoyageProvider(), child: const CircuitPreScreen()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),





      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tunisia Go Travel',
      home: const MainWrapperScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}