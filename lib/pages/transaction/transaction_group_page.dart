import 'package:Billy/constants.dart';
import 'package:Billy/enums/transaction_insert_mode_enum.dart';
import 'package:Billy/enums/transaction_type_enum.dart';
import 'package:Billy/models/group_details_model.dart';
import 'package:Billy/providers/group_provider.dart';
import 'package:Billy/services/transaction_service.dart';
import 'package:Billy/utils/generic_util.dart';
import 'package:Billy/widgets/components/error_alert_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Billy/enums/split_rate_mode_enum.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

class TransactionGroupPage extends ConsumerStatefulWidget {
  final String? groupId;
  final String? transactionId;
  final bool isEditAllowed;

  const TransactionGroupPage({super.key, this.groupId, this.transactionId, this.isEditAllowed = false});

  @override
  ConsumerState<TransactionGroupPage> createState() => _TransactionGroupPageState();
}

class _TransactionGroupPageState extends ConsumerState<TransactionGroupPage> {
  final Logger log = Logger('TransactionGroupPage');
  final double _defaultSizedBoxHeight = 6.0;

  late TextEditingController _priceController;
  late TextEditingController _paidAmountController;
  late TextEditingController _splitRateController;
  late TextEditingController _merchantController;
  late TextEditingController _categoriesController;
  late TextEditingController _noteController;
  GroupDetailsModel? _selectedGroup;
  bool _isLoading = false;
  bool _isSaveEnabled = false;
  TransactionInsertModeEnum? _transactionInsertMode;
  String? _errorMessage;
  String pageTitle = 'Inserisci Spesa';
  String? _selectedSplitRateValue;
  SplitRateModeEnum? _selectedSplitRateValueButton;

  late final bool isEdit;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(text: '');
    _paidAmountController = TextEditingController(text: '');
    _splitRateController = TextEditingController(text: '');
    _merchantController = TextEditingController(text: '');
    _categoriesController = TextEditingController(text: '');
    _noteController = TextEditingController(text: '');
    _priceController.addListener(_onFieldChanged);
    _paidAmountController.addListener(_onFieldChanged);
    _splitRateController.addListener(_onFieldChanged);

    isEdit = widget.transactionId != null && widget.isEditAllowed;
    _pageTitleSetup();

    if (widget.transactionId != null) {
      _loadExistingTransaction(widget.transactionId!);
    }
  }
  
  @override
  void dispose() {
    _priceController.removeListener(_onFieldChanged);
    _paidAmountController.removeListener(_onFieldChanged);
    _splitRateController.removeListener(_onFieldChanged);
    _priceController.dispose();
    _paidAmountController.dispose();
    _splitRateController.dispose();
    _merchantController.dispose();
    _categoriesController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  GroupDetailsModel? _computeSelectedGroup(List<GroupDetailsModel> groups) {
    log.fine("Computing selected group for groupId ${widget.groupId} from groups: $groups");
    if (widget.groupId == null) return null;
    try {
      return groups.firstWhere((g) => g.id == widget.groupId);
    }
    catch (e) {
      log.warning("Group with id ${widget.groupId} not found in groups: $groups", e);
      // Se non trova il gruppo, ritorna null
      return null;
    }
  }

  bool _filterGroups(GroupDetailsModel item, String filter) {
    final name = (item.name).toLowerCase();
    return name.contains(filter.toLowerCase());
  }

  double _formatPriceInput() {
    String text = _priceController.text;
    text = text.replaceAll(',', '.');
    _priceController.value = _priceController.value.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    return double.tryParse(text) ?? 0.0;
  }

  void _handleTransactionInsertModeValue(TransactionInsertModeEnum value) {
    setState(() {
      _selectedSplitRateValueButton = null;
      _selectedSplitRateValue = null;
      _transactionInsertMode = value;
    });
  }

  void _handleSplitRateValue(SplitRateModeEnum value) {
    setState(() {
      _paidAmountController.text = '';
      if (_selectedSplitRateValueButton == value) {
        _selectedSplitRateValueButton = null; // Deseleziona se già selezionato
      } 
      else {
        _selectedSplitRateValueButton = value;
      }
      _selectedSplitRateValue = _selectedSplitRateValueButton?.name;
      _onFieldChanged();
    });
  }

  void _onGroupChanged(GroupDetailsModel? selected) {
    setState(() {
      _selectedGroup = selected!;
    });
    _onFieldChanged();
  }

  void _onFieldChanged() {
    setState(() {
      _isSaveEnabled = (_selectedGroup != null && (_paidAmountController.text.isNotEmpty || _selectedSplitRateValue != null) && _priceController.text.isNotEmpty);
    });
  }

  void _pageTitleSetup() {
    pageTitle = isEdit ? 'Modifica Spesa di Gruppo' : 'Inserisci Spesa Gruppo';
  }

  Future<bool> _confirmSave({required String message}) async {
    // Mostra dialog di conferma
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => _buildConfirmDialog(context, message: message),
    );

    return confirmed ?? false; // Ritorna false se l'utente chiude il dialog senza scegliere
  }

  Future<void> _loadExistingTransaction(String transactionId) async {
    setState(() {
      _isLoading = true;
    });

    // TODO: da implementare caricamento spesa esistente
    // final groupDetailsResponse = await GroupService().fetchGroupDetailsAndParticipants(transactionId);
    // log.fine("Existing users in group $transactionId: $groupDetailsResponse");
    
    // if (groupDetailsResponse.success) {
    //   log.fine("Group details: ${groupDetailsResponse.data}");
    //   _nameController.text = groupDetailsResponse.data.name;
    //   _descriptionController.text = groupDetailsResponse.data.description ?? '';
    //   _linkController.text = groupDetailsResponse.data.link;
      
    //   final userProfiles = groupDetailsResponse.data.participants.map((p) => p.profile).toList();
    //   setState(() {
    //     _existingUsers.clear();
    //     _existingUsers.addAll(userProfiles);
    //   });
    // }
    // else {
    //   setState(() {
    //     _errorMessage = 'Errore durante il caricamento dei partecipanti esistenti: ${groupDetailsResponse.message}';
    //   });
    // }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _saveTransaction() async {
    if (mounted) {
      setState(() {
        _errorMessage = null;
        _isSaveEnabled = false;
      });
    }

    try {
      if (_paidAmountController.text.isEmpty && _selectedSplitRateValue == null) {
        throw Exception("Devi specificare una quota pagata o un tasso di divisione");
      }

      double formattedPrice = _formatPriceInput();
      double? paidAmount;
      if (_paidAmountController.text.isNotEmpty) {
        paidAmount = double.tryParse(_paidAmountController.text.replaceAll(',', '.')) ?? 0.0;
        if (paidAmount > formattedPrice) {
          final bool proceed = await _confirmSave(message: "La quota pagata è maggiore del totale. Vuoi procedere comunque?");
          if (!proceed) {
            setState(() {
              _isSaveEnabled = true;
            });
            return; // Esci dalla funzione senza salvare
          }
        }
      }

      if (isEdit) { // Logica di salvataggio modifica gruppo
        await TransactionService().updateGroupTransaction(
          groupId: _selectedGroup!.id,
          transactionId: widget.transactionId!,
          price: formattedPrice,
          transactionType: TransactionTypeEnum.EXPENSE, // TODO: da impostare in base alla selezione dell'utente
          merchant: _merchantController.text.trim(),
          categories: _categoriesController.text.trim(),
          note: _noteController.text.trim(),
        );
      } 
      else { // Logica di creazione nuovo gruppo
        await TransactionService().createGroupTransaction(
          groupId: _selectedGroup!.id,
          price: formattedPrice,
          transactionType: TransactionTypeEnum.EXPENSE, // TODO: da impostare in base alla selezione dell'utente
          splitRate: _selectedSplitRateValue,
          paidAmount: paidAmount,
          merchant: _merchantController.text.trim(),
          categories: _categoriesController.text.trim(),
          note: _noteController.text.trim(),
        );
      }
    
      if (mounted) {
        GenericUtil.showSnackbar(context, isEdit ? "Dati aggiornati" : "Dati salvati");
        Navigator.of(context).pop(true); // Torna indietro e segnala che c'è stato un cambiamento
      }
    }
    catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Errore durante il salvataggio';
          _isSaveEnabled = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupsState = ref.watch(groupsProvider);
    // Calcola _selectedGroup solo quando cambia la lista dei gruppi
    if (_selectedGroup == null && widget.groupId != null) {
      _selectedGroup = _computeSelectedGroup(groupsState.value ?? []);
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(pageTitle),
      ),
      body: groupsState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Errore durante il caricamento. Riprovare")),
        data: (groups) {

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.rowHorizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [ // -- Campi di input
                // -- Gruppo
                DropdownSearch<GroupDetailsModel>(
                  items: groups,
                  itemAsString: (g) => g.name,
                  selectedItem: _selectedGroup,
                  onChanged: _onGroupChanged,
                  dropdownDecoratorProps: const DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      labelText: 'Seleziona Gruppo',
                    ),
                  ),
                  filterFn: (item, filter) => _filterGroups(item, filter),
                  popupProps: PopupProps.menu(
                    showSearchBox: true,
                    searchFieldProps: TextFieldProps(
                      decoration: const InputDecoration(
                        labelText: 'Cerca gruppo...',
                        suffixIcon: Icon(Icons.search),
                      ),                      
                    ),
                  ),
                ),
                
                // -- Transaction Price
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _priceController,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^[0-9]*[.,]?[0-9]*$')),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Totale Spesa',
                          suffixIcon: Padding(
                            padding: EdgeInsets.only(right: 12.0),
                            child: Text('€', style: TextStyle(fontSize: 18)),
                          ),
                          suffixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                        ),
                      ),
                    ),
                  ],
                ),

                // -- Split Rate vs Paid Amount
                SizedBox(height: _defaultSizedBoxHeight),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: (_transactionInsertMode == TransactionInsertModeEnum.FIX_PAID ? BorderSide(color: Colors.black) : BorderSide.none),
                            ),
                            backgroundColor: const Color.fromARGB(255, 225, 250, 2),
                            foregroundColor: Colors.black87,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                          ),
                          onPressed: () => _handleTransactionInsertModeValue(TransactionInsertModeEnum.FIX_PAID),
                          child: const Text('Specifica quota'),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: (_transactionInsertMode == TransactionInsertModeEnum.SPLIT_RATE ? BorderSide(color: Colors.black) : BorderSide.none),
                            ),
                            backgroundColor: const Color.fromARGB(255, 11, 250, 238),
                            foregroundColor: Colors.black87,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                          ),
                          onPressed: () => _handleTransactionInsertModeValue(TransactionInsertModeEnum.SPLIT_RATE),
                          child: const Text('Dividi spesa'),
                        ),
                      ),
                    ),
                  ],
                ),

                if (_transactionInsertMode == TransactionInsertModeEnum.FIX_PAID) ...[
                  SizedBox(height: _defaultSizedBoxHeight),
                  _buildFixedRateComponents(),
                ]
                else if (_transactionInsertMode == TransactionInsertModeEnum.SPLIT_RATE) ...[
                  _buildSplitRateComponents(),
                ],

                // -- Negozio
                SizedBox(height: _defaultSizedBoxHeight),
                TextField(
                  controller: _merchantController,
                  decoration: const InputDecoration(labelText: 'Negozio'),
                ),
                
                // -- Categorie
                SizedBox(height: _defaultSizedBoxHeight),
                TextField(
                  controller: _categoriesController,
                  decoration: const InputDecoration(labelText: 'Categorie'),
                ),
                
                // -- Note
                SizedBox(height: _defaultSizedBoxHeight),
                TextField(
                  controller: _noteController,
                  decoration: const InputDecoration(labelText: 'Note'),
                ),

                // Alert errore
                if (_errorMessage != null) ...[
                  ErrorAlertWidget(errorMessage: _errorMessage!),
                ],
                
                // Save/Cancel buttons
                SizedBox(height: _defaultSizedBoxHeight),
                _buildSaveCancelButtons(),
              ],
            ),
          );
        }
      ),    
    );      
  }

  Widget _buildConfirmDialog(BuildContext context, {required String message}) {
    return AlertDialog(
      title: const Text('Conferma salvataggio'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Annulla'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Conferma'),
        ),
      ]
    );
  }

  Widget _buildFixedRateComponents() {
    return TextField(
      controller: _paidAmountController,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^[0-9]*[.,]?[0-9]*$')),
      ],
      decoration: const InputDecoration(
        labelText: 'Quota pagata',
        suffixIcon: Padding(
          padding: EdgeInsets.only(right: 12.0),
          child: Text('€', style: TextStyle(fontSize: 18)),
        ),
        suffixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
      ),
    );
  }

  Widget _buildSplitRateComponents() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: _defaultSizedBoxHeight),
        Text('Quanto paghi?', style: const TextStyle(fontWeight: FontWeight.bold)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: (_selectedSplitRateValueButton == SplitRateModeEnum.ONE_QUARTER ? BorderSide(color: Colors.black) : BorderSide.none),
                    ),
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                  ),
                  onPressed: () => _handleSplitRateValue(SplitRateModeEnum.ONE_QUARTER),
                  child: const Text('25%'),
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: (_selectedSplitRateValueButton == SplitRateModeEnum.HALF ? BorderSide(color: Colors.black) : BorderSide.none),
                    ),
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                  ),
                  onPressed: () => _handleSplitRateValue(SplitRateModeEnum.HALF),
                  child: const Text('50%'),
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: (_selectedSplitRateValueButton == SplitRateModeEnum.THREE_QUARTERS ? BorderSide(color: Colors.black) : BorderSide.none),
                    ),
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                  ),
                  onPressed: () => _handleSplitRateValue(SplitRateModeEnum.THREE_QUARTERS),
                  child: const Text('75%'),
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: (_selectedSplitRateValueButton == SplitRateModeEnum.EQUALLY ? BorderSide(color: Colors.black) : BorderSide.none),
                    ),
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                  ),
                  onPressed: () => _handleSplitRateValue(SplitRateModeEnum.EQUALLY),
                  child: const Text('Equally'),
                ),
              ),
            ),
            Expanded(
              flex: 2, // Bottone più largo per il 100%
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: (_selectedSplitRateValueButton == SplitRateModeEnum.ZERO ? BorderSide(color: Colors.black) : BorderSide.none),
                    ),
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
                  ),
                  onPressed: () => _handleSplitRateValue(SplitRateModeEnum.ZERO),
                  child: const Text('Hai anticipato tu'),
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: '%',
                    contentPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [ FilteringTextInputFormatter.digitsOnly, ],
                ),
              ),
            ),
          ],
        ),

        Text('Per quanti paghi?', style: const TextStyle(fontWeight: FontWeight.bold)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: (_selectedSplitRateValueButton == SplitRateModeEnum.FIXED_1 ? BorderSide(color: Colors.black) : BorderSide.none),
                    ),
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                  ),
                  onPressed: () => _handleSplitRateValue(SplitRateModeEnum.FIXED_1),
                  child: const Text('1'),
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: (_selectedSplitRateValueButton == SplitRateModeEnum.FIXED_2 ? BorderSide(color: Colors.black) : BorderSide.none),
                    ),
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                  ),
                  onPressed: () => _handleSplitRateValue(SplitRateModeEnum.FIXED_2),
                  child: const Text('2'),
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: (_selectedSplitRateValueButton == SplitRateModeEnum.FIXED_3 ? BorderSide(color: Colors.black) : BorderSide.none),
                    ),
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                  ),
                  onPressed: () => _handleSplitRateValue(SplitRateModeEnum.FIXED_3),
                  child: const Text('3'),
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: (_selectedSplitRateValueButton == SplitRateModeEnum.FIXED_4 ? BorderSide(color: Colors.black) : BorderSide.none),
                    ),
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                  ),
                  onPressed: () => _handleSplitRateValue(SplitRateModeEnum.FIXED_4),
                  child: const Text('4'),
                ),
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Altro',
                    contentPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 5),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                ),
              ),
            ),
          ],
        ),
      ]
    );
  }
  
  Widget _buildSaveCancelButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: _isSaveEnabled ? 
          () { // Salva o crea gruppo
            _saveTransaction();
          } 
          : null, // Disabilita il pulsante se il nome è vuoto
          child: const Text('Salva'),
        ),
        const SizedBox(width: 16),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annulla'),
        ),
      ],
    );
  }

}