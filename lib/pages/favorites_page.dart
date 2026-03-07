import 'package:Billy/languages/app_localizations.dart';
import 'package:flutter/material.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
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