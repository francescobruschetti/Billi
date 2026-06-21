
import 'package:Billy/constants.dart';
import 'package:flutter/material.dart';
import 'package:Billy/widgets/components/custom_snackbar_widget.dart';

class GenericUtil {

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