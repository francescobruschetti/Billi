import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:monitoraggio_spese/models/api_response_model.dart';
import 'package:monitoraggio_spese/services/groups_service.dart';
import 'package:monitoraggio_spese/services/profiles_service.dart';

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
  bool _isSaveEnabled = false;
  bool _isSearching = false;
  String? _errorMessage;
  String _searchUser = '';
  List<Map<String, dynamic>> _selectedUsers = [];
  List<Map<String, dynamic>> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.group?['name'] ?? '');
    _descriptionController = TextEditingController(text: widget.group?['description'] ?? '');
    _linkController = TextEditingController(text: widget.group?['link'] ?? '');
    _nameController.addListener(_onNameChanged);
  }

  void _onNameChanged() {
    setState(() {
      _isSaveEnabled = _nameController.text.trim().isNotEmpty;
    });
  }

  void _openGroupDetails(Map<String, dynamic> groupDetails) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => GroupDetailsPage(group: groupDetails, isEdit: false)),
    );
  }

  Future<void> _saveGroup() async {
    setState(() {
      _errorMessage = null;
      _isSaveEnabled = false;
    });

    ApiResponseModel<Map<String, dynamic>> apiResponseModel = ApiResponseModel<Map<String, dynamic>>(success: false, message: "Errore nella salvataggio dei dati", data: {});
    if (widget.isEdit) { // Logica di salvataggio modifica gruppo
      apiResponseModel = await GroupsService().updateGroup(
        id: widget.group!['id'],
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
      );
    } 
    else { // Logica di creazione nuovo gruppo
      apiResponseModel = await GroupsService().createGroup(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
      );
    }

    if (apiResponseModel.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gruppo creato con successo :)')),
      );
      _openGroupDetails(apiResponseModel.data);
    }
    else {
      setState(() {
        _errorMessage = 'Errore nella creazione del gruppo';
        _isSaveEnabled = true;
      });
    }
  }

  Future<void> _getExistingUser(String key) async {
    setState(() {
      _isSearching = true;
      _errorMessage = null;
      _searchResults = [];
    });

    try {
      final res = await ProfilesService().getUserByEmailOrUsername(key);
      setState(() {
        _searchResults = [res as Map<String, dynamic>];
      });
    } 
    catch (e) {
      setState(() {
        _errorMessage = 'Errore durante la ricerca dell\'utente: $e';
      });
    } 
    finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
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
            // if editing an existing group
            if (widget.group != null) ...[
              // Link di invito
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _linkController,
                      decoration: const InputDecoration(labelText: 'Link'),
                      readOnly: true,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    tooltip: 'Copia',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _linkController.text));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Link copiato negli appunti')),
                      );
                    },
                  ),
                  // IconButton(
                  //   icon: const Icon(Icons.ios_share),
                  //   tooltip: 'Condividi',
                  //   onPressed: () {
                  //     // TODO: implementa la logica di condivisione
                  //   },
                  // ),
                ],
              ),
            
              // Aggiunta utenti al gruppo
              const SizedBox(height: 16),
              Text('Aggiungi partecipanti:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: const InputDecoration(
                        hintText: 'Cerca utente per username o email',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      onChanged: (value) {
                        setState(() => _searchUser = value);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: (_isSearching || _searchUser.isEmpty) ? null : () => _getExistingUser(_searchUser),
                    child: _isSearching ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Cerca'),
                  ),
                ],
              ),
              
            ],
                  
            // Alert errore
            if (_errorMessage != null) ...[
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            // Save/Cancel buttons
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _isSaveEnabled ? () { // Salva o crea gruppo
                    _saveGroup();
                  } : null, // Disabilita il pulsante se il nome è vuoto
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