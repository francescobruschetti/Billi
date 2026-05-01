import 'package:Billy/main.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class ButtonGroupProvePage extends StatefulWidget {
  const ButtonGroupProvePage({super.key});

  @override
  State<ButtonGroupProvePage> createState() => _ButtonGroupProvePageState();
}

class _ButtonGroupProvePageState extends State<ButtonGroupProvePage> {
  final Logger log = Logger('ButtonGroupProvePage');
  late String currentLanguage;
  
  final List<bool> _selectedFruits = <bool>[true, false, false];
  final List<Widget> fruits = <Widget>[
    Text('Apple'),
    Text('Banana'),
    Text('Orange'),
  ];

  @override
  void initState() {
    super.initState();
    currentLanguage = BillyApp.getCurrentLanguage(context);
  }

  void changeLanguage(BuildContext context, String languageCode) {
    Locale newLocale = Locale(languageCode);
    BillyApp.setLocale(context, newLocale);
    setState(() {
      currentLanguage = languageCode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text('Prova Button Group')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ToggleButtons(
              direction: Axis.horizontal,
              onPressed: (int index) {
                setState(() {
                  // The button that is tapped is set to true, and the others to false.
                  for (int i = 0; i < _selectedFruits.length; i++) {
                    _selectedFruits[i] = i == index;
                  }
                });
              },
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              selectedBorderColor: Colors.red[700],
              selectedColor: Colors.white,
              fillColor: Colors.red[200],
              color: Colors.red[400],
              constraints: const BoxConstraints(
                minHeight: 40.0,
                minWidth: 80.0,
              ),
              isSelected: _selectedFruits,
              children: fruits,
            ),
          ],
        ),
      ),
    );
  }
}