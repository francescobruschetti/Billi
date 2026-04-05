import 'package:Billy/constants.dart';
import 'package:Billy/enums/transaction_type_enum.dart';
import 'package:Billy/pages/transaction/components/categories_bottom_sheet_widget.dart';
import 'package:Billy/utils/generic_util.dart';
import 'package:Billy/widgets/components/custom_icon_widget.dart';
import 'package:Billy/widgets/components/custom_validated_textfield_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Billy/services/transaction_service.dart';
import 'package:Billy/widgets/components/error_alert_widget.dart';
import 'package:Billy/widgets/components/loading_scaffold.dart';

class TransactionPage extends StatefulWidget {
  final String? transactionId;
  final TransactionTypeEnum transactionType;
  final bool isEditAllowed;

  const TransactionPage({super.key, this.transactionId, required this.transactionType, this.isEditAllowed = false});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  late TextEditingController _priceController;
  late TextEditingController _merchantController;
  late TextEditingController _categoriesController;
  late TextEditingController _noteController;
  bool _isLoading = false;
  bool _isSaveEnabled = false;
  String? _errorMessage;
  String pageTitle = '';

  late final bool isEdit;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(text: '');
    _merchantController = TextEditingController(text: '');
    _categoriesController = TextEditingController(text: '');
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
    _noteController.dispose();
    super.dispose();
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

  void _onFieldChanged() {
    setState(() {
      _isSaveEnabled = _priceController.text.isNotEmpty;
    });
  }

  void _openCategoriesBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // obbligatorio per DraggableScrollableSheet
      backgroundColor: Colors.transparent, // lascia gestire il colore al sheet
      builder: (BuildContext context) => CategoriesBottomSheetWidget(
        title: 'Seleziona Categoria',
      ),
    );
  }

  void _pageTitleSetup() {
    if (widget.transactionType == TransactionTypeEnum.EXPENSE) {
      pageTitle = isEdit ? 'Modifica Spesa' : 'Inserisci Spesa';
    }
    else if (widget.transactionType == TransactionTypeEnum.INCOME) {
      pageTitle = isEdit ? 'Modifica Entrata' : 'Inserisci Entrata';
    }
  }

  Future<void> _loadExistingTransaction(String transactionId) async {
    setState(() {
      _isLoading = true;
    });

    // TODO: da implementare caricamento spesa esistente
  
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
      if (isEdit) { // Logica di salvataggio modifica gruppo
        await TransactionService().updatePersonalTransaction(
          transactionId: widget.transactionId!,
          price: _formatPriceInput(),
          transactionType: widget.transactionType,
          merchant: (widget.transactionType == TransactionTypeEnum.EXPENSE) ? _merchantController.text.trim() : null,
          categories: _categoriesController.text.trim(),
          note: _noteController.text.trim(),
        );
      } 
      else { // Logica di creazione nuovo gruppo
        await TransactionService().createPersonalTransaction(
          price: _formatPriceInput(),
          transactionType: widget.transactionType,
          merchant: (widget.transactionType == TransactionTypeEnum.EXPENSE) ? _merchantController.text.trim() : null,
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
                // -- Prezzo
                CustomValidatedTextField(
                  controller: _priceController,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^[0-9]*[.,]?[0-9]*$')),
                  ],
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  labelText: 'Prezzo',
                  onChanged: (value) => _formatPriceInput(),
                  prefixIcon: Icon(Icons.euro, size: 24),
                ),
                
                // -- Negozio
                if (widget.transactionType == TransactionTypeEnum.EXPENSE) ...[
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
                ],
                
                // -- Categorie
                const SizedBox(height: AppConstants.sizedBoxHeight),
                CustomValidatedTextField(
                  controller: _categoriesController,
                  labelText: 'Categorie',
                  prefixIcon: Icon(Icons.shopping_cart, size: 24),
                  onTap: _openCategoriesBottomSheet,
                ),
                
                // -- Note
                const SizedBox(height: AppConstants.sizedBoxHeight),
                CustomValidatedTextField(
                  controller: _noteController,
                  labelText: 'Note',
                  prefixIcon: Icon(Icons.note, size: 24),
                ),

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