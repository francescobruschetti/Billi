import 'package:Billy/languages/app_localizations.dart';
import 'package:Billy/main.dart';
import 'package:flutter/material.dart';

class MultiLinguaProvePage extends StatefulWidget {
  const MultiLinguaProvePage({super.key});

  @override
  State<MultiLinguaProvePage> createState() => _MultiLinguaProvePageState();
}

class _MultiLinguaProvePageState extends State<MultiLinguaProvePage> {
  late String currentLanguage;

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
      appBar: AppBar(title: const Text('Prova Multi-lingua')),
      body: Center(
        child: Column(
          children: [
            // --- Prova Multi-lingua ---
            Expanded(child: _buildMultiLinguaTest(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildMultiLinguaTest(BuildContext context) {
    return Column(
      children: [
        Text('Current language: $currentLanguage'),
          ElevatedButton(
            onPressed: () {
              changeLanguage(context, currentLanguage == 'en' ? 'it' : 'en');
            },
            child: Text(currentLanguage == 'en' ? 'Switch to Italian' : 'Switch to English'),
          ),
          Text(AppLocalizations.of(context)!.helloWorld),
          Text(AppLocalizations.of(context)!.nWombats(0)),
          // Returns '1 wombat'
          Text(AppLocalizations.of(context)!.nWombats(1)),
          // Returns '5 wombats'
          Text(AppLocalizations.of(context)!.nWombats(5)),
          Text(AppLocalizations.of(context)!.helloWorldOn(DateTime.utc(1959, 7, 9))),
      ],
    );
  }
}