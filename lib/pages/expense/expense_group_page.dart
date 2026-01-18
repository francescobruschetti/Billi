import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:monitoraggio_spese/models/api_response_model.dart';
import 'package:monitoraggio_spese/services/expenses_service.dart';
import 'package:monitoraggio_spese/services/groups_service.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:monitoraggio_spese/widgets/components/loading_scaffold.dart';

class ExpenseGroupPage extends StatefulWidget {
  final String? expenseId;
  final bool isEditAllowed;

  const ExpenseGroupPage({super.key, this.expenseId, this.isEditAllowed = false});

  @override
  State<ExpenseGroupPage> createState() => _ExpenseGroupPageState();
}

class _ExpenseGroupPageState extends State<ExpenseGroupPage> {
  final double _defaultSizedBoxHeight = 6.0;

  late TextEditingController _priceController;
  late TextEditingController _splitRateController;
  late TextEditingController _merchantController;
  late TextEditingController _categoriesController;
  late TextEditingController _noteController;
  List<Map<String, dynamic>> _userGroups = [];
  Map<String, dynamic>? _selectedGroup;
  bool _isLoading = false;
  bool _isSaveEnabled = false;
  bool _isSplitRateSectionVisible = false;
  String? _errorMessage;
  String pageTitle = 'Inserisci Spesa';
  String? _selectedSplitRateValue;
  String? _selectedSplitRateValueButton;

  late final bool isEdit;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(text: '');
    _splitRateController = TextEditingController(text: '');
    _merchantController = TextEditingController(text: '');
    _categoriesController = TextEditingController(text: '');
    _noteController = TextEditingController(text: '');
    _priceController.addListener(_onFieldChanged);
    _splitRateController.addListener(_onFieldChanged);

    isEdit = widget.expenseId != null && widget.isEditAllowed;
    _pageTitleSetup();
    _loadUserGroups();

    if (widget.expenseId != null) {
      _loadExistingExpense(widget.expenseId!);
    }
  }
  
  @override
  void dispose() {
    _priceController.removeListener(_onFieldChanged);
    _splitRateController.removeListener(_onFieldChanged);
    _priceController.dispose();
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

  void _handleSplitRateValue(String value) {
    setState(() {
      if (_selectedSplitRateValueButton == value) {
        _selectedSplitRateValueButton = null; // Deseleziona se già selezionato
      } 
      else {
        _selectedSplitRateValueButton = value;
      }
      _selectedSplitRateValue = _selectedSplitRateValueButton;
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
      _isSaveEnabled = (_selectedGroup != null && _selectedSplitRateValue != null) && _priceController.text.isNotEmpty;
    });
  }

  void _pageTitleSetup() {
    pageTitle = isEdit ? 'Modifica Spesa di Gruppo' : 'Inserisci Spesa Gruppo';
  }

  void _toggleSplitRateSection() {
    setState(() {
      _isSplitRateSectionVisible = !_isSplitRateSectionVisible;
    });
  }

  Future<void> _loadExistingExpense(String expenseId) async {
    setState(() {
      _isLoading = true;
    });

    // TODO: da implementare caricamento spesa esistente
    // final groupDetailsResponse = await GroupsService().getGroupDetailsAndParticipants(expenseId);
    // print("Existing users in group $expenseId: $groupDetailsResponse");
    
    // if (groupDetailsResponse.success) {
    //   print("Group details: ${groupDetailsResponse.data}");
    //   _nameController.text = groupDetailsResponse.data.name;
    //   _descriptionController.text = groupDetailsResponse.data.description ?? '';
    //   _linkController.text = groupDetailsResponse.data.link;
      
    //   final userProfiles = groupDetailsResponse.data.groupParticipants.map((p) => p.profile).toList();
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

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _loadUserGroups() async {
    final groups = await GroupsService().fetchAllGroupsForUser();
    if (mounted) {
      setState(() {
        _userGroups = groups;
      });
    }
  }
  
  Future<void> _saveExpense() async {
    setState(() {
      _errorMessage = null;
      _isSaveEnabled = false;
    });

    String message = isEdit ? "Dati aggiornati" : "Dati salvati";
    ApiResponseModel<Map<String, dynamic>> apiResponseModel = ApiResponseModel<Map<String, dynamic>>(
      success: false, message: "Errore durante il salvataggio dei dati", data: {}
    );

    if (isEdit) { // Logica di salvataggio modifica gruppo
      apiResponseModel = await ExpensesService().updateGroup(
        groupId: _selectedGroup!['id'],
        expenseId: widget.expenseId!,
        price: _formatPriceInput(),

        merchant: _merchantController.text.trim(),
        categories: _categoriesController.text.trim(),
        note: _noteController.text.trim(),
      );
    } 
    else { // Logica di creazione nuovo gruppo
      apiResponseModel = await ExpensesService().createGroup(
        groupId: _selectedGroup!['id'],
        price: _formatPriceInput(),
        merchant: _merchantController.text.trim(),
        categories: _categoriesController.text.trim(),
        note: _noteController.text.trim(),
      );
    }
    
    if (apiResponseModel.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      Navigator.of(context).pop(true); // Torna indietro e segnala che c'è stato un cambiamento
    }
    else {
      setState(() {
        _errorMessage = 'Errore durante il salvataggio';
        _isSaveEnabled = true;
      });
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
                
                // -- Prezzo
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
                          labelText: 'Prezzo',
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

                // -- Split Rate
                SizedBox(height: _defaultSizedBoxHeight),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _splitRateController,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^[0-9]*[.,]?[0-9]*$')),
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Suddivisione',
                          suffixIcon: Padding(
                            padding: EdgeInsets.only(right: 12.0),
                            child: Text('%', style: TextStyle(fontSize: 18)),
                          ),
                          suffixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
                        ),
                      ),
                    ),                    
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      child: IconButton(
                        icon: const Icon(Icons.settings),
                        color: Colors.black,
                        iconSize: 28,
                        padding: const EdgeInsets.all(8),
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(Colors.grey.shade200),
                          shape: WidgetStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          elevation: WidgetStateProperty.all(0),
                        ),
                        onPressed: () {
                          _toggleSplitRateSection();
                        },
                      ),
                    ),
                  ],
                ),
                if (_isSplitRateSectionVisible) ...[
                  
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
                                side: (_selectedSplitRateValueButton == 'fixed25%' ? BorderSide(color: Colors.black) : BorderSide.none),
                              ),
                              backgroundColor: Colors.grey.shade200,
                              foregroundColor: Colors.black87,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                            ),
                            onPressed: () => _handleSplitRateValue('fixed25%'),
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
                                side: (_selectedSplitRateValueButton == 'fixed50%' ? BorderSide(color: Colors.black) : BorderSide.none),
                              ),
                              backgroundColor: Colors.grey.shade200,
                              foregroundColor: Colors.black87,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                            ),
                            onPressed: () => _handleSplitRateValue('fixed50%'),
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
                                side: (_selectedSplitRateValueButton == 'fixed75%' ? BorderSide(color: Colors.black) : BorderSide.none),
                              ),
                              backgroundColor: Colors.grey.shade200,
                              foregroundColor: Colors.black87,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                            ),
                            onPressed: () => _handleSplitRateValue('fixed75%'),
                            child: const Text('75%'),
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
                                side: (_selectedSplitRateValueButton == 'fixed100%' ? BorderSide(color: Colors.black) : BorderSide.none),
                              ),
                              backgroundColor: Colors.grey.shade200,
                              foregroundColor: Colors.black87,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
                            ),
                            onPressed: () => _handleSplitRateValue('fixed100%'),
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
                                side: (_selectedSplitRateValueButton == 'quote2' ? BorderSide(color: Colors.black) : BorderSide.none),
                              ),
                              backgroundColor: Colors.grey.shade200,
                              foregroundColor: Colors.black87,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                            ),
                            onPressed: () => _handleSplitRateValue('quote2'),
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
                                side: (_selectedSplitRateValueButton == 'quote3' ? BorderSide(color: Colors.black) : BorderSide.none),
                              ),
                              backgroundColor: Colors.grey.shade200,
                              foregroundColor: Colors.black87,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                            ),
                            onPressed: () => _handleSplitRateValue('quote3'),
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
                                side: (_selectedSplitRateValueButton == 'quote4' ? BorderSide(color: Colors.black) : BorderSide.none),
                              ),
                              backgroundColor: Colors.grey.shade200,
                              foregroundColor: Colors.black87,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                            ),
                            onPressed: () => _handleSplitRateValue('quote4'),
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
                        _saveExpense();
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