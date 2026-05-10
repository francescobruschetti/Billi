import 'package:Billy/constants.dart';
import 'package:Billy/widgets/components/custom_icon_widget.dart';
import 'package:flutter/material.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: AppConstants.subtitleTextSize)),
          ),
          ListTile(
            leading: const CustomIconWidget(assetPath: 'assets/images/icons/outward.PNG', size: 24),
            title: const Text('Logout'),
            onTap: () {
              Navigator.of(context).pop(); // Chiude il drawer
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            },
          ),
        ],
      ),
    );
  }
}