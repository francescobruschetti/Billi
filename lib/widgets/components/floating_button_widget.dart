import 'package:flutter/material.dart';

class FloatingButtonWidget extends StatelessWidget {
  final Widget iconButton;
  final Function() onPressed;


  const FloatingButtonWidget({
    super.key,
    required this.iconButton,
    required this.onPressed,  
  });

  @override
  Widget build(BuildContext context) {

    return FloatingActionButton(
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        onPressed: onPressed,
        child: iconButton,
      );
  }
}