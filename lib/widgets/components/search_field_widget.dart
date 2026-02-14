import 'package:flutter/material.dart';

class SearchFieldWidget extends StatelessWidget {
  final String text;
  final IconData? icon;
  final ValueChanged<String> onChanged;

  const SearchFieldWidget({
    super.key,
    required this.text,
    this.icon,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: text,
        border: OutlineInputBorder(),
        isDense: true,
        prefixIcon: icon != null ? Icon(icon) : Icon(Icons.search),
      ),
      onChanged: onChanged,
    );
  }
}