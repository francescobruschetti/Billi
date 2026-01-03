import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GroupsService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<List<Map<dynamic, dynamic>>> fetchAllGroupsForUser() async {
    final userId = supabase.auth.currentUser!.id;
    final res = await supabase.rpc('get_user_groups');
    print("Fetched groups for user $userId: $res");

    return (res as List)
        .map((g) => g as Map<String, dynamic>)
        .toList();
  }

  Future<void> createGroupFlow(BuildContext context) async { // TODO: non mi convince, meglio creare una pagina dedicata con cui creare / modificare il gruppo
    String? groupName;
    // Primo popup: inserisci nome gruppo
    await showDialog(
      context: context,
      builder: (context) {
        String tempName = '';
        return AlertDialog(
          title: const Text('Crea gruppo'),
          content: TextField(
            decoration: const InputDecoration(hintText: 'Nome gruppo'),
            onChanged: (value) => tempName = value,
          ),
          actions: [
            TextButton(
              onPressed: () {
                groupName = tempName;
                Navigator.of(context).pop();
              },
              child: const Text('Avanti'),
            ),
          ],
        );
      },
    );
    if (groupName == null || groupName!.isEmpty) return;

    // Secondo popup: aggiungi utenti
    await showDialog(
      context: context,
      builder: (context) {
        String userInput = '';
        return AlertDialog(
          title: Text('Aggiungi utenti a "$groupName"'),
          content: TextField(
            decoration: const InputDecoration(hintText: 'Username o email'),
            onChanged: (value) => userInput = value,
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Qui puoi gestire la logica di aggiunta utenti
                Navigator.of(context).pop();
              },
              child: const Text('Aggiungi'),
            ),
          ],
        );
      },
    );
  }

}
