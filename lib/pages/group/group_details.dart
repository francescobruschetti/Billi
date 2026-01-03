import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GroupDetailsPage extends StatefulWidget {
  final Map<String, dynamic>? group; // null = creazione, non null = modifica
  final bool isEdit;

  const GroupDetailsPage({super.key, this.group, this.isEdit = false});

  @override
  State<GroupDetailsPage> createState() => _GroupDetailsPageState();
}

class _GroupDetailsPageState extends State<GroupDetailsPage> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _linkController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.group?['name'] ?? '');
    _descriptionController = TextEditingController(text: widget.group?['description'] ?? '');
    
    _linkController = TextEditingController(text: widget.group?['link'] ?? '');

  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.isEdit || widget.group != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Modifica gruppo' : 'Crea gruppo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campi di input
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nome gruppo'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Descrizione (opzionale)'),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _linkController,
                  decoration: const InputDecoration(labelText: 'Link'),
                  enabled: false,
                ),

                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: _linkController.text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Link copiato negli appunti')),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {
                    // TODO: da implementare
                  },
                ),
              ],  
            ),
            
            // Save/Cancel buttons
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {// Salva o crea gruppo
                    Navigator.of(context).pop({
                      'name': _nameController.text,
                      'description': _descriptionController.text,
                      'link': _linkController.text,
                    });
                  },
                  child: Text(isEdit ? 'Salva' : 'Crea'),
                ),
                const SizedBox(width: 16),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Annulla'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}