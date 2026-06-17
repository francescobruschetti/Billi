import 'package:Billy/constants.dart';
import 'package:flutter/material.dart';

class SegmentedControl extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onChanged;
  final List<MapEntry<String, IconData?>> segments;

  const SegmentedControl({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
    required this.segments,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.grey.shade300, // TODO: gestire il cambio di Theme (light/dark mode)
        borderRadius: BorderRadius.circular(999),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          return Stack(
            children: [
              // PILA ANIMATA
              TweenAnimationBuilder<double>(
                tween: Tween<double>(
                  begin: 0,
                  end: selectedIndex.toDouble(),
                ),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOutCubic,
                builder: (context, value, child) {
                  final left = (width / segments.length) * value;

                  return Positioned(
                    left: left,
                    top: 0,
                    bottom: 0,
                    width: width / segments.length,
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary, // TODO: gestire il cambio di Theme (light/dark mode)
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.black12, // black with 12% opacity
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),

              Row(
                children: segments.asMap().entries.map((entry) {
                  return _buildItem(entry.value.key, entry.key, entry.value.value);
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildItem(String text, int index, IconData? icon) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(index),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) Icon(icon, size: AppConstants.smallIconSize, color: Colors.black),
                if (icon != null) const SizedBox(width: 4),

                Text(
                  text,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}