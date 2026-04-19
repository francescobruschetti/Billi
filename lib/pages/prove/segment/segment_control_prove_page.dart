import 'package:flutter/material.dart';

class SegmentedControlProve extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onChanged;

  const SegmentedControlProve({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(999), // Pill-shaped: Usa il valore massimo possibile rispetto alla dimensione del widget // TODO: provare ad usarlo sempre
      ),
      child: Row(
        children: [
          _buildItem("Entrate", 0),
          _buildItem("Uscite", 1),
        ],
      ),
    );
  }

  Widget _buildItem(String text, int index) {
    final isSelected = selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black, // isSelected ? Colors.black : Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }
}