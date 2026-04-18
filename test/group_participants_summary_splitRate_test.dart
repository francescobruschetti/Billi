
import 'package:Billy/enums/transaction_type_enum.dart';
import 'package:Billy/models/category_model.dart';
import 'package:Billy/models/group_transaction_model.dart';
import 'package:Billy/models/group_participant_model.dart';
import 'package:Billy/models/merchant_model.dart';
import 'package:Billy/models/profile_model.dart';
import 'package:Billy/utils/group_transactions_util.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('computeParticipantsSummary test: 3 partecipants, 1 transactions by 1 profile', () {
    // Crea un'istanza della classe (se serve)
    final profile1 = ProfileModel(id: 'profile1', name: 'profile1', username: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now());
    final profile2 = ProfileModel(id: 'profile2', name: 'profile2', username: 'profile2', createdAt: DateTime.now(), updatedAt: DateTime.now());
    final profile3 = ProfileModel(id: 'profile3', name: 'profile3', username: 'profile3', createdAt: DateTime.now(), updatedAt: DateTime.now());

    // Prepara dati di esempio
    final transactions = [
      GroupTransactionModel(
        id: 'e1',
        groupId: 'g1',
        profileModel: profile1,
        merchant: MerchantModel(id: 'merchant1', name: 'merchant1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
        category: CategoryModel(id: 'category1', name: 'category1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
        paidAmount: 50,
        totalAmount: 100,
        splitRate: null,
        transactionType: TransactionTypeEnum.EXPENSE,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      GroupTransactionModel(
        id: 'e2',
        groupId: 'g1',
        profileModel: profile1,
        merchant: MerchantModel(id: 'merchant1', name: 'merchant1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
        category: CategoryModel(id: 'category1', name: 'category1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
        paidAmount: 20,
        totalAmount: 100,
        splitRate: null,
        transactionType: TransactionTypeEnum.EXPENSE,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    final groupParticipants = [
      GroupParticipantModel(userId: 'profile1', profile: profile1),
      GroupParticipantModel(userId: 'profile2', profile: profile2),
      GroupParticipantModel(userId: 'profile3', profile: profile3)
    ];

    final summary = GroupTransactionsUtil.computeParticipantsSummary(transactions: transactions, participants: groupParticipants);
    
    expect(summary, isNotNull);
    expect(summary.entries.length, 3);

    expect(summary[profile1.id], isNotNull);
    expect(summary[profile2.id], isNotNull);
    expect(summary[profile3.id], isNotNull);
    
    // Profile 1:
    expect(summary[profile1.id]!.paidAmountGroup, 200);
    expect(summary[profile1.id]!.paidAmountItself, 70);
    expect(summary[profile1.id]!.toReceiveNet, 130);
    expect(summary[profile1.id]!.toReceiveGross, 130);
    expect(summary[profile1.id]!.movements.length, 0);
    expect(summary[profile1.id]!.balanceMovements.length, 0);

    // Profile 2:
    expect(summary[profile2.id]!.paidAmountGroup, 0);
    expect(summary[profile2.id]!.paidAmountItself, 0);
    expect(summary[profile2.id]!.toReceiveNet, -65.0);
    expect(summary[profile2.id]!.toReceiveGross, 0);    
    expect(summary[profile2.id]!.movements.length, 1);
    expect(summary[profile3.id]!.balanceMovements.length, 1);
    expect(summary[profile3.id]!.balanceMovements.first, isNotNull);
    expect(summary[profile3.id]!.balanceMovements.last, isNotNull);
    expect(summary[profile3.id]!.balanceMovements.first.otherUserId, profile1.id);
    expect(summary[profile3.id]!.balanceMovements.first.amount, 65.0);
    
    // Profile 3:
    expect(summary[profile3.id]!.paidAmountGroup, 0);
    expect(summary[profile3.id]!.paidAmountItself, 0);
    expect(summary[profile3.id]!.toReceiveNet, -65.0);
    expect(summary[profile3.id]!.toReceiveGross, 0);
    expect(summary[profile3.id]!.movements.length, 1);
    expect(summary[profile3.id]!.balanceMovements.length, 1);
    expect(summary[profile3.id]!.balanceMovements.first, isNotNull);
    expect(summary[profile3.id]!.balanceMovements.last, isNotNull);
    expect(summary[profile3.id]!.balanceMovements.first.otherUserId, profile1.id);
    expect(summary[profile3.id]!.balanceMovements.first.amount, 65.0);
  });

}