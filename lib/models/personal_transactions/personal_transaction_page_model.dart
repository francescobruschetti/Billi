import 'package:Billy/models/personal_transactions/personal_transaction_model.dart';
import 'package:Billy/models/personal_transactions/personal_transaction_totals_model.dart';

class PersonalTransactionPageModel {
  final List<PersonalTransactionModel> transactions;
  final PersonalTransactionTotalsModel totals;

  PersonalTransactionPageModel.fromJson(Map<String, dynamic> data)
      : transactions = PersonalTransactionModel.fromList(data['transactions']),
        totals = PersonalTransactionTotalsModel.fromJson(data['totals']);
}