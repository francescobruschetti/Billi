import 'package:Billy/enums/transaction_type_enum.dart';
import 'package:flutter/material.dart';
import 'package:Billy/models/profile_model.dart';
import 'package:Billy/widgets/components/custom_icon_widget.dart';

class GroupTransactionCardWidget extends StatelessWidget {
  final String? merchantName;
  final String? categoryName;
  final String formattedDateTime;
  final double totalAmount;
  final TransactionTypeEnum transactionType;
  final ProfileModel? profileModel;
  final String? note;
  final String? splitRate;
  final double? paidAmount;

  const GroupTransactionCardWidget({
    super.key,
    this.merchantName,
    this.categoryName,
    required this.formattedDateTime,
    required this.totalAmount,
    required this.transactionType,
    this.note,
    this.profileModel,
    this.paidAmount,
    this.splitRate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
        child: ExpansionTile(
          title: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 4, // Spaziatura tra gli elementi
            runSpacing: 2, // Spaziatura tra le righe
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- Transaction entry
                  CustomIconWidget(assetPath: 'assets/images/icons/sell-filled.PNG', color: Colors.orange),
                  const SizedBox(width: 4),
                  if (categoryName != null) Text(categoryName!, style: const TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.shopping_cart, size: 20, color: Colors.blueGrey),
                  const SizedBox(width: 4),
                  if (merchantName != null) Text(merchantName!, style: const TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
              if (profileModel != null) 
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.person, size: 20, color: Colors.green),
                    const SizedBox(width: 4),
                    Text(profileModel!.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ),           
            ],
          ),
          subtitle: Text(formattedDateTime, style: const TextStyle(fontSize: 12)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: 4),
              Text(
                _formatAmount(totalAmount, transactionType), 
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: transactionType == TransactionTypeEnum.INCOME ? Colors.green : Colors.red,
                )
              ),
              Icon(Icons.expand_more, color: Colors.grey.shade600),
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
                        if (paidAmount != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: 
                                SelectableText('Importo pagato: €${paidAmount!.toStringAsFixed(2)}',
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
                                SelectableText('Importo mancante: €${(totalAmount - (paidAmount ?? 0)).toStringAsFixed(2)}', 
                                  textAlign: TextAlign.left, 
                                  style: TextStyle(
                                    color: (totalAmount - (paidAmount ?? 0)) > 0 ? Colors.red : Colors.green,
                                    fontWeight: FontWeight.bold,
                                  )
                                ),
                            ),
                          ),
                        if (splitRate != null)
                          Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text('Percentuale di suddivisione: $splitRate', textAlign: TextAlign.left),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: SelectableText((note != null && note!.isNotEmpty) ? 'Nota: $note' : 'Nessuna nota', textAlign: TextAlign.left),
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