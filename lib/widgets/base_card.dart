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
        color: AppColorstatic.secondary.withOpacity(0.02),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColorstatic.mainColor.withOpacity(0.03),
        )
      ),
      child: child,
    );
  }
}