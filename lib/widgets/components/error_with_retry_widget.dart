import 'package:Billy/constants.dart';
import 'package:Billy/widgets/components/custom_button_widget.dart';
import 'package:flutter/material.dart';

class ErrorWithRetryWidget extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;
  final String buttonText;

  const ErrorWithRetryWidget({
    super.key,
    required this.onRetry,
    this.errorMessage = "Errore durante il caricamento",
    this.buttonText = 'Riprova',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            errorMessage,
            style: const TextStyle(fontSize: AppConstants.textSize),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppConstants.mediumSizedBoxHeight),
          
          IntrinsicWidth( // Note Docs: Force button to take only the necessary width
            child: CustomButtonWidget(
              onPressed: onRetry, // Note Docs: non esegue direttamente onRetry() per evitare di chiamare la funzione al momento della build. Use () { onRetry(param1, param2); } or pass the function reference without parentheses.
              text: 'Ricarica',
              iconData: Icons.refresh,
            ),
          )
        
        ],
      ),
    );
  }
}
