import 'package:Billy/constants.dart';
import 'package:Billy/pages/prove/ui_prove_page.dart';
import 'package:Billy/pages/settings/settings.dart';
import 'package:Billy/widgets/components/custom_icon_widget.dart';
import 'package:flutter/material.dart';
import '../pages/home_page.dart';
import '../pages/group/groups_page.dart';


class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final _pages = const [ // *Note: queste sono le pagine che verranno mostrate nel body del main_scaffold (items: const [...])*
    HomePage(),
    GroupsPage(),
    SettingsPage(),
    UIProvePageX(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // debug UI: backgroundColor: Colors.pink[200],
      resizeToAvoidBottomInset: true, // Evita overflow quando la tastiera è aperta
      // debug: appBar: const MainAppBarWidget(),
      // debug: drawer: const Drawer(), 
      body: _pages[_currentIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.rowHorizontalPadding, vertical: AppConstants.rowVerticalPadding),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.primary, width: AppConstants.rowVerticalPadding),
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              type: BottomNavigationBarType.fixed,              
              selectedItemColor: Theme.of(context).colorScheme.secondary,
              // debug UI: backgroundColor: Colors.orange[200],
              onTap: (index) {
                setState(() => _currentIndex = index);
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Personale',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.group),
                  label: 'Gruppi',
                ),
                BottomNavigationBarItem(
                  icon: CustomIconWidget(assetPath: 'assets/images/icons/settings-filled.PNG', size: 24),
                  label: 'Impostazioni',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.padding),
                  label: 'Prove UI',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}