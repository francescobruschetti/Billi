import 'package:Billy/constants.dart';
import 'package:Billy/enums/theme_enum.dart';
import 'package:Billy/extentions/user_settings_extensions.dart';
import 'package:Billy/providers/local-database/user_settings_provider.dart';
import 'package:Billy/widgets/components/app_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

class ThemeSettingBottomSheetWidget extends ConsumerStatefulWidget {
  final String title;
  const ThemeSettingBottomSheetWidget({super.key, required this.title});

  @override
  ConsumerState<ThemeSettingBottomSheetWidget> createState() => _ThemeSettingBottomSheetWidgetState();
}

class _ThemeSettingBottomSheetWidgetState extends ConsumerState<ThemeSettingBottomSheetWidget> {
  final Logger log = Logger('ThemeSettingBottomSheetWidget');
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

  void _setupSelectedThemes(ThemeEnum? currentTheme) {
    log.fine("Setting up selected themes with current theme: $currentTheme");
    _selectedThemes = <bool>[
      currentTheme == ThemeEnum.DARK,
      currentTheme == ThemeEnum.LIGHT,
      currentTheme == ThemeEnum.SYSTEM,
    ];
  }

  @override
  Widget build(BuildContext context) {    
    final settingsState = ref.watch(userSettingsProvider);
    
    return settingsState.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text("Errore durante il caricamento. Riprovare")), // TODO: migliorare gestione errori
      data: (settings) {
        _setupSelectedThemes(settings?.themeModeEnum);

        return AppBottomSheet(
          title: widget.title,
          initialSize: 0.4,
          minSize: 0.2,
          maxSize: 0.5,

          child: Column(
            children: [         
              const SizedBox(height: AppConstants.sizedBoxHeight),
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

                            fillColor: Theme.of(context).colorScheme.primaryContainer, // Selected Button Background Color
                            selectedColor: Theme.of(context).colorScheme.onPrimaryContainer, // Text Color for selected button
                            color: Theme.of(context).colorScheme.onPrimary, // Text Color

                            constraints: BoxConstraints(
                              minHeight: 40.0,
                              minWidth: constraints.maxWidth,
                            ),
                            isSelected: _selectedThemes,
                            children: themeWidgets,
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
    );
  }
}