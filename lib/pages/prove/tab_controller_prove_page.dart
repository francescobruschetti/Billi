import 'package:Billy/main.dart';
import 'package:Billy/pages/home_page.dart';
import 'package:Billy/pages/settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TabControllerProvePage extends StatefulWidget {
  const TabControllerProvePage({super.key});

  @override
  State<TabControllerProvePage> createState() => _TabControllerProvePageState();
}

class _TabControllerProvePageState extends State<TabControllerProvePage> {
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
      appBar: AppBar(title: const Text('Prova TabController')),
      body: Center(
        child: Column(
          children: [
            Expanded(child: _buildTabBar(context)),
          ],
        ),
      ),
    );
  }

  // prova: 2026-04-12
  Widget _buildTabBar(BuildContext context) {
    final platform = Theme.of(context).platform;
    if (platform == TargetPlatform.iOS) {
      // TabBar Material arrotondata sopra il contenuto
      return DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  color: Theme.of(context).colorScheme.surface,
                  child: const TabBar(
                    indicator: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.black54,
                    tabs: [
                      Tab(icon: Icon(Icons.home), text: 'Home'),
                      Tab(icon: Icon(Icons.settings), text: 'Impostazioni'),
                    ],
                  ),
                ),
              ),
            ),
            const Expanded(
              child: TabBarView(
                children: [
                  HomePage(),
                  SettingsPage(),
                ],
              ),
            ),
          ],
        ),
      );
    } else {
      // Su Android/Web: TabBar stile Cupertino in basso
      return CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(CupertinoIcons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(CupertinoIcons.settings), label: 'Impostazioni'),
          ],
        ),
        tabBuilder: (context, index) {
          switch (index) {
            case 0:
              return CupertinoTabView(builder: (_) => HomePage());
            case 1:
              return CupertinoTabView(builder: (_) => SettingsPage());
            default:
              return Container();
          }
        },
      );
    }
  }
}