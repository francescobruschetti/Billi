import 'package:flutter/material.dart';

class CustomIconWidget extends StatelessWidget {
  final String assetPath;
  final double size;
  final Color? color;

  const CustomIconWidget({
    required this.assetPath,
    this.size = 30,
    this.color,
    super.key,
  });
  
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      width: size,
      height: size,
      color: color ?? Theme.of(context).colorScheme.onPrimaryContainer,
      fit: BoxFit.contain,
    );
  }
}