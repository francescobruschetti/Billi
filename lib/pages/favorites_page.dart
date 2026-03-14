import 'package:Billy/languages/app_localizations.dart';
import 'package:Billy/main.dart';
import 'package:flutter/material.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  String currentLanguage = 'it';

  void changeLanguage(BuildContext context, String languageCode) {
    /* TODO: not working: */
    Locale newLocale = Locale(languageCode);
    BillyApp.setLocale(context, newLocale);
    setState(() {
      currentLanguage = languageCode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
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
      ),
    );
  }
}