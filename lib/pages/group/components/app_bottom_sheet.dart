// Solo scaffolding visivo, nessuna logica
import 'package:Billy/constants.dart';
import 'package:flutter/material.dart';

class AppBottomSheet extends StatelessWidget {
  final String? title;
  final Widget child;

  /* 
  * initialSize: 0.5 si apre a metà schermo
  * minSize: 0.25 non si chiude sotto il 25%
  * maxSize: 0.95 si estende quasi a tutto schermo
  * snap: true si aggancia ai punti definiti in snapSizes 
  * 
  * Note: must be used in order!!!
  */
  final double initialSize; // altezza iniziale (0.0 - 1.0)
  final double minSize; // altezza minima
  final double maxSize; // altezza massima

  const AppBottomSheet({
    super.key,
    this.title,
    this.initialSize = 0.5,
    this.minSize = 0.2,
    this.maxSize = 1.0,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: initialSize,
      minChildSize: minSize,
      maxChildSize: maxSize,
      expand: false, // si espande per riempire lo spazio disponibile
      snap: false, // si aggancia agli snap point
      snapSizes: [minSize, initialSize, maxSize], // punti di aggancio
      snapAnimationDuration: const Duration(milliseconds: 200), // durata animazione snap
      builder: (context, scrollController) {
        return Container(
          // width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.rowHorizontalPadding),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 2),
              Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              if (title != null) ...[
                const SizedBox(height: 16),
                Text(title!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
              const SizedBox(height: 8),
              child, // Contenuto personalizzato
            ],
          ),
        );
      },
    );
  }
}