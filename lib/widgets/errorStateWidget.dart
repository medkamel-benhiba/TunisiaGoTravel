import 'package:flutter/material.dart';

class ErrorStateWidget extends StatelessWidget {
  final String error;
  final String? title;
  final String? message;

  const ErrorStateWidget({
    super.key,
    required this.error,
    this.title = 'Oops! Something went wrong',
    this.message = 'Unable to load hotel details',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red[400],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title!,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message!,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}