import 'package:flutter/material.dart';

class CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color color;

  const CounterButton({
    Key? key,
    required this.icon,
    this.onTap,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isEnabled = onTap != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: isEnabled ? color.withOpacity(0.15) : Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isEnabled ? color.withOpacity(0.3) : Colors.grey[300]!,
              width: 1.5,
            ),
          ),
          child: Icon(
            icon,
            size: 20,
            color: isEnabled ? color : Colors.grey[400],
          ),
        ),
      ),
    );
  }
}
