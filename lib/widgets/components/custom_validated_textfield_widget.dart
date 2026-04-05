
// Widget riutilizzabile per TextField con validazione e gestione focus/touched
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomValidatedTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final bool obscureText;

  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final void Function()? onTap;
  final Widget? prefixIcon;
  final bool? readOnly;
  final IconButton? suffixIcon;
  final String? Function(String value)? validator;

  const CustomValidatedTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.obscureText = false,
    
    this.inputFormatters,
    this.keyboardType,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.prefixIcon,
    this.readOnly = false,
    this.suffixIcon,
    this.validator,
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
      inputFormatters: widget.inputFormatters,
      keyboardType: widget.keyboardType,
      obscureText: widget.obscureText,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      onTap: widget.onTap,
      readOnly: widget.readOnly ?? false,
      
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        errorText: errorText,
        labelText: widget.labelText,
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.suffixIcon,
      ),
    );
  }
}