import 'package:flutter/material.dart';

class CircuitInfoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color backgroundColor;

  const CircuitInfoCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.backgroundColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}