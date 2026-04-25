import 'package:Billy/enums/theme_enum.dart';
import 'package:Billy/main.dart';
import 'package:Billy/widgets/components/app_bottom_sheet.dart';
import 'package:flutter/material.dart';

class ThemeSettingBottomSheetWidget extends StatefulWidget {
  final String title;
  const ThemeSettingBottomSheetWidget({super.key, required this.title});

  @override
  State<ThemeSettingBottomSheetWidget> createState() => _ThemeSettingBottomSheetWidgetState();
}

class _ThemeSettingBottomSheetWidgetState extends State<ThemeSettingBottomSheetWidget> {
  static final ScrollController _verticalController = ScrollController();

  late List<bool> _selectedThemes;
  final List<Widget> themeWidgets = <Widget>[
    Text(ThemeEnum.DARK.value),
    Text(ThemeEnum.LIGHT.value),
    Text(ThemeEnum.SYSTEM.value),
  ];

  @override
  void initState() {
    super.initState();
    ThemeEnum currentTheme = BillyApp.getThemeMode(context) == ThemeMode.dark
        ? ThemeEnum.DARK
        : BillyApp.getThemeMode(context) == ThemeMode.light
            ? ThemeEnum.LIGHT
            : ThemeEnum.SYSTEM;
            
    _selectedThemes = <bool>[
      currentTheme == ThemeEnum.DARK,
      currentTheme == ThemeEnum.LIGHT,
      currentTheme == ThemeEnum.SYSTEM,
    ];
  }

  void _handleThemeChange(BuildContext context, int index) {
    setState(() {
      // The button that is tapped is set to true, and the others to false.
      for (int i = 0; i < _selectedThemes.length; i++) {
        _selectedThemes[i] = i == index;
      }
    });

    Navigator.of(context).pop(ThemeEnum.values[index]);
  }

  @override
  Widget build(BuildContext context) {
    return AppBottomSheet(
      title: widget.title,
      initialSize: 0.4,
      minSize: 0.2,
      maxSize: 0.5,

      child: Column(
        children: [         
          const SizedBox(height: 4),
          Scrollbar(
            controller: _verticalController,
            thumbVisibility: true,
            child: Scrollbar(
              notificationPredicate: (notif) => notif.metrics.axis == Axis.horizontal,
              child: SingleChildScrollView(
                controller: _verticalController,
                scrollDirection: Axis.vertical,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SizedBox(
                      width: constraints.maxWidth - 16,
                      child: ToggleButtons(
                        direction: Axis.vertical,
                        onPressed: (int index) => _handleThemeChange(context, index),
                        
                        borderRadius: const BorderRadius.all(Radius.circular(8)),
                        borderColor: Theme.of(context).colorScheme.primary,
                        selectedBorderColor: Theme.of(context).colorScheme.primary,

                        fillColor: Theme.of(context).colorScheme.primary, // Selected Button Background Color
                        selectedColor: Theme.of(context).colorScheme.onPrimaryContainer, // Text Color for selected button
                        color: Theme.of(context).colorScheme.onPrimary, // Text Color

                        constraints: BoxConstraints(
                          minHeight: 40.0,
                          minWidth: constraints.maxWidth,
                        ),
                        isSelected: _selectedThemes,
                        children: themeWidgets,
                        // TODO: not working
                        // children: List.generate(themeWidgets.length, (i) {
                        //   return Container(
                        //     color: _selectedThemes[i]
                        //         ? Colors.red // Theme.of(context).colorScheme.primary
                        //         : Colors.amber, // .of(context).colorScheme.surface, // colore non selezionato
                        //     alignment: Alignment.center,
                        //     child: themeWidgets[i],
                        //   );
                        // }),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}