import 'package:Billy/enums/transaction_insert_mode_enum.dart';
import 'package:Billy/services/transactions_service.dart';
import 'package:Billy/widgets/components/custom_snackbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Billy/enums/split_rate_mode_enum.dart';
import 'package:Billy/models/api_response_model.dart';
import 'package:Billy/services/groups_service.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:Billy/widgets/components/loading_scaffold.dart';

class TransactionGroupPage extends StatefulWidget {
  final String? groupId;
  final String? transactionId;
  final bool isEditAllowed;

  const TransactionGroupPage({super.key, this.groupId, this.transactionId, this.isEditAllowed = false});

  @override
  State<TransactionGroupPage> createState() => _TransactionGroupPageState();
}

class _TransactionGroupPageState extends State<TransactionGroupPage> {
  final double _defaultSizedBoxHeight = 6.0;

  late TextEditingController _priceController;
  late TextEditingController _paidAmountController;
  late TextEditingController _splitRateController;
  late TextEditingController _merchantController;
  late TextEditingController _categoriesController;
  late TextEditingController _noteController;
  List<Map<String, dynamic>> _userGroups = [];
  Map<String, dynamic>? _selectedGroup;
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
    _loadUserGroups();

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

  bool _filterGroups(Map<String, dynamic> item, String filter) {
    final name = (item['name'] ?? '').toString().toLowerCase();
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

  void _onGroupChanged(Map<String, dynamic>? selected) {
    setState(() {
      _selectedGroup = selected;
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

  Future<void> _loadExistingTransaction(String transactionId) async {
    setState(() {
      _isLoading = true;
    });

    // TODO: da implementare caricamento spesa esistente
    // final groupDetailsResponse = await GroupsService().getGroupDetailsAndParticipants(transactionId);
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

  Future<void> _loadUserGroups() async {
    final groups = await GroupsService().fetchAllGroupsForUser();
    if (mounted) {
      setState(() {
        _userGroups = groups;
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

    String message = isEdit ? "Dati aggiornati" : "Dati salvati";
    ApiResponseModel<Map<String, dynamic>> apiResponseModel = ApiResponseModel<Map<String, dynamic>>(
      success: false, message: "Errore durante il salvataggio dei dati", data: {}
    );

    if (isEdit) { // Logica di salvataggio modifica gruppo
      apiResponseModel = await TransactionsService().updateGroupTransaction(
        groupId: _selectedGroup!['id'],
        transactionId: widget.transactionId!,
        price: _formatPriceInput(),
        merchant: _merchantController.text.trim(),
        categories: _categoriesController.text.trim(),
        note: _noteController.text.trim(),
      );
    } 
    else { // Logica di creazione nuovo gruppo
      apiResponseModel = await TransactionsService().createGroupTransaction(
        groupId: _selectedGroup!['id'],
        price: _formatPriceInput(),
        splitRate: _selectedSplitRateValue,
        paidAmount: double.tryParse(_paidAmountController.text.replaceAll(',', '.')),
        merchant: _merchantController.text.trim(),
        categories: _categoriesController.text.trim(),
        note: _noteController.text.trim(),
      );
    }
    
    if (apiResponseModel.success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          CustomSnackkBarWidget( 
            text: message,
          ).build(context),
        );
        Navigator.of(context).pop(true); // Torna indietro e segnala che c'è stato un cambiamento
      }
    }
    else {
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
    
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(pageTitle),
      ),
      body: _isLoading
        ? const LoadingScaffold(message: 'Carico...')
        : SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [ // -- Campi di input
                // -- Gruppo
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: 
                    DropdownSearch<Map<String, dynamic>>(
                      items: _userGroups,
                      itemAsString: (g) => g['name'] ?? '-',
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
                    )
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
                          // TODO: onPressed: (_transactionInsertMode != TransactionInsertModeEnum.SPLIT_RATE) ? () => _handleTransactionInsertModeValue(TransactionInsertModeEnum.FIX_PAID) : null,
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
                          // TODO: onPressed: (_transactionInsertMode != TransactionInsertModeEnum.FIX_PAID) ? () => _handleTransactionInsertModeValue(TransactionInsertModeEnum.SPLIT_RATE) : null,
                          onPressed: () => _handleTransactionInsertModeValue(TransactionInsertModeEnum.SPLIT_RATE),
                          child: const Text('Dividi spesa'),
                        ),
                      ),
                    ),
                  ],
                ),


                if (_transactionInsertMode == TransactionInsertModeEnum.FIX_PAID) ...[
                  SizedBox(height: _defaultSizedBoxHeight),
                  TextField(
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
                  ),
                ]
                else if (_transactionInsertMode == TransactionInsertModeEnum.SPLIT_RATE) ...[
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
                SizedBox(height: _defaultSizedBoxHeight),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _isSaveEnabled ? () { // Salva o crea gruppo
                        _saveTransaction();
                      } : null, // Disabilita il pulsante se il nome è vuoto
                      child: const Text('Salva'),
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