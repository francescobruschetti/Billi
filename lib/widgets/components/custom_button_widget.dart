import 'package:flutter/material.dart';

class CustomButtonWidget extends StatelessWidget {
  final String? text;
  final Color? backgroundColor;
  final IconData icon;
  final VoidCallback onPressed;

  const CustomButtonWidget({
    super.key,
    this.text,
    this.backgroundColor,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.primaryContainer,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: backgroundColor ?? Theme.of(context).colorScheme.primary, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (text != null) ...[
            Icon(icon),
            const SizedBox(width: 8),
            Text(text!, style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer)),
          ]
          else ...[
            Icon(icon, size: 30),
          ],
        ],
      ),
    );
  }
}