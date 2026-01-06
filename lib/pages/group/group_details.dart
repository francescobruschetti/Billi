import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:monitoraggio_spese/models/api_response_model.dart';
import 'package:monitoraggio_spese/models/profile_model.dart';
import 'package:monitoraggio_spese/services/groups_service.dart';
import 'package:monitoraggio_spese/services/profiles_service.dart';

class GroupDetailsPage extends StatefulWidget {
  final String? groupId; // null = creazione, non null = modifica
  final bool isEdit;

  const GroupDetailsPage({super.key, this.groupId, this.isEdit = false});

  @override
  State<GroupDetailsPage> createState() => _GroupDetailsPageState();
}

class _GroupDetailsPageState extends State<GroupDetailsPage> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _linkController;
  bool _isLoading = false;
  bool _isSaveEnabled = false;
  bool _isSearching = false;
  String? _errorMessage;
  String _searchUser = '';
  final List<Map<String, dynamic>> _selectedUsers = [];
  final List<ProfileModel> _existingUsers = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: '');
    _descriptionController = TextEditingController(text: '');
    _linkController = TextEditingController(text: '');
    _nameController.addListener(_onNameChanged);

    if (widget.groupId != null) {
      _loadExistingUsers(widget.groupId!);
    }    
  }

  void _onNameChanged() {
    setState(() {
      _isSaveEnabled = _nameController.text.trim().isNotEmpty;
    });
  }

  // Apri i dettagli del gruppo dopo la creazione
  void _openGroupDetails(Map<String, dynamic> groupDetails) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => GroupDetailsPage(groupId: groupDetails['id'], isEdit: false)),
    );
  }

  Future<void> _getExistingUser(String key) async {
    setState(() {
      _isSearching = true;
      _errorMessage = null;
    });

    try {
      final res = await ProfilesService().getUserByEmailOrUsername(key);
      print("User search result: $res");
      if (res.isEmpty) {
        setState(() {
          _errorMessage = 'Nessun utente trovato con username o email "$key"';
        });
      } 
      else {
        setState(() {
          res.forEach((user) {
            if (_existingUsers.any((u) => u.id == user['id'])) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Utente ${user['username'] ?? user['email'] ?? user['id']} già presente nel gruppo')),
              );
              return; // Salta utenti già presenti nel gruppo
            }
            if (!_selectedUsers.any((u) => u['id'] == user['id'])) {
              _selectedUsers.add(user);
            }
          });
        });
      }
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

  Future<void> _loadExistingUsers(String groupId) async {
    setState(() {
      _isLoading = true;
    });

    final groupDetailsResponse = await GroupsService().getGroupDetailsAndParticipants(groupId);
    print("Existing users in group $groupId: $groupDetailsResponse");
    
    if (groupDetailsResponse.success) {
      print("Group details: ${groupDetailsResponse.data}");
      _nameController.text = groupDetailsResponse.data.name;
      _descriptionController.text = groupDetailsResponse.data.description ?? '';
      _linkController.text = groupDetailsResponse.data.link;
      
      final userProfiles = groupDetailsResponse.data.groupParticipants.map((p) => p.profile).toList();
      setState(() {
        _existingUsers.clear();
        _existingUsers.addAll(userProfiles);
      });
    }
    else {
      setState(() {
        _errorMessage = 'Errore durante il caricamento dei partecipanti esistenti: ${groupDetailsResponse.message}';
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveGroup() async {
    setState(() {
      _errorMessage = null;
      _isSaveEnabled = false;
    });

    ApiResponseModel<Map<String, dynamic>> apiResponseModel = ApiResponseModel<Map<String, dynamic>>(success: false, message: "Errore nella salvataggio dei dati", data: {});
    if (widget.isEdit) { // Logica di salvataggio modifica gruppo
      apiResponseModel = await GroupsService().updateGroup(
        id: widget.groupId!,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        participantsToAdd: _selectedUsers,
        // TODO: participantsToRemove: _existingUsers.where((u) => !_existingUsers.contains(u)).toList(),
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
    final isEdit = widget.isEdit || widget.groupId != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Modifica gruppo' : 'Crea gruppo'),
      ),
      body: _isLoading
        // Loading indicator
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Caricamento dati gruppo...', style: TextStyle(fontSize: 16)),
              ],
            ),
          )
        // Page content loaded
        : Padding(
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
            if (widget.groupId != null) ...[
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
              
              // List of users to be added to group
              const SizedBox(height: 8),
              if (_selectedUsers.isNotEmpty) ...[
                Row(
                  children: [
                    const Text('Nuovi partecipanti:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Text('(${_selectedUsers.length})'),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _selectedUsers.map((u) => Chip(
                    label: Text(u['username'] ?? u['email'] ?? u['id']),
                    onDeleted: () {
                      setState(() => _selectedUsers.removeWhere((x) => x['id'] == u['id']));
                    },
                  )).toList(),
                ),
              ],

              // List of users already in group
              const SizedBox(height: 8),
              if (_existingUsers.isEmpty) ...[
                const Text('Nessun partecipante nel gruppo'),
              ]
              else ...[
                Row(
                  children: [
                    const Text('Partecipanti:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Text('(${_existingUsers.length})'),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _existingUsers.map((u) => Chip(
                    label: Text((u.username.isNotEmpty) ? u.username : u.name),
                    onDeleted: () {
                      setState(() => _existingUsers.removeWhere((x) => x.id == u.id));
                    },
                  )).toList(),
                ),
              ],
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