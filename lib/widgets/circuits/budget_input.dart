import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class BudgetInput extends StatelessWidget {
  final TextEditingController controller;

  const BudgetInput({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: tr('budget'), // clé de traduction
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        prefixIcon: const Icon(Icons.money_sharp),
      ),
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
    );
  }
}
