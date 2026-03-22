
import 'package:flutter/material.dart';
import 'package:Billy/widgets/components/custom_snackbar_widget.dart';

class GenericUtil {

  
  static Future<bool?> showConfirmationBeforeDeleteDialog(BuildContext context, String title, String content, 
    {String confirmButtonText = "Elimina", String cancelButtonText = "Annulla"}) async {
    return await showConfirmationDialog(
      context,
      title,
      content,
      confirmButtonText: confirmButtonText,
      cancelButtonText: cancelButtonText,
      isDestructive: true,
    );
  }

  static Future<bool?> showConfirmationDialog(BuildContext context, String title, String content, 
    {String confirmButtonText = "Elimina", String cancelButtonText = "Annulla", bool isDestructive = false}) async 
  {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelButtonText),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: isDestructive ? Colors.red : Colors.blue[700]),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmButtonText),
          ),
        ],
      ),
    );
  }

  static void showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      CustomSnackBarWidget( 
        text: message,
      ).build(context),
    );
  }

}