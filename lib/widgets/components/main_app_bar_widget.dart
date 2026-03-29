
import 'package:flutter/material.dart';

class MainAppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  const MainAppBarWidget({super.key});
  
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
        title: const Text('Billy - Monitoraggio Spese'),
        actions: [ ],
        // backgroundColor: Colors.red,
        // shape: const RoundedRectangleBorder(
        //   borderRadius: BorderRadius.all(Radius.circular(20)),
        // ),
    );
  }
}