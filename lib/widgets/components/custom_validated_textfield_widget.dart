
// Widget riutilizzabile per TextField con validazione e gestione focus/touched
import 'package:flutter/material.dart';

class CustomValidatedTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final String? Function(String value)? validator;
  final bool obscureText;
  final TextInputType? keyboardType;
  final IconButton? suffixIcon;
  final void Function(String)? onSubmitted;

  const CustomValidatedTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.validator,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
    this.onSubmitted,
  });

  @override
  State<CustomValidatedTextField> createState() => _CustomValidatedTextFieldState();
}

class _CustomValidatedTextFieldState extends State<CustomValidatedTextField> {
  late FocusNode _focusNode;
  bool _touched = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        setState(() {
          _touched = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final errorText = (_touched && widget.validator != null)
        ? widget.validator!(widget.controller.text)
        : null;
        
    return TextField(
      controller: widget.controller,
      focusNode: _focusNode,
      obscureText: widget.obscureText,
      keyboardType: widget.keyboardType,
      onSubmitted: widget.onSubmitted,
      decoration: InputDecoration(
        labelText: widget.labelText,
        errorText: errorText,
        border: const OutlineInputBorder(),
        suffixIcon: widget.suffixIcon,
      ),
    );
  }
}