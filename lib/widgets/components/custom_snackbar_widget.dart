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
    return SnackBar(
      content: Text(text, style: TextStyle(color: Theme.of(context).colorScheme.onSecondary)),

      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(64)),

      backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.secondary,
      duration: Duration(seconds: durationSeconds ?? 2),

      showCloseIcon: showIcon ?? true,
      closeIconColor: Theme.of(context).colorScheme.onSecondary,
    );
  }
}