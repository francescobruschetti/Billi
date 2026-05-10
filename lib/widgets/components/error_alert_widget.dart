import 'package:Billy/constants.dart';
import 'package:flutter/material.dart';

class ErrorAlertWidget extends StatelessWidget {
  final String errorMessage;
  final IconData? icon;
  final VoidCallback? onClose;

  const ErrorAlertWidget({
    super.key,
    required this.errorMessage,
    this.icon,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon ?? Icons.error_outline, color: Colors.red),
          const SizedBox(width: AppConstants.mediumSizedBoxWidth),
          Expanded(
            child: Text(
              errorMessage,
              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
          if (onClose != null) ...[
            const SizedBox(width: AppConstants.sizedBoxWidth),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              tooltip: 'Chiudi',
              onPressed: onClose,
              splashRadius: 8,
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
            ),
          ],
        ],
      ),
    );
  }
}