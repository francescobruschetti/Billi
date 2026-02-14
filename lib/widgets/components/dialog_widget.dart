import 'package:flutter/material.dart';

class DialogWidget extends StatelessWidget {
  final String? title;
  final Widget customContent;

  const DialogWidget({
    super.key,
    this.title,
    required this.customContent,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: title != null ? Text('$title') : null,
      content: SingleChildScrollView(child: customContent),
      actions: [
        TextButton(
          child: const Text('Chiudi'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}