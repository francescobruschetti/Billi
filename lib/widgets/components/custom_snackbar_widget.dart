import 'package:flutter/material.dart';

class CustomSnackBarWidget extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final int? durationSeconds;
  final bool? showIcon;

  const CustomSnackBarWidget({
    super.key,
    required this.text,
    this.backgroundColor,
    this.durationSeconds,
    this.showIcon,
  });

  @override
  SnackBar build(BuildContext context) {
    return SnackBar(content: 
      Text(text),
      behavior: SnackBarBehavior.floating,
      backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.onPrimaryContainer,
      duration: Duration(seconds: durationSeconds ?? 2),
      showCloseIcon: showIcon ?? true,
    );
  }
}