import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Billy/models/api_response_model.dart';
import 'package:Billy/services/expenses_service.dart';
import 'package:Billy/widgets/components/error_alert_widget.dart';
import 'package:Billy/widgets/components/loading_scaffold.dart';

class ExpensePage extends StatefulWidget {
  final String? expenseId;
  final bool isEditAllowed;

  const ExpensePage({super.key, this.expenseId, this.isEditAllowed = false});

  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  late TextEditingController _priceController;
  late TextEditingController _merchantController;
  late TextEditingController _categoriesController;
  late TextEditingController _noteController;
  bool _isLoading = false;
  bool _isSaveEnabled = false;
  String? _errorMessage;
  String pageTitle = 'Inserisci Spesa';

  late final bool isEdit;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(text: '');
    _merchantController = TextEditingController(text: '');
    _categoriesController = TextEditingController(text: '');
    _noteController = TextEditingController(text: '');
    _priceController.addListener(_onFieldChanged);

    isEdit = widget.expenseId != null && widget.isEditAllowed;
    _pageTitleSetup();

    if (widget.expenseId != null) {
      _loadExistingExpense(widget.expenseId!);
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

  void _pageTitleSetup() {
    pageTitle = isEdit ? 'Modifica Spesa' : 'Inserisci Spesa';
  }

  Future<void> _loadExistingExpense(String expenseId) async {
    setState(() {
      _isLoading = true;
    });

    // TODO: da implementare caricamento spesa esistente
  
    setState(() {
      _isLoading = false;
    });
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
      apiResponseModel = await ExpensesService().updatePersonalExpense(
        expenseId: widget.expenseId!,
        price: _formatPriceInput(),
        merchant: _merchantController.text.trim(),
        categories: _categoriesController.text.trim(),
        note: _noteController.text.trim(),
      );
    } 
    else { // Logica di creazione nuovo gruppo
      apiResponseModel = await ExpensesService().createPersonalExpense(
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
                
                // -- Negozio
                const SizedBox(height: 8),
                TextField(
                  controller: _merchantController,
                  decoration: const InputDecoration(labelText: 'Negozio'),
                ),
                
                // -- Categorie
                const SizedBox(height: 8),
                TextField(
                  controller: _categoriesController,
                  decoration: const InputDecoration(labelText: 'Categorie'),
                ),
                
                // -- Note
                const SizedBox(height: 8),
                TextField(
                  controller: _noteController,
                  decoration: const InputDecoration(labelText: 'Note'),
                ),

                // Alert errore
                if (_errorMessage != null) ...[
                  ErrorAlertWidget(errorMessage: _errorMessage!),
                ],
                
                // Save/Cancel buttons
                const SizedBox(height: 8),
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