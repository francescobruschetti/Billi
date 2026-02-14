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

  final _pages = const [ // Note: queste sono le pagine che verranno mostrate nel body del main_scaffold
    HomePage(),
    GroupsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
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
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.primary, width: 10),
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              type: BottomNavigationBarType.fixed,
              onTap: (index) {
                setState(() => _currentIndex = index);
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.group),
                  label: 'Gruppi',
                )
              ],
            ),
          ),
        ),
      ),
      // v1:
      // bottomNavigationBar: Padding(
      //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      //   child: DecoratedBox(
      //     decoration: BoxDecoration(
      //       border: Border.all(color: Colors.black, width: 3),
      //       borderRadius: BorderRadius.circular(16),
      //     ),
      //     child: ClipRRect(
      //       borderRadius: BorderRadius.circular(16),
      //       child: BottomNavigationBar(
      //         currentIndex: _currentIndex,
      //         type: BottomNavigationBarType.fixed,
      //         backgroundColor: Colors.red,
      //         onTap: (index) {
      //           setState(() => _currentIndex = index);
      //         },
      //         items: const [
      //           BottomNavigationBarItem(
      //             icon: Icon(Icons.home),
      //             label: 'Home',
      //           ),
      //           BottomNavigationBarItem(
      //             icon: Icon(Icons.group),
      //             label: 'Gruppi',
      //           )
      //         ],
      //       ),
      //     ),
      //   ),
      //),
    );
  }
}