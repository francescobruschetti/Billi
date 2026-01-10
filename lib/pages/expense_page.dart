import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:monitoraggio_spese/models/api_response_model.dart';
import 'package:monitoraggio_spese/services/expenses_service.dart';

class ExpensePage extends StatefulWidget {
  final String? expenseId;
  final bool isPersonalExpense;
  final bool isEditAllowed;

  const ExpensePage({super.key, this.expenseId, required this.isPersonalExpense, this.isEditAllowed = false});

  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  late TextEditingController _priceController;
  late TextEditingController _merchantController;
  late TextEditingController _noteController;
  bool _isLoading = false;
  bool _isSaveEnabled = false;
  String? _errorMessage;

  late final bool isEdit;

  @override
  void initState() {
    super.initState();
    _priceController = TextEditingController(text: '');
    _merchantController = TextEditingController(text: '');
    _noteController = TextEditingController(text: '');
    _priceController.addListener(_onFieldChanged);

    if (widget.expenseId != null) {
      _loadExistingExpense(widget.expenseId!);
    }

    isEdit = widget.expenseId != null && widget.isEditAllowed;
  }
  
  @override
  void dispose() {
    _priceController.removeListener(_onFieldChanged);
    _merchantController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    setState(() {
      _isSaveEnabled = _priceController.text.isNotEmpty; // es. && _merchantController.text.isNotEmpty;
    });
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

  Future<void> _saveExpense() async {
    setState(() {
      _errorMessage = null;
      _isSaveEnabled = false;
    });

    String message = '';
    ApiResponseModel<Map<String, dynamic>> apiResponseModel = ApiResponseModel<Map<String, dynamic>>(
      success: false, message: "Errore durante il salvataggio dei dati", data: {}
    );
    if (isEdit) { // Logica di salvataggio modifica gruppo
      message = "Dati aggiornatic correttamente";
      apiResponseModel = await ExpensesService().update(
        id: widget.expenseId!,
        price: _formatPriceInput(),
        merchant: _merchantController.text.trim(),
        note: _noteController.text.trim(),
      );
    } 
    else { // Logica di creazione nuovo gruppo
      message = "Spesa salvata con successo";
      apiResponseModel = await ExpensesService().create(
        price: _formatPriceInput(),
        merchant: _merchantController.text.trim(),
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
        _errorMessage = 'Errore durante il salvataggio dei dati';
        _isSaveEnabled = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(isEdit ? 'Modifica Spesa' : 'Inserisci Spesa'),
      ),
      body: _isLoading
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Caricamento dati...', style: TextStyle(fontSize: 16)),
              ],
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
          // Campi di input
          TextField(
            controller: _priceController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^[0-9]*[.,]?[0-9]*$')),
            ],
            decoration: const InputDecoration(labelText: 'Prezzo'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _merchantController,
            decoration: const InputDecoration(labelText: 'Negozio'),
          ),
          const SizedBox(height: 8),
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