import 'package:Billy/constants.dart';
import 'package:Billy/extentions/datetime_extention.dart';
import 'package:Billy/providers/local-database/api_token_provider.dart';
import 'package:Billy/services/api_token_service.dart';
import 'package:Billy/utils/generic_util.dart';
import 'package:Billy/widgets/components/custom_button_widget.dart';
import 'package:Billy/widgets/components/custom_validated_textfield_widget.dart';
import 'package:Billy/widgets/components/data_picker_bottom_sheet.dart';
import 'package:Billy/widgets/components/loading_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

class ApiTokenDetailsPage extends ConsumerStatefulWidget {
  final String? tokenId;

  const ApiTokenDetailsPage({super.key, this.tokenId});

  @override
  ConsumerState<ApiTokenDetailsPage> createState() => _ApiTokenDetailsPageState();
}

class _ApiTokenDetailsPageState extends ConsumerState<ApiTokenDetailsPage> {
  final Logger log = Logger('ApiTokenDetailsPage');
  final ApiTokenService _apiTokenService = ApiTokenService();
  
  late TextEditingController _nameController;
  late TextEditingController _validUntilController;
  late TextEditingController _lastUsedController;
  late TextEditingController _revokedAtController;

  DateTime? _selectedValidUntilDate;
  DateTime? _selectedLastUsedDate;
  DateTime? _selectedRevokedAtDate;

  bool _isLoading = false;
  bool _isSaveEnabled = false;
  String? _errorMessage;
  String pageTitle = '';

  late final bool isEdit;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _validUntilController = TextEditingController();
    _lastUsedController = TextEditingController();
    _revokedAtController = TextEditingController();

    _nameController.addListener(_onFieldChanged);
    _validUntilController.addListener(_onFieldChanged);
    _lastUsedController.addListener(_onFieldChanged);
    _revokedAtController.addListener(_onFieldChanged);

    _selectedValidUntilDate = null;
    _selectedLastUsedDate = null;
    _selectedRevokedAtDate = null;
    isEdit = widget.tokenId != null;
    _pageTitleSetup();

    if (widget.tokenId != null) {
      _loadExistingToken(widget.tokenId!);
    }
  }
  
  @override
  void dispose() {
    _nameController.removeListener(_onFieldChanged);
    _nameController.dispose();
    _validUntilController.removeListener(_onFieldChanged);
    _validUntilController.dispose();
    _lastUsedController.removeListener(_onFieldChanged);
    _lastUsedController.dispose();
    _revokedAtController.removeListener(_onFieldChanged);
    _revokedAtController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingToken(String tokenId) async {
    setState(() {
      _isLoading = true;
    });

    // TODO: da implementare caricamento token esistente
  
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onFieldChanged() {
    setState(() {
      _isSaveEnabled = _nameController.text.isNotEmpty 
        && _validUntilController.text.isNotEmpty;
        // TODO: validUntil > now && revokedAt == null
    });
  }

  void _pageTitleSetup() {
    pageTitle = isEdit ? 'Modifica Token' : 'Crea Token';
  }

  Future<void> _saveToken() async {
    if (mounted) {
      setState(() {
        _errorMessage = null;
        _isSaveEnabled = false;
      });
    }

    if (_nameController.text.isEmpty || _validUntilController.text.isEmpty || _selectedValidUntilDate == null) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Nome e Scadenza sono obbligatori';
          _isSaveEnabled = true;
        });
      }
      return;
    }

    try {
      String? token = null;
      if (isEdit) { // Logica di salvataggio
          // TODO: implement save existing token
    //     await TransactionService().updatePersonalTransaction(
    //       transactionId: widget.transactionId!,
    //       price: _formatPriceInput(),
    //       transactionType: widget.transactionType,
    //       merchant: (widget.transactionType == TransactionTypeEnum.EXPENSE) ? _merchantController.text.trim() : null,
    //       categories: (widget.transactionType == TransactionTypeEnum.EXPENSE) ? _categoriesController.text.trim() : 'INCOME',
    //       note: _noteController.text.trim(),
    //     );
      } 
      else { // Logica di creazione
        // TODO: modificare utilizzando provider e cache
        token = _apiTokenService.generateApiToken();
        final String hashedToken = _apiTokenService.sha256Hash(token);

        await _apiTokenService.saveHashedTokenToSecureStorage(
          hashedToken: hashedToken, 
          validUntil: _selectedValidUntilDate!,
          tokenName: 'Token generato il ${DateTime.now()}'
        );

        // TODO: ref.read(apiTokenProvider.notifier).addTokenLocally(token); // Aggiorna la lista dei token
      }
    
      if (mounted) {
        GenericUtil.showSnackbar(context, isEdit ? "Dati aggiornati" : "Dati salvati");
        Navigator.of(context).pop(token); // Torna indietro e segnala che c'è stato un cambiamento
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

  Future<void> _selectValidUntilDate(BuildContext context) async {
    DateTime? selectedDate = await _showBottomSheetDatePicker(context);
    if (selectedDate != null) {
      setState(() {
        _validUntilController.text = selectedDate.toDateStr();
        _selectedValidUntilDate = selectedDate;
      });
    }
  }

  Future<DateTime?> _showBottomSheetDatePicker(BuildContext context) async
  {
    return showModalBottomSheet<DateTime>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      builder: (context) => DataPickerBottomSheet()
    );
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
              children: [ 
                // -- Campi di input
                // -- Name
                CustomValidatedTextField(
                  controller: _nameController,
                  inputFormatters: [],
                  keyboardType: TextInputType.text,
                  labelText: 'Nome',
                  onChanged: (value) {},
                  prefixIcon: Icon(Icons.text_fields, size: 24),
                  validator: (value) => value.trim().isEmpty ? 'Il nome è obbligatorio' : null,
                ),

                // -- Valid Until
                const SizedBox(height: AppConstants.mediumSizedBoxHeight),
                CustomValidatedTextField(
                  controller: _validUntilController,
                  inputFormatters: [],
                  keyboardType: TextInputType.datetime,
                  labelText: 'Scadenza',
                  onTap: () => _selectValidUntilDate(context),
                  onChanged: (value) {},
                  prefixIcon: Icon(Icons.calendar_today, size: 24),
                ),

                if (isEdit) ...[ // TODO: da implementare campi read-only per lastUsed e revokedAt
                  // -- Last Used
                  const SizedBox(height: AppConstants.mediumSizedBoxHeight),
                  CustomValidatedTextField(
                    controller: _lastUsedController,
                    inputFormatters: [],
                    keyboardType: TextInputType.datetime,
                    labelText: 'Ultimo utilizzo',
                    onChanged: (value) {},
                    prefixIcon: Icon(Icons.access_time, size: 24),
                    readOnly: true,
                  ),

                  // -- Revoked At
                  const SizedBox(height: AppConstants.mediumSizedBoxHeight),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: CustomValidatedTextField(
                          controller: _revokedAtController,
                          inputFormatters: [],
                          keyboardType: TextInputType.datetime,
                          labelText: 'Revocato il',
                          onChanged: (value) {},
                          prefixIcon: Icon(Icons.cancel, size: 24),
                          readOnly: true,
                        ),
                      ),

                      const SizedBox(width: AppConstants.mediumSizedBoxWidth),
                      CustomButtonWidget(
                        backgroundColor: Colors.redAccent,
                        iconData: Icons.lock_open,
                        onPressed: () => null, // TODO: implement revoke token
                      ),
                    ],
                  )
                ],

                // Save/Cancel buttons
                const SizedBox(height: AppConstants.mediumSizedBoxHeight),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomButtonWidget(
                      onPressed: () { // Salva o crea gruppo
                        _saveToken();
                      },
                      text: isEdit ? 'Salva' : 'Crea',
                      isEnabled: _isSaveEnabled,
                    ),

                    const SizedBox(width: AppConstants.largeSizedBoxWidth),
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