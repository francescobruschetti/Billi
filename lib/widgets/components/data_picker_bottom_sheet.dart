
import 'package:Billy/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DataPickerBottomSheet extends StatefulWidget {
  final DateTime initialDate = DateTime.now();
  final DateTime firstDate = DateTime.now();
  final DateTime lastDate = DateTime(2100);

  DataPickerBottomSheet({super.key,});

  @override
  State<DataPickerBottomSheet> createState() => _DataPickerBottomSheetState();
}

class _DataPickerBottomSheetState extends State<DataPickerBottomSheet> {
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {

    return StatefulBuilder(
      builder: (context, setState) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Select date',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: AppConstants.mediumSizedBoxHeight),
                CalendarDatePicker(
                  initialDate: selectedDate,
                  firstDate: widget.firstDate,
                  lastDate: widget.lastDate,
                  onDateChanged: (date) {
                    setState(() {
                      selectedDate = date;
                    });
                  },
                ),
                // TODO: UI error
                // CupertinoDatePicker(
                //   mode: CupertinoDatePickerMode.date,
                //   initialDateTime: selectedDate,
                //   minimumDate: widget.firstDate,
                //   maximumDate: widget.lastDate,
                //   onDateTimeChanged: (date) {
                //     setState(() {
                //       selectedDate = date;
                //     });
                //   },
                // ),

                const SizedBox(height: AppConstants.mediumSizedBoxHeight),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),

                    FilledButton(
                      onPressed: () => Navigator.pop(context, selectedDate),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

}