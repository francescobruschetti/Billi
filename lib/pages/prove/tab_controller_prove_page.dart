import 'package:Billy/main.dart';
import 'package:Billy/pages/home_page.dart';
import 'package:Billy/pages/settings/settings_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class TabControllerProvePage extends StatefulWidget {
  const TabControllerProvePage({super.key});

  @override
  State<TabControllerProvePage> createState() => _TabControllerProvePageState();
}

class _TabControllerProvePageState extends State<TabControllerProvePage> {
  final Logger log = Logger('TabControllerProvePage');
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
    return _buildTabBar(context);
  }

  // Tutorial: https://blog.logrocket.com/flutter-tabbar-a-complete-tutorial-with-examples/
  Widget _buildTabBar(BuildContext context) {
    final platform = Theme.of(context).platform;
    log.fine('Current platform: $platform');
    if (platform == TargetPlatform.iOS) {
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
    else {
      return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(            
            bottom: TabBar(
              labelColor: Theme.of(context).colorScheme.onSecondaryContainer,
              indicatorSize: TabBarIndicatorSize.tab, // Change indicator size
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(50), // Creates border
                color: Theme.of(context).colorScheme.secondaryContainer,
              ),
              tabs: [
                Tab(icon: Icon(Icons.flight)),
                Tab(icon: Icon(Icons.directions_transit)),
                Tab(icon: Icon(Icons.directions_car)),
              ],
            ),
            title: Text('Tabs Demo'),
          ),
          body: TabBarView(
            children: [
              Icon(Icons.flight, size: 350),
              Icon(Icons.directions_transit, size: 350),
              Icon(Icons.directions_car, size: 350),
            ],
          ),
        ),
      );
    }
  }
}