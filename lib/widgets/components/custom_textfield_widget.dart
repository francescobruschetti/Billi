import 'package:flutter/material.dart';

class CustomTextFieldWidget extends StatelessWidget {
  final TextEditingController controller;
  final String text;
  final String? labelText;

  const CustomTextFieldWidget({
    required this.controller,
    required this.text,
    this.labelText,
    super.key,
  });
  
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(labelText: labelText, border: const OutlineInputBorder()),
      
    );
  }
}