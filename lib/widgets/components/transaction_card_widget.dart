import 'package:Billy/constants.dart';
import 'package:Billy/enums/category_enum.dart';
import 'package:Billy/enums/transaction_type_enum.dart';
import 'package:Billy/models/group/group_expense_partecipants_model.dart';
import 'package:flutter/material.dart';
import 'package:Billy/models/profile_model.dart';
import 'package:Billy/widgets/components/custom_icon_widget.dart';
import 'package:Billy/extentions/category_enum_extention.dart';

class TransactionCardWidget extends StatefulWidget {
  final String formattedDateTime;
  final double totalAmount;
  final TransactionTypeEnum transactionType;
  final String? categoryName;
  final String? groupId;
  final String? merchantName;
  final String? note;
  final String? splitRate;
  final double? paidAmount;
  final ProfileModel? profileModel;
  final List<GroupExpenseParticipantModel>? expenseParticipants;
  final VoidCallback? expensePartecipantsOnPressed;

  const TransactionCardWidget({
    super.key,
    required this.formattedDateTime,
    required this.totalAmount,
    required this.transactionType,
    this.categoryName,
    this.groupId,
    this.merchantName,
    this.note,
    this.splitRate,
    this.paidAmount,
    this.profileModel,
    this.expenseParticipants, 
    this.expensePartecipantsOnPressed,
  });

  @override
  State<TransactionCardWidget> createState() => _TransactionCardWidgetState();
}

class _TransactionCardWidgetState extends State<TransactionCardWidget> {

  late CategoryEnum categoryEnum;

  @override
  void initState() {
    super.initState();
    if (widget.categoryName != null) {
      setState(() {
        categoryEnum = CategoryEnumParsing(widget.categoryName!).toCategoryEnum();        
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        child: ExpansionTile(
          title: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4, // Spaziatura tra gli elementi
            runSpacing: 2, // Spaziatura tra le righe
            children: [
              // --- Category entry
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- Transaction entry
                  if (widget.categoryName != null) ...[
                    categoryEnum.toIcon(),
                  ] 
                  else ...[
                    CustomIconWidget(assetPath: 'assets/images/icons/sell_filled.PNG', color: Colors.orange),
                  ],
                  
                  const SizedBox(width: AppConstants.sizedBoxWidth),
                  if (widget.categoryName != null) ...[
                    Text(widget.categoryName!, style: const TextStyle(fontWeight: FontWeight.w500)),
                  ]
                  else ...[
                    const Text('-'),
                  ]
                ],
              ),

              // -- Merchant entry
              if (categoryEnum != CategoryEnum.INCOME) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.shopping_cart, size: 20, color: Colors.blueGrey),
                    const SizedBox(width: AppConstants.sizedBoxWidth),
                    if (widget.merchantName != null) ...[
                      Text(widget.merchantName!, style: const TextStyle(fontWeight: FontWeight.w500)),
                    ]
                    else ...[
                      const Text('-'),
                    ]
                  ],
                ),
              ],

              // -- Profile entry
              if (widget.profileModel != null) ...[
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.person, size: 20, color: Colors.green),
                    const SizedBox(width: AppConstants.sizedBoxWidth),
                    Text(widget.profileModel!.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ],
          ),
          subtitle: Text(widget.formattedDateTime, style: const TextStyle(fontSize: AppConstants.smallTextSize)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.note != null && widget.note!.isNotEmpty) ...[
                Icon(Icons.note, color: Colors.yellow[700], size: 20),
              ],
              if (widget.expenseParticipants != null && widget.expenseParticipants!.isNotEmpty) ...[
                IconButton(
                  icon: Badge(
                    label: Text('${widget.expenseParticipants!.length + 1}'), // +1 per includere il profilo del pagatore
                    backgroundColor: Colors.blueAccent,
                    child: Icon(Icons.group, color: Colors.blue[700], size: 24),
                  ),
                  onPressed: widget.expensePartecipantsOnPressed,
                ),
              ],
              const SizedBox(width: AppConstants.sizedBoxWidth),
              Text(
                _formatAmount(widget.totalAmount, widget.transactionType), 
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: AppConstants.textSize,
                  color: widget.transactionType == TransactionTypeEnum.INCOME ? Colors.green : Colors.red,
                )
              ),
            ],
          ),
          children: [
            SizedBox(
              width: double.infinity,
              child: Card(
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: // Transaction details
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        
                        // --- Group Entry
                        if (widget.groupId != null) ...[
                          if (widget.paidAmount != null) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: 
                                  SelectableText('Importo pagato: €${widget.paidAmount!.toStringAsFixed(2)}',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    )
                                  ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: 
                                  SelectableText('Importo mancante: €${(widget.totalAmount - (widget.paidAmount ?? 0)).toStringAsFixed(2)}', 
                                    textAlign: TextAlign.left, 
                                    style: TextStyle(
                                      color: (widget.totalAmount - (widget.paidAmount ?? 0)) > 0 ? Colors.red : Colors.green,
                                      fontWeight: FontWeight.bold,
                                    )
                                  ),
                              ),
                            ),
                          ],
                          if (widget.splitRate != null) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text('Percentuale di suddivisione: ${widget.splitRate}', textAlign: TextAlign.left),
                              ),
                            ),
                          ],
                        ],

                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: SelectableText((widget.note != null && widget.note!.isNotEmpty) ? 'Nota: ${widget.note}' : 'Nessuna nota', textAlign: TextAlign.left),
                          ),
                        ),

                      ],
                    ),
                  ),
              ),
            ),
          ],
        ),
    );
  }

  String _formatAmount(double amount, TransactionTypeEnum type) {
    String value = (type == TransactionTypeEnum.EXPENSE ? '-' : '') + amount.toStringAsFixed(2);
    return '€$value';
  }
}