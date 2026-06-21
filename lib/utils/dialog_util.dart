
import 'package:Billy/constants.dart';
import 'package:flutter/material.dart';

class DialogUtil {

  static Future<bool?> showConfirmationBeforeDeleteDialog(BuildContext context, String title, String contentMessage, 
    {String confirmButtonText = "Elimina", String cancelButtonText = "Annulla"}) async {
    return await showConfirmationDialog(
      context,
      title,
      contentMessage,
      confirmButtonText: confirmButtonText,
      cancelButtonText: cancelButtonText,
      isDestructive: true,
    );
  }

  static Future<bool> showConfirmationBeforeSaveDialog({ required BuildContext context, String title = 'Conferma salvataggio', String contentMessage = '', 
    String confirmButtonText = "Conferma", String cancelButtonText = "Annulla"}) async {
    final confirmed = await showConfirmationDialog(
      context, 
      title, 
      contentMessage,
      confirmButtonText: confirmButtonText,
      cancelButtonText: cancelButtonText);

    return confirmed ?? false; // Ritorna false se l'utente chiude il dialog senza scegliere
  }

  static Future<bool?> showConfirmationDialog(BuildContext context, String title, String contentMessage, 
    {String confirmButtonText = "Elimina", String cancelButtonText = "Annulla", bool isDestructive = false}) async 
  {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(contentMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelButtonText),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDestructive ? AppConstants.red : Theme.of(context).colorScheme.secondary,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              confirmButtonText, 
              style: TextStyle(
                color: isDestructive ? Colors.white : Theme.of(context).colorScheme.onSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

}