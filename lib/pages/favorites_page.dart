import 'package:flutter/material.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Preferiti')),
      body: const Center(
        child: Text('Pagina Preferiti'),
      ),
    );
  }
}