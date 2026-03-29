import 'package:Billy/constants.dart';
import 'package:Billy/exceptions/app_exception.dart';
import 'package:Billy/models/group_participant_model.dart';
import 'package:Billy/providers/group_provider.dart';
import 'package:Billy/utils/generic_util.dart';
import 'package:Billy/widgets/components/custom_validated_textfield_widget.dart';
import 'package:Billy/widgets/components/error_alert_widget.dart';
import 'package:Billy/widgets/components/search_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:Billy/models/profile_model.dart';
import 'package:Billy/services/group_service.dart';
import 'package:Billy/services/profile_service.dart';
import 'package:Billy/widgets/components/loading_scaffold.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GroupDetailsPage extends ConsumerStatefulWidget {
  final String? groupId; // null = creazione, non null = modifica
  final bool isEditAllowed;

  const GroupDetailsPage({super.key, this.groupId, this.isEditAllowed = false});

  @override
  ConsumerState<GroupDetailsPage> createState() => _GroupDetailsPageState();
}

class _GroupDetailsPageState extends ConsumerState<GroupDetailsPage> {
  final Logger log = Logger('GroupDetailsPage');
  
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _linkController;
  bool _isLoading = false;
  bool _isSaveEnabled = false;
  bool _isSearching = false;
  bool _showOnlyError = false; // TODO: da implementare
  String? _errorMessage;
  String _searchUser = '';
  final List<GroupParticipantModel> _selectedUsers = [];
  final List<String> _removedUserIds = [];
  final List<ProfileModel> _existingUsers = [];

  late final bool isEdit;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: '');
    _descriptionController = TextEditingController(text: '');
    _linkController = TextEditingController(text: '');
    _nameController.addListener(_onNameChanged);

    if (widget.groupId != null) {
      _loadExistingGroup(widget.groupId!);
    }

    isEdit = widget.groupId != null && widget.isEditAllowed;
  }
  
  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _nameController.dispose();
    _descriptionController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  Future<void> _deleteGroup(String groupId) async {
    final confirmed = await GenericUtil.showConfirmationBeforeDeleteDialog(
      context, 
      'Conferma eliminazione', 
      "Sei sicuro di voler eliminare questo gruppo e tutti i dati associati?\nL'operazione non è reversibile.",
      confirmButtonText: 'Elimina',
      cancelButtonText: 'Annulla');
    if (confirmed != true) return;

    try {
      await GroupService().deleteGroup(groupId);
      ref.read(groupsProvider.notifier).removeGroupLocally(groupId);

      if (!mounted) return; // To ensure that "context" is still valid after using "await"
      GenericUtil.showSnackbar(context, 'Gruppo eliminato');
      _navigatePop(result: { 'deleteGroupId': groupId});    
    } 
    catch (e) {
      log.severe("Errore durante la cancellazione del gruppo: $e");
      if (mounted) {
        setState(() {
          _errorMessage = 'Errore durante la cancellazione del gruppo';
          _showOnlyError = true;
        });
      }
    } 
  }

  Future<void> _getExistingUser(String key) async {
    if (mounted) {
      setState(() {
        _isSearching = true;
        _errorMessage = null;
        _showOnlyError = false;
      });
    }

    try {
      final res = await ProfileService().getUserByEmailOrUsername(key);
      log.fine("User search result: $res");
      if (mounted) {
        setState(() {
          if (_existingUsers.any((u) => u.id == res.id)) {
            GenericUtil.showSnackbar(context, 'Utente ${res.username} già presente nel gruppo');
            return; // Salta utenti già presenti nel gruppo
          }
          if (!_selectedUsers.any((u) => u.userId == res.id)) {
            _selectedUsers.add(GroupParticipantModel(userId: res.id, profile: res));
          }
        });
      }
    } 
    catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Errore durante la ricerca dell\'utente: $e';
          _showOnlyError = true;
        });
      }
    } 
    finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  Future<void> _loadExistingGroup(String groupId) async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final groupDetailsResponse = await GroupService().fetchGroupDetailsAndParticipants(groupId);
      log.fine("Existing users in group $groupId: $groupDetailsResponse");
      if (mounted) {
        _nameController.text = groupDetailsResponse.name;
        _descriptionController.text = groupDetailsResponse.description ?? '';
        _linkController.text = groupDetailsResponse.link;
        final userProfiles = groupDetailsResponse.participants.map((p) => p.profile).toList();
        setState(() {
          _existingUsers.clear();
          _existingUsers.addAll(userProfiles);
        });
      }
    } 
    on GroupException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
        });
      }
    }
    catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Errore durante il caricamento dei dettagli del gruppo.';
        });
      }
    } 
    finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigatePop({Map<String, dynamic>? result}) {
    Navigator.of(context).pop(result);
  }

  void _onNameChanged() {
    setState(() {
      _isSaveEnabled = _nameController.text.trim().isNotEmpty;
    });
  }

  // Apri i dettagli del gruppo dopo la creazione
  void _openGroupDetails(String groupId) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => GroupDetailsPage(groupId: groupId, isEditAllowed: true)),
    );
  }

  Future<void> _saveGroup() async {
    if (mounted) {
      setState(() {
        _errorMessage = null;
        _isSaveEnabled = false;
      });
    }

    try {
      if (isEdit) { // Logica di salvataggio modifica gruppo
        final updated = await GroupService().updateGroup(
          id: widget.groupId!,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          participantsToAdd: _selectedUsers,
          participantsToRemoveIds: _removedUserIds,
        );

        ref.read(groupsProvider.notifier).updateGroupLocally(updated);

        if (!mounted) return;
        GenericUtil.showSnackbar(context, "Dati aggiornati correttamente");
        _navigatePop();
      } 
      else { // Logica di creazione nuovo gruppo
        final created = await GroupService().createGroup(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
        );

        ref.read(groupsProvider.notifier).addGroupLocally(created);

        if (!mounted) return;
        GenericUtil.showSnackbar(context, "Gruppo creato con successo");
        _openGroupDetails(created.id);
      }
    } 
    on GroupException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
        _isSaveEnabled = true;
      });
    } 
    catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = "Errore imprevisto, riprova più tardi";
        _isSaveEnabled = true;
      });
    }
  
  }

  @override
  Widget build(BuildContext context) {   

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(isEdit ? 'Dettagli gruppo' : 'Crea gruppo'),
        actions: [
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.delete_forever_rounded, color: AppConstants.red, size: 24),
              tooltip: 'Elimina gruppo',
              onPressed: () => _deleteGroup(widget.groupId!),
            ),
        ],
      ),
      body: _isLoading
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [LoadingScaffold(message: 'Caricamento dati gruppo...')],
            ),
          )
        : SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                CustomValidatedTextField(
                  controller: _nameController,
                  labelText: 'Nome gruppo',
                  validator: (value) => value.trim().isEmpty ? 'Il nome del gruppo è obbligatorio' : null,
                ),
                
                const SizedBox(height: AppConstants.sizedBoxHeight),
                CustomValidatedTextField(
                  controller: _descriptionController,
                  labelText: 'Descrizione',
                ),
                // if editing an existing group
                
                if (widget.groupId != null) ...[
                  // Link di invito
                  const SizedBox(height: AppConstants.sizedBoxHeight),
                  Row(
                    children: [
                      Expanded(
                        child: CustomValidatedTextField(
                          controller: _linkController,
                          labelText: 'Link',
                          prefixIcon: const Icon(Icons.link, size: 24),
                          readOnly: true,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy),
                        tooltip: 'Copia',
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: _linkController.text));
                          GenericUtil.showSnackbar(context, 'Link copiato negli appunti');
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.ios_share),
                        tooltip: 'Condividi',
                        onPressed: () => GenericUtil.showSnackbar(context, 'Funzione di condivisione non ancora implementata'), // TODO: implementare condivisione link
                      ),
                    ],
                  ),
                
                  // Aggiunta utenti al gruppo
                  const SizedBox(height: AppConstants.sizedBoxHeight),
                  Text('Aggiungi partecipanti:', style: TextStyle(fontWeight: FontWeight.bold)),
                  
                  const SizedBox(height: AppConstants.sizedBoxHeight),
                  Row(
                    children: [
                      Expanded(
                        child: SearchFieldWidget(
                          hintText: 'Cerca utente per username o email',
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
                  const SizedBox(height: AppConstants.sizedBoxHeight),
                  if (_selectedUsers.isNotEmpty) ...[
                    Row(
                      children: [
                        const Text('Nuovi partecipanti:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        Text('(${_selectedUsers.length})'),
                      ],
                    ),
                    const SizedBox(height: AppConstants.sizedBoxHeight),
                    Wrap(
                      spacing: 8,
                      children: _selectedUsers.map((u) => Chip(
                        label: Text(u.profile.username),
                        onDeleted: () {
                          setState(() {
                            _selectedUsers.removeWhere((x) => x.userId == u.userId);
                          });
                        },
                      )).toList(),
                    ),
                  ],

                  // List of users already in group
                  const SizedBox(height: AppConstants.sizedBoxHeight),
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
                    const SizedBox(height: AppConstants.sizedBoxHeight),
                    Wrap(
                      spacing: 8,
                      children: _existingUsers.map((u) => Chip(
                        label: Text((u.username.isNotEmpty) ? u.username : u.name),
                        onDeleted: () {
                          setState(() {
                            _existingUsers.removeWhere((x) => x.id == u.id);
                            _removedUserIds.add(u.id);
                          });
                        },
                      )).toList(),
                    ),
                  ],
                ],
                      
                // Alert errore
                if (_errorMessage != null) ...[
                  ErrorAlertWidget(errorMessage: _errorMessage!),
                ],
                
                // Save/Cancel buttons
                const SizedBox(height: AppConstants.sizedBoxHeight),
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
                      onPressed: () => _navigatePop(),
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