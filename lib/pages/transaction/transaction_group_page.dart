import 'package:Billy/constants.dart';
import 'package:Billy/enums/transaction_type_enum.dart';
import 'package:Billy/models/create_category_response_model.dart';
import 'package:Billy/models/group_details_model.dart';
import 'package:Billy/models/group_expense_split_response_model.dart';
import 'package:Billy/pages/transaction/components/categories_bottom_sheet_widget.dart';
import 'package:Billy/pages/transaction/components/splitrate_vs_paidamount_bottom_sheet_widget.dart';
import 'package:Billy/providers/group_provider.dart';
import 'package:Billy/providers/ui_provider.dart';
import 'package:Billy/services/transaction_service.dart';
import 'package:Billy/utils/generic_util.dart';
import 'package:Billy/widgets/components/custom_button_widget.dart';
import 'package:Billy/widgets/components/custom_icon_widget.dart';
import 'package:Billy/widgets/components/custom_validated_textfield_widget.dart';
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
  final TransactionTypeEnum transactionType;
  final bool isEditAllowed;

  const TransactionGroupPage({super.key, required this.transactionType, this.groupId, this.transactionId, this.isEditAllowed = false});

  @override
  ConsumerState<TransactionGroupPage> createState() => _TransactionGroupPageState();
}

class _TransactionGroupPageState extends ConsumerState<TransactionGroupPage> {
  final Logger log = Logger('TransactionGroupPage');
  final double _defaultSizedBoxHeight = 6.0;

  late TextEditingController _priceController;
  late TextEditingController _merchantController;
  late TextEditingController _categoriesController;
  late TextEditingController _paymentMethodController; // TODO: da implementare
  late TextEditingController _noteController;
  GroupDetailsModel? _selectedGroup;
  bool _isLoading = false;
  bool _isSaveEnabled = false;
  late final bool isEdit;
  String? _errorMessage;
  String pageTitle = 'Inserisci Spesa';
  SplitRateModeEnum? _selectedSplitRateValueEnum;
  GroupExpenseSplitResponseModel? _groupExpenseSplitResponseModel;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(text: '');
    _merchantController = TextEditingController(text: '');
    _categoriesController = TextEditingController(text: '');
    _paymentMethodController = TextEditingController(text: '');
    _noteController = TextEditingController(text: '');
    _priceController.addListener(_onFieldChanged);

    isEdit = widget.transactionId != null && widget.isEditAllowed;
    _pageTitleSetup();

    if (widget.transactionId != null) {
      _loadExistingTransaction(widget.transactionId!);
    }
  }
  
  @override
  void dispose() {
    _priceController.removeListener(_onFieldChanged);

    _priceController.dispose();
    _merchantController.dispose();
    _categoriesController.dispose();
    _paymentMethodController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  GroupDetailsModel? _computeSelectedGroup(List<GroupDetailsModel> groups) {
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

  Future<bool> _confirmSave({required String message}) async {
    final confirmed = await GenericUtil.showConfirmationDialog(
      context, 
      'Conferma salvataggio', 
      message,
      confirmButtonText: 'Conferma',
      cancelButtonText: 'Annulla');

    return confirmed ?? false; // Ritorna false se l'utente chiude il dialog senza scegliere
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
  
  void _onGroupChanged(GroupDetailsModel? selected) {
    setState(() {
      _selectedGroup = selected!;
    });
    _onFieldChanged();
  }

  void _onFieldChanged() {
    setState(() {
      if (widget.transactionType == TransactionTypeEnum.EXPENSE) {
        _isSaveEnabled = (_selectedGroup != null 
          && (_selectedSplitRateValueEnum != null || _groupExpenseSplitResponseModel?.splitRateModeEnum != null)
          && _priceController.text.isNotEmpty
        );
      }
      else {
        _isSaveEnabled = (_selectedGroup != null && _priceController.text.isNotEmpty);
      }
    });
  }

  Future<void> _openCategoriesBottomSheet() async {
    final CreateCategoryResponseModel? categoryResponse = await showModalBottomSheet(
      context: context,
      isScrollControlled: true, // obbligatorio per DraggableScrollableSheet
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => CategoriesBottomSheetWidget(
        title: 'Seleziona Categoria',
      ),
    );

    if (categoryResponse != null) {
      _categoriesController.text = categoryResponse.category?.name ?? categoryResponse.newName ?? '';
    }
  }

  Future<void> _openSplitRateVsPaidAmountBottomSheet() async {
    GroupExpenseSplitResponseModel? response = await showModalBottomSheet(
      context: context,
      //enableDrag: false, // disabilita il drag per evitare chiusure accidentali
      //isDismissible: false, // disabilita la chiusura toccando fuori dal bottom sheet
      isScrollControlled: true, // obbligatorio per DraggableScrollableSheet
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => SplitrateVsPaidamountBottomSheetWidget(
        splitRateModeEnum: _selectedSplitRateValueEnum, 
        groupExpenseSplitResponseModel: _groupExpenseSplitResponseModel,
      ),
    );

    if (response != null) { // is null when user cancels/closes the bottom sheet without saving
      setState(() {
        _groupExpenseSplitResponseModel = response;
        _selectedSplitRateValueEnum = _groupExpenseSplitResponseModel!.splitRateModeEnum;
        _onFieldChanged(); // per aggiornare l'abilitazione del tasto salva in base alla nuova selezione
      });
    }
  }

  void _pageTitleSetup() {
    if (widget.transactionType == TransactionTypeEnum.EXPENSE) {
      pageTitle = isEdit ? 'Modifica Spesa' : 'Inserisci Spesa';
    }
    else if (widget.transactionType == TransactionTypeEnum.INCOME) {
      pageTitle = isEdit ? 'Modifica Entrata' : 'Inserisci Entrata';
    }
  }

  Future<void> _saveExpenseTransaction() async {
    if (mounted) {
      setState(() {
        _errorMessage = null;
        _isSaveEnabled = false;
      });
    }

    try {
      if (_selectedSplitRateValueEnum == null) {
        throw Exception("Devi specificare una quota pagata o un tasso di divisione");
      }

      double formattedPrice = _formatPriceInput();
      double? paidAmount;
      if (_groupExpenseSplitResponseModel?.fixedAmount != null) {
        paidAmount = _groupExpenseSplitResponseModel?.fixedAmount;
        if (paidAmount! > formattedPrice) {
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
      // TODO:
        // await TransactionService().updateGroupExpenseTransaction(
        //   groupId: _selectedGroup!.id,
        //   transactionId: widget.transactionId!,
        //   price: formattedPrice,
        //   merchant: _merchantController.text.trim(),
        //   categories: _categoriesController.text.trim(),
        //   note: _noteController.text.trim(),
        // );
      } 
      else { // Logica di creazione nuovo gruppo
        await TransactionService().createGroupExpenseTransaction(
          groupId: _selectedGroup!.id,
          price: formattedPrice,
          splitRateEnum: _selectedSplitRateValueEnum,
          paidAmount: paidAmount,
          merchant: _merchantController.text.trim(),
          categories: _categoriesController.text.trim(),
          note: _noteController.text.trim(),
        );
      }
    
      if (mounted) {
        GenericUtil.showSnackbar(context, isEdit ? "Dati aggiornati" : "Dati salvati");
        resetProviders();
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

  Future<void> _saveIncomeTransaction() async {
    if (mounted) {
      setState(() {
        _errorMessage = null;
        _isSaveEnabled = false;
      });
    }

    try {
      double formattedPrice = _formatPriceInput();

      if (isEdit) { // Logica di salvataggio modifica gruppo
        await TransactionService().updateGroupIncomeTransaction(
          groupId: _selectedGroup!.id,
          transactionId: widget.transactionId!,
          price: formattedPrice,
          note: _noteController.text.trim(),
        );
      } 
      else { // Logica di creazione nuovo gruppo
        await TransactionService().createGroupIncomeTransaction(
          groupId: _selectedGroup!.id,
          price: formattedPrice,
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

  void resetProviders() {
    ref.read(splitRateAndPaidAmountTabProvider.notifier).state = 0;
    ref.read(splitRateModeProvider.notifier).state = null;
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
        error: (err, _) => Center(child: Text("Errore durante il caricamento. Riprovare")), // TODO: migliorare gestione errori
        data: (groups) {

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.rowHorizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [ // -- Campi di input
                // -- Gruppo
                _buildDropDownGroup(groups),

                // -- Transaction Price
                const SizedBox(height: AppConstants.sizedBoxHeight),
                Row(
                  children: [
                    Expanded(
                      child: CustomValidatedTextField(
                        controller: _priceController,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^[0-9]*[.,]?[0-9]*$')),
                        ],
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        labelText: 'Prezzo',
                        onChanged: (value) => _formatPriceInput(),
                        prefixIcon: Icon(Icons.euro, size: 24),
                      ),
                    ),
                    
                    // -- Split Rate vs Paid Amount
                    if (widget.transactionType == TransactionTypeEnum.EXPENSE) ...[
                      const SizedBox(width: 8),
                      CustomButtonWidget(
                        onPressed: _openSplitRateVsPaidAmountBottomSheet,
                        text: _selectedSplitRateValueEnum?.value ?? 'Configura quota',
                        isIconPrefix: false,
                        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                        customIcon: CustomIconWidget(assetPath: 'assets/images/icons/right.PNG', size: 24, color: Theme.of(context).colorScheme.onSecondaryContainer),
                      ),
                    ],
                  ],
                ),

                if (widget.transactionType == TransactionTypeEnum.EXPENSE) ...[
                  _buildTextFiels()
                ],

                // -- Note
                const SizedBox(height: AppConstants.sizedBoxHeight),
                CustomValidatedTextField(
                  controller: _noteController,
                  labelText: 'Note',
                  prefixIcon: Icon(Icons.note, size: 24),
                ),

                // Alert errore
                if (_errorMessage != null) ...[
                  ErrorAlertWidget(errorMessage: _errorMessage!, onClose: () {
                    setState(() {
                      _errorMessage = null;
                    });
                  }),
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

  Widget _buildDropDownGroup(List<GroupDetailsModel> groups) {
    return DropdownSearch<GroupDetailsModel>(
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
    );
  }

  Widget _buildSaveCancelButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomButtonWidget(
          onPressed: () => widget.transactionType == TransactionTypeEnum.EXPENSE 
              ? _saveExpenseTransaction() 
              : _saveIncomeTransaction(),
          text: isEdit ? 'Salva' : 'Crea',
          isEnabled: _isSaveEnabled,
        ),

        const SizedBox(width: 16),
        TextButton(
          onPressed: () => {
            resetProviders(),
            Navigator.of(context).pop(),
          },
          child: const Text('Annulla'),
        ),
      ],
    );
  }

  Widget _buildTextFiels() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // -- Negozio
        const SizedBox(height: AppConstants.sizedBoxHeight),
        CustomValidatedTextField(
          controller: _merchantController,
          labelText: 'Negozio',
          prefixIcon: SizedBox(
            width: 24,
            height: 24,
            child: Center(
              child: CustomIconWidget(assetPath: 'assets/images/icons/sell.PNG', size: 24),
            ),
          ),
        ),

        // -- Categorie
        const SizedBox(height: AppConstants.sizedBoxHeight),
        CustomValidatedTextField(
          controller: _categoriesController,
          labelText: 'Categorie',
          prefixIcon: Icon(Icons.shopping_cart, size: 24),
          onTap: _openCategoriesBottomSheet,
        ),

        // -- Payment method (TODO: da implementare)
        const SizedBox(height: AppConstants.sizedBoxHeight),
        CustomValidatedTextField(
          controller: _paymentMethodController,
          labelText: 'Metodo di pagamento',
          prefixIcon: Icon(Icons.payment, size: 24),
          // TODO: implementare onTap: _openPaymentMethodsBottomSheet
        ),
      ],
    );
  }

}