import 'package:flutter/material.dart';

class CustomSnackkBarWidget extends StatelessWidget {
  final String text;
  final Color? backgroundColor;
  final int? durationSeconds;
  final bool? showIcon;

  const CustomSnackkBarWidget({
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
      backgroundColor: backgroundColor ?? Colors.black,
      duration: Duration(seconds: durationSeconds ?? 2),
      showCloseIcon: showIcon ?? true,
    );
  }
}