import 'package:flutter/material.dart';

class SearchFieldWidget extends StatelessWidget {
  final String hintText;
  final IconData? icon;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClose;

  const SearchFieldWidget({
    super.key,
    required this.hintText,
    this.icon,
    required this.onChanged,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      autoFocus: true,
      hintText: hintText,
      leading: icon != null ? Icon(icon) : const Icon(Icons.search),
      onChanged: onChanged,
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      trailing: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onClose,
            tooltip: 'Chiudi',
          ),
      ],
    );
  }
}