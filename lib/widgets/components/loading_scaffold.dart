import 'package:Billy/constants.dart';
import 'package:flutter/material.dart';

class LoadingScaffold extends StatelessWidget {
  final String message;
  final double height;
  const LoadingScaffold({super.key, this.message = 'Caricamento...', this.height = 300});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: AppConstants.mediumSizedBoxHeight),
            Text(message, style: const TextStyle(fontSize: AppConstants.textSize)),
          ],
        ),
      ),
    );
  }
}