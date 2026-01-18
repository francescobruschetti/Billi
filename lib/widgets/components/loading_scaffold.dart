import 'package:flutter/material.dart';

class LoadingScaffold extends StatelessWidget {
  final String message;
  final double height;
  const LoadingScaffold({Key? key, this.message = 'Caricamento...', this.height = 300}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(message, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}