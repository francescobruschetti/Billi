import 'package:flutter/material.dart';
import 'package:monitoraggio_spese/enums/time_filter_enum.dart';

class TimeFilterWidget extends StatelessWidget {
  final List<TimeFilterEnum> timeFilters;
  final void Function(TimeFilterEnum) onPressed;

  const TimeFilterWidget({
    super.key,
    required this.timeFilters,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Calcola la larghezza minima per ogni bottone
    final minButtonWidth = 100.0;
    final totalMinWidth = minButtonWidth * (timeFilters.length);
    final screenWidth = MediaQuery.of(context).size.width;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: screenWidth,
          maxWidth: totalMinWidth > screenWidth ? totalMinWidth : screenWidth,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: timeFilters.map((filter) =>
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: SizedBox(
                width: minButtonWidth,
                child: ElevatedButton(
                  onPressed: () => onPressed(filter),
                  style: ElevatedButton.styleFrom(
                    side: const BorderSide(color: Colors.blueAccent),
                    textStyle: const TextStyle(fontStyle: FontStyle.italic),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Text(filter.value, textAlign: TextAlign.center),
                ),
              ),
            )
          ).toList(),
        ),
      ),
    );


    // return ElevatedButton(
    //   onPressed: onPressed,
    //   child: Row(
    //     mainAxisAlignment: MainAxisAlignment.center,
    //     children: [
    //       Text(timeFilters.map((e) => e.toString().split('.').last).join(', ')),
    //     ],
    //   ),
    // );
  }
}