import 'package:flutter/material.dart';

class SegmentedControl extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onChanged;

  const SegmentedControl({
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
        borderRadius: BorderRadius.circular(999),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          return Stack(
            children: [
              // PILLA ANIMATA
              TweenAnimationBuilder<double>(
                tween: Tween<double>(
                  begin: 0,
                  end: selectedIndex.toDouble(),
                ),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOutCubic,
                builder: (context, value, child) {
                  final left = (width / 2) * value;

                  return Positioned(
                    left: left,
                    top: 0,
                    bottom: 0,
                    width: width / 2,
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.white,
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
                children: [
                  _buildItem("Dividi spesa", 0),
                  _buildItem("Specifica quota", 1),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildItem(String text, int index) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(index),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}