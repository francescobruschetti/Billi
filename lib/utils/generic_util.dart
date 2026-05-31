
import 'package:Billy/constants.dart';
import 'package:flutter/material.dart';
import 'package:Billy/widgets/components/custom_snackbar_widget.dart';

class GenericUtil {

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

  static Widget buildLoadingOverlayLinearIndicator(bool isRefreshing) {
    if (!isRefreshing) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Aggiornamento in corso...'),
        const Center(
          child: SizedBox(height: 3, width: 120, child: LinearProgressIndicator()),
        ),
      ],
    );
  }
  
  static Widget buildLoadingOverlayCircularIndicator(bool isRefreshing, {Color? color = Colors.blue}) {
    if (!isRefreshing) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 4, color: color)),
        ),
        const SizedBox(width: AppConstants.mediumSizedBoxWidth),
        const Text('Aggiornamento in corso...'),
      ],
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