import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:tunisiagotravel/providers/global_provider.dart';
import 'package:tunisiagotravel/screens/main_wrapper_screen.dart';
import '../theme/color.dart';
import '../theme/styletext.dart';
// Add this package for animations
import 'package:flutter_animate/flutter_animate.dart';

class CircuitReservationSuccessScreen extends StatelessWidget {
  const CircuitReservationSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'reservation_confirmed'.tr(),
          style: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
            fontWeight: FontWeight.bold
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColorstatic.primary,
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isTablet ? 32 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // --- Enhanced Success Icon with Animation ---
                    Animate(
                      effects: [
                        ScaleEffect(
                          duration: 500.ms,
                          curve: Curves.easeOutBack,
                        ),
                        FadeEffect(duration: 500.ms),
                      ],
                      child: Container(
                        width: isTablet ? size.width * 0.2 : size.width * 0.3,
                        height: isTablet ? size.width * 0.2 : size.width * 0.3,
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.check_circle,
                          size: isTablet ? size.width * 0.12 : size.width * 0.2,
                          color: Colors.green.shade600,
                        ),
                      ),
                    ),
                    SizedBox(height: isTablet ? 32 : 24), // Use fixed spacing for consistency

                    // --- Improved Thank You Message with Font Styling ---
                    Text(
                      'reservation_thank_you'.tr(),
                      style: TextStyle(
                        fontSize: isTablet ? 28 : 22,
                        fontWeight: FontWeight.bold,
                        color: AppColorstatic.mainColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: isTablet ? 24 : 16),

                    // --- Modernized Information Card ---
                    Card(
                      elevation: 8, // Higher elevation for a floating effect
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24), // More rounded corners
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(isTablet ? 32 : 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'reservation_success_message'.tr(),
                              style: TextStyle(
                                fontSize: isTablet ? 18 : 16,
                                height: 1.6,
                                color: AppColorstatic.mainColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: isTablet ? 24 : 16),

                            // --- Clean Contact Info Block ---
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: isTablet ? 24 : 16, vertical: isTablet ? 16 : 12),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.blue.shade100), // Lighter border
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [

                                  SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.phone,
                                            color: Colors.blue.shade700,
                                            size: isTablet ? 28 : 24,
                                          ),
                                          SizedBox(width: 5),
                                          Text(
                                            'contact_us'.tr(),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.blue.shade700,
                                              fontSize: isTablet ? 20 : 16,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        '+216 71 168 600\n+216 71 168 604',
                                        style: TextStyle(
                                          fontSize: isTablet ? 20 : 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue.shade800,
                                        ),
                                      ),
                                    ],
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
              ),
            ),

            // --- Enhanced Buttons Section ---
            Padding(
              padding: EdgeInsets.fromLTRB(isTablet ? 32 : 20, 16, isTablet ? 32 : 20, isTablet ? 32 : 20),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final provider = Provider.of<GlobalProvider>(context, listen: false);
                        provider.setPage(AppPage.home);
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => MainWrapperScreen()),
                              (route) => false,
                        );
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColorstatic.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: isTablet ? 20 : 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      icon: const Icon(Icons.home),
                      label: Text(
                        'back_to_home'.tr(),
                        style: TextStyle(
                          fontSize: isTablet ? 18 : 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Your dialog code remains here
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text('contact_support'.tr()),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('phone_numbers'.tr() + ':'),
                                const SizedBox(height: 8),
                                const Text(
                                  '+216 71 168 600\n+216 71 168 604',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text('close'.tr()),
                              ),
                            ],
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColorstatic.primary, width: 2), // Thicker border
                        padding: EdgeInsets.symmetric(vertical: isTablet ? 20 : 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: Icon(Icons.support_agent, color: AppColorstatic.primary),
                      label: Text(
                        'contact_support'.tr(),
                        style: TextStyle(
                          fontSize: isTablet ? 18 : 16,
                          fontWeight: FontWeight.bold,
                          color: AppColorstatic.primary,
                        ),
                      ),
                    ),
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