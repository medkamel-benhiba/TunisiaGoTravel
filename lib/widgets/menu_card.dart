import 'package:flutter/material.dart';

class MenuCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final Color backgroundColor;
  final VoidCallback? onTap;

  const MenuCard({
    super.key,
    required this.title,
    required this.imagePath,
    required this.backgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              imagePath,
              fit: BoxFit.cover,
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                color: backgroundColor,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
