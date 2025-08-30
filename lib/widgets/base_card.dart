import 'package:flutter/material.dart';
import 'package:tunisiagotravel/theme/color.dart';

class BaseCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const BaseCard({
    super.key,
    required this.child,
    this.margin = const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    this.padding = const EdgeInsets.all(12),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColorstatic.lightTextColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}