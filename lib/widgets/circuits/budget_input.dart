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
        hintText: tr('please_enter_budget'),
        hintStyle: const TextStyle(color: Colors.grey),
        labelText: tr('budget'),
        labelStyle: const TextStyle(color: Colors.black),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            width: 0.0,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            width: 0.0,
            color: Colors.grey,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            width: 0.4,
            color: Colors.blue,
          ),
        ),
        prefixIcon: const Icon(Icons.money_sharp),
      ),
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
    );
  }
}