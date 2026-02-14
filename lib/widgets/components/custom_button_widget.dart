import 'package:flutter/material.dart';

class CustomButtonWidget extends StatelessWidget {
  final String? text;
  final IconData icon;
  final VoidCallback onPressed;

  const CustomButtonWidget({
    super.key,
    this.text,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (text != null) ...[
            Icon(icon),
            const SizedBox(width: 8),
            Text(text!),
          ]
          else ...[
            Icon(icon, size: 30),
          ],
        ],
      ),
    );
  }
}