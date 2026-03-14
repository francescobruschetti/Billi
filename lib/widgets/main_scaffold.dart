import 'package:Billy/constants.dart';
import 'package:Billy/pages/ui_prove_page.dart';
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
    UIProvePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // debug UI: backgroundColor: Colors.pink[200],
      resizeToAvoidBottomInset: true, // Evita overflow quando la tastiera è aperta
      appBar: AppBar(
        title: const Text('Billy - Monitoraggio Spese'),
        actions: [ ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                Navigator.of(context).pop(); // Chiude il drawer
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              },
            ),
          ],
        ),
      ),
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