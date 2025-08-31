import 'package:flutter/material.dart';

class BudgetInput extends StatelessWidget {
  final TextEditingController controller;

  const BudgetInput({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: "Budget",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: const Icon(Icons.money_rounded),
      ),
      keyboardType: TextInputType.number,
    );
  }
}