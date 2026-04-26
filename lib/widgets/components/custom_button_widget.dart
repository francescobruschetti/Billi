import 'package:Billy/constants.dart';
import 'package:Billy/widgets/components/custom_icon_widget.dart';
import 'package:flutter/material.dart';

class CustomButtonWidget extends StatelessWidget {
  final String? text;
  final Color? backgroundColor;
  final IconData? iconData;
  final CustomIconWidget? customIcon;
  final bool isIconPrefix;
  final bool isEnabled;
  final VoidCallback? onPressed;

  const CustomButtonWidget({
    super.key,
    this.text,
    this.backgroundColor,
    this.iconData,
    this.customIcon,
    this.isIconPrefix = true,
    this.isEnabled = true,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isEnabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        disabledBackgroundColor: AppConstants.disabledButtonColor,
        backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.secondaryContainer,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        
        shape: RoundedRectangleBorder(
          side: BorderSide(color: isEnabled ? (backgroundColor ?? Theme.of(context).colorScheme.secondaryContainer) : AppConstants.disabledButtonColor, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: isIconPrefix ? _buildIsIconPrefix(context) : _buildIsIconSuffix(context),
    );
  }

  Widget _buildIsIconPrefix(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (iconData != null) ...[
          Icon(iconData, color: Theme.of(context).colorScheme.onPrimaryContainer, size: text == null ? 30 : 24),
        ],
        if (iconData == null && customIcon != null) ...[
          customIcon!,
        ],
        if (text != null) ...[
          if (iconData != null || customIcon != null) ...[
            const SizedBox(width: 4),
          ],

          Text(text!, style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer)), // es. , fontWeight: FontWeight.bold)),
        ],
      ],
    );
  }

  Widget _buildIsIconSuffix(BuildContext context) {
    return Row(      
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(text!, style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer)), 

        if (iconData != null) ...[
          const SizedBox(width: 4),
          Icon(iconData, color: Theme.of(context).colorScheme.onPrimaryContainer, size: text == null ? 30 : 24),
        ],
        if (iconData == null && customIcon != null) ...[
          const SizedBox(width: 4),
          customIcon!,
        ],
      ],
    );
  }
}