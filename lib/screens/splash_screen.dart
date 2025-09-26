import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tunisiagotravel/models/festival.dart';
import 'package:tunisiagotravel/providers/activity_provider.dart';
import 'package:tunisiagotravel/providers/event_provider.dart';
import 'package:tunisiagotravel/providers/festival_provider.dart';
import 'package:tunisiagotravel/providers/monument_provider.dart';
import 'package:tunisiagotravel/providers/musee_provider.dart';
import 'package:tunisiagotravel/providers/state_provider.dart';
import 'package:tunisiagotravel/screens/main_wrapper_screen.dart';
import 'package:tunisiagotravel/theme/color.dart';

import '../providers/destination_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DestinationProvider>(context, listen: false).fetchDestinations();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StateProvider>(context, listen: false).fetchStates();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<EventProvider>(context, listen: false).fetchEvents();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ActivityProvider>(context, listen: false).fetchAllActivities();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MonumentProvider>(context, listen: false).fetchMonuments();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MuseeProvider>(context, listen: false).fetchMusees();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FestivalProvider>(context, listen: false).fetchAllFestivals();
    });












    // Fade animation for logo
    _fadeController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    // Scale animation for logo
    _scaleController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );

    // Wave animation for background
    _waveController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
    _waveAnimation = Tween<double>(begin: 0.0, end: 10.0).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeInOut),
    );

    // Start animations
    _fadeController.forward();
    _scaleController.forward();

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainWrapperScreen()),
      );
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background with gradient and wave effect
          AnimatedBuilder(
            animation: _waveAnimation,
            builder: (context, child) {
              return CustomPaint(
                painter: WavePainter(_waveAnimation.value),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColorstatic.primary, AppColorstatic.primary],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              );
            },
          ),
          // Centered logo with fade and scale animations
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 250,
                      height: 250,
                        child: Image.asset('assets/images/logo-whiteold.png')
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for wave effect
class WavePainter extends CustomPainter {
  final double animationValue;

  WavePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.8);

    for (double x = 0; x <= size.width; x++) {
      path.lineTo(
        x,
        size.height * 0.8 +
            sin((x / size.width * 2 * 3.14) + animationValue) * 20,
      );
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Placeholder home screen
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tunisia Go Travel')),
      body: const Center(child: Text('Welcome to Tunisia Go Travel!')),
    );
  }
}