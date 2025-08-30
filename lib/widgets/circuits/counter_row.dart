import 'package:flutter/material.dart';

class CounterRow extends StatelessWidget {
  final String label;
  final int count;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const CounterRow({
    super.key,
    required this.label,
    required this.count,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
        IconButton(
          icon: const Icon(Icons.remove_circle_outline, color: Colors.blue),
          onPressed: onDecrement,
        ),
        Text(
          "$count",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
          onPressed: onIncrement,
        ),
      ],
    );
  }
}
