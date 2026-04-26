import 'package:Billy/constants.dart';
import 'package:Billy/exceptions/app_exception.dart';
import 'package:Billy/models/group_participant_model.dart';
import 'package:Billy/pages/group/components/invitation_link_bottom_sheet_widget.dart';
import 'package:Billy/providers/group_provider.dart';
import 'package:Billy/utils/generic_util.dart';
import 'package:Billy/widgets/components/custom_button_widget.dart';
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
  bool _isLoading = false;
  bool _isSaveEnabled = false;
  bool _isSearching = false;
  bool _showOnlyError = false; // TODO: da implementare

  String? _errorMessage;
  String _searchUser = '';
  late String _invitationLink;
  final List<GroupParticipantModel> _selectedUsers = [];
  final List<String> _removedUserIds = [];
  final List<ProfileModel> _existingUsers = [];

  late final bool isEdit;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: '');
    _descriptionController = TextEditingController(text: '');
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
    if ((_isSearching || key.isEmpty)) return;

    if (mounted) {
      setState(() {
        _isSearching = true;
        _errorMessage = null;
        _showOnlyError = false;
      });
    }

    try {
      final res = await ProfileService().getUserByEmailOrUsername(key);
      
      if (res.id.isEmpty) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Nessun utente trovato con email o username "$key"';
            _showOnlyError = true;
          });
        }
        return;
      }
      
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
      log.severe("Errore durante la ricerca dell'utente: $e");
      if (mounted) {
        setState(() {
          _errorMessage = 'Errore durante la ricerca dell\'utente';
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
        _invitationLink = groupDetailsResponse.link;

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

  void _openInviteLinkBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // obbligatorio per DraggableScrollableSheet
      backgroundColor: Colors.transparent, // lascia gestire il colore al sheet
      builder: (BuildContext context) => InvitationLinkBottomSheetWidget(
        title: 'Link di invito al gruppo',
        subTitle: 'Condividi questo link con altre persone per invitarle a partecipare al gruppo',
        link: _invitationLink,
      ),
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
              icon: const Icon(Icons.link, size: 24),
              tooltip: 'Mostra link di invito',
              onPressed: () => _openInviteLinkBottomSheet(),
            ),

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
            padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: MediaQuery.of(context).viewInsets.bottom), // Aggiunta di padding inferiore dinamico per evitare sovrapposizione da parte della tastiera
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
                  _buildAddUsersToGroup(),

                  // List of users to be added to group
                  _buildListOfUsersToBeAddedToGroup(),
                  
                  // List of users already in group
                  _buildListOfUsersAlreadyInGroup(),
                ],
                      
                // Alert errore
                if (_errorMessage != null) ...[
                  ErrorAlertWidget(errorMessage: _errorMessage!, onClose: () {
                    setState(() {
                      _errorMessage = null;
                    });
                  }),
                ],
                
                // Save/Cancel buttons
                const SizedBox(height: AppConstants.sizedBoxHeight),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomButtonWidget(
                      onPressed: () { // Salva o crea gruppo
                        _saveGroup();
                      },
                      text: isEdit ? 'Salva' : 'Crea',
                      isEnabled: _isSaveEnabled,
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

  Widget _buildAddUsersToGroup() {
    return Column(
      children: [
        // Aggiunta utenti al gruppo
        const SizedBox(height: AppConstants.sizedBoxHeight),
        Align(
          alignment: Alignment.centerLeft,
          child: Text('Aggiungi partecipanti:', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        
        const SizedBox(height: AppConstants.sizedBoxHeight),
        Row(
          children: [
            Expanded(
              child: SearchFieldWidget(
                hintText: 'Cerca utente per username o email',
                onChanged: (value) => setState(() => _searchUser = value), // Nota: quando SearchFieldWidget._onClose().widget.onChanged('') viene chiamato, _searchText viene resettato a ''
                onClose: () => setState(() { // Aggiunto per sicurezza
                  _searchUser = '';
                }),
                onSubmitted: (value) {
                    _getExistingUser(value);
                },
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => _getExistingUser(_searchUser),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Theme.of(context).colorScheme.secondaryContainer, width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSearching 
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) 
                : Text('Cerca', style: TextStyle(color: Theme.of(context).colorScheme.onSecondaryContainer)), // es. , fontWeight: FontWeight.bold)),
            ),
          ],
        ),
                 
      ],
    );
  }

  Widget _buildListOfUsersToBeAddedToGroup() {
    return Column(
      children: [
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
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _selectedUsers.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final user = _selectedUsers[i];
              return ListTile(
                leading: Icon(Icons.account_circle_rounded, color: Colors.orange[700], size: 32),
                title: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.profile.name),
                    Text(" (@${user.profile.username})", style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                  ],
                ),
                trailing: 
                  // TODO: add icon only user is not a CREATOR
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: AppConstants.red),
                    tooltip: 'Rimuovi',
                    onPressed: () {
                      setState(() {
                        _selectedUsers.removeWhere((u) => u.profile.id == user.profile.id);
                      });
                    },
                  ),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildListOfUsersAlreadyInGroup() {
    return Column(
      children: [
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
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _existingUsers.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final user = _existingUsers[i];
              return ListTile(
                leading: Icon(Icons.account_circle_rounded, color: Colors.orange[700], size: 32),
                title: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.name),
                    Text(" (@${user.username})", style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                  ],
                ),
                trailing: 
                  // TODO: add icon only user is not a CREATOR
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: AppConstants.red),
                    tooltip: 'Rimuovi dal gruppo',
                    onPressed: () {
                      setState(() {
                        _removedUserIds.add(user.id);
                        _existingUsers.removeWhere((u) => u.id == user.id);
                      });
                    },
                  ),
              );
            },
          ),
        ],
      ],
    );
  }


  Widget _buildListTile({ required String name, required String username}) {
    // return ListTile(
    //   leading: Icon(Icons.account_circle_rounded, color: Colors.orange[700], size: 32),
    //   title: Row(
    //     children: [
    //       Text(name),
    //       const Spacer(),
    //       Text('@$username', style: TextStyle(color: Colors.grey[600])),

    //     ],
    //   ),
    //   // onTap: onTap
    // );
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: ListView.separated(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: _existingUsers.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final user = _existingUsers[i];
          return _buildListTile(
            name: user.name,
            username: user.username,
          );
        },
      ),
    );
  }
}