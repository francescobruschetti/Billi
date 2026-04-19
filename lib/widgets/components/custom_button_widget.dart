import 'package:Billy/widgets/components/custom_icon_widget.dart';
import 'package:flutter/material.dart';

class CustomButtonWidget extends StatelessWidget {
  final String? text;
  final Color? backgroundColor;
  final IconData? iconData;
  final CustomIconWidget? customIcon;
  final bool isIconPrefix;
  final VoidCallback? onPressed;

  const CustomButtonWidget({
    super.key,
    this.text,
    this.backgroundColor,
    this.iconData,
    this.customIcon,
    this.isIconPrefix = true,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.secondaryContainer,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: backgroundColor ?? Theme.of(context).colorScheme.secondaryContainer, width: 1),
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
          Icon(iconData, color: Theme.of(context).colorScheme.onSecondary, size: text == null ? 30 : 24),
        ],
        if (iconData == null && customIcon != null) ...[
          customIcon!,
        ],
        if (text != null) ...[
          if (iconData != null || customIcon != null) ...[
            const SizedBox(width: 8),
          ],

          Text(text!, style: TextStyle(color: Theme.of(context).colorScheme.onSecondaryContainer)), // es. , fontWeight: FontWeight.bold)),
        ],
      ],
    );
  }

  Widget _buildIsIconSuffix(BuildContext context) {
    return Row(      
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(text!, style: TextStyle(color: Theme.of(context).colorScheme.onSecondaryContainer)), 

        if (iconData != null) ...[
          Icon(iconData, color: Theme.of(context).colorScheme.onSecondary, size: text == null ? 30 : 24),
        ],
        if (iconData == null && customIcon != null) ...[
          customIcon!,
        ],
      ],
    );
  }
}