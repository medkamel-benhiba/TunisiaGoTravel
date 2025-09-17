import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ComposeButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const ComposeButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          tr("compose"),
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }
}