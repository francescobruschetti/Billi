// TODO: implementare expensePartecipants
// import 'package:Billy/enums/transaction_type_enum.dart';
// import 'package:Billy/models/category/category_model.dart';
// import 'package:Billy/models/group/group_expense_partecipants_model.dart';
// import 'package:Billy/models/group/group_transaction_model.dart';
// import 'package:Billy/models/group/group_participant_model.dart';
// import 'package:Billy/models/merchant_model.dart';
// import 'package:Billy/models/profile_model.dart';
// import 'package:Billy/utils/group_transactions_util.dart';
// import 'package:flutter_test/flutter_test.dart';

// void main() {
//   test('computeParticipantsSummary test: 3 partecipants, 2 transactions by 1 profile', () {
//     // Crea un'istanza della classe (se serve)
//     final profile1 = ProfileModel(id: 'profile1', name: 'profile1', username: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now());
//     final profile2 = ProfileModel(id: 'profile2', name: 'profile2', username: 'profile2', createdAt: DateTime.now(), updatedAt: DateTime.now());
//     final profile3 = ProfileModel(id: 'profile3', name: 'profile3', username: 'profile3', createdAt: DateTime.now(), updatedAt: DateTime.now());

//     // Prepara dati di test
//     final transactions = [
//       GroupTransactionModel(
//         id: 'e1',
//         groupId: 'g1',
//         profileModel: profile1,
//         merchant: MerchantModel(id: 'merchant1', name: 'merchant1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         category: CategoryModel(id: 'category1', name: 'category1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         paidAmount: 50,
//         totalAmount: 100,
//         splitRate: null,
//         transactionType: TransactionTypeEnum.EXPENSE,
//         createdAt: DateTime.now(),
//         updatedAt: DateTime.now(),
//       ),
//       GroupTransactionModel(
//         id: 'e2',
//         groupId: 'g1',
//         profileModel: profile1,
//         merchant: MerchantModel(id: 'merchant1', name: 'merchant1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         category: CategoryModel(id: 'category1', name: 'category1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         paidAmount: 20,
//         totalAmount: 100,
//         splitRate: null,
//         transactionType: TransactionTypeEnum.EXPENSE,
//         createdAt: DateTime.now(),
//         updatedAt: DateTime.now(),
//       ),
//     ];

//     final groupParticipants = [
//       GroupParticipantModel(userId: 'profile1', profile: profile1),
//       GroupParticipantModel(userId: 'profile2', profile: profile2),
//       GroupParticipantModel(userId: 'profile3', profile: profile3)
//     ];

//     final summary = GroupTransactionsUtil.computeParticipantsSummary(transactions: transactions, participants: groupParticipants);
    
//     expect(summary, isNotNull);
//     expect(summary.entries.length, 3);

//     expect(summary[profile1.id], isNotNull);
//     expect(summary[profile2.id], isNotNull);
//     expect(summary[profile3.id], isNotNull);
    
//     // Profile 1:
//     expect(summary[profile1.id]!.paidAmountGroup, 200);
//     expect(summary[profile1.id]!.paidAmountItself, 70);
//     expect(summary[profile1.id]!.toReceiveNet, 130);
//     expect(summary[profile1.id]!.toReceiveGross, 130);
//     expect(summary[profile1.id]!.movements.length, 0);
//     expect(summary[profile1.id]!.balanceMovements.length, 0);

//     // Profile 2:
//     expect(summary[profile2.id]!.paidAmountGroup, 0);
//     expect(summary[profile2.id]!.paidAmountItself, 0);
//     expect(summary[profile2.id]!.toReceiveNet, -65.0);
//     expect(summary[profile2.id]!.toReceiveGross, 0);    
//     expect(summary[profile2.id]!.movements.length, 1);
//     expect(summary[profile3.id]!.balanceMovements.length, 1);
//     expect(summary[profile3.id]!.balanceMovements.first, isNotNull);
//     expect(summary[profile3.id]!.balanceMovements.last, isNotNull);
//     expect(summary[profile3.id]!.balanceMovements.first.otherUserId, profile1.id);
//     expect(summary[profile3.id]!.balanceMovements.first.amount, 65.0);
    
//     // Profile 3:
//     expect(summary[profile3.id]!.paidAmountGroup, 0);
//     expect(summary[profile3.id]!.paidAmountItself, 0);
//     expect(summary[profile3.id]!.toReceiveNet, -65.0);
//     expect(summary[profile3.id]!.toReceiveGross, 0);
//     expect(summary[profile3.id]!.movements.length, 1);
//     expect(summary[profile3.id]!.balanceMovements.length, 1);
//     expect(summary[profile3.id]!.balanceMovements.first, isNotNull);
//     expect(summary[profile3.id]!.balanceMovements.last, isNotNull);
//     expect(summary[profile3.id]!.balanceMovements.first.otherUserId, profile1.id);
//     expect(summary[profile3.id]!.balanceMovements.first.amount, 65.0);
//   });

//   test('computeParticipantsSummary test: 3 partecipants, 3 transactions by 2 profiles', () {
//     // Crea un'istanza della classe (se serve)
//     final profile1 = ProfileModel(id: 'profile1', name: 'profile1', username: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now());
//     final profile2 = ProfileModel(id: 'profile2', name: 'profile2', username: 'profile2', createdAt: DateTime.now(), updatedAt: DateTime.now());
//     final profile3 = ProfileModel(id: 'profile3', name: 'profile3', username: 'profile3', createdAt: DateTime.now(), updatedAt: DateTime.now());

//     // Prepara dati di test
//     final transactions = [
//       GroupTransactionModel(
//         id: 'e1',
//         groupId: 'g1',
//         profileModel: profile1,
//         merchant: MerchantModel(id: 'merchant1', name: 'merchant1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         category: CategoryModel(id: 'category1', name: 'category1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         paidAmount: 40,
//         totalAmount: 70,
//         splitRate: null,
//         transactionType: TransactionTypeEnum.EXPENSE,
//         createdAt: DateTime.now(),
//         updatedAt: DateTime.now(),
//       ),
//       GroupTransactionModel(
//         id: 'e2',
//         groupId: 'g1',
//         profileModel: profile1,
//         merchant: MerchantModel(id: 'merchant1', name: 'merchant1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         category: CategoryModel(id: 'category1', name: 'category1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         paidAmount: 40,
//         totalAmount: 100,
//         splitRate: null,
//         transactionType: TransactionTypeEnum.EXPENSE,
//         createdAt: DateTime.now(),
//         updatedAt: DateTime.now(),
//       ),
//       GroupTransactionModel(
//         id: 'e3',
//         groupId: 'g1',
//         profileModel: profile2,
//         merchant: MerchantModel(id: 'merchant1', name: 'merchant1', userId: 'profile2', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         category: CategoryModel(id: 'category1', name: 'category1', userId: 'profile2', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         paidAmount: 20,
//         totalAmount: 100,
//         splitRate: null,
//         transactionType: TransactionTypeEnum.EXPENSE,
//         createdAt: DateTime.now(),
//         updatedAt: DateTime.now(),
//       ),
//     ];

//     final groupParticipants = [
//       GroupParticipantModel(userId: 'profile1', profile: profile1),
//       GroupParticipantModel(userId: 'profile2', profile: profile2),
//       GroupParticipantModel(userId: 'profile3', profile: profile3)
//     ];

//     final summary = GroupTransactionsUtil.computeParticipantsSummary(transactions: transactions, participants: groupParticipants);
    
//     expect(summary, isNotNull);
//     expect(summary.entries.length, 3);

//     expect(summary[profile1.id], isNotNull);
//     expect(summary[profile2.id], isNotNull);
//     expect(summary[profile3.id], isNotNull);
    
//     // Profile 1:
//     expect(summary[profile1.id]!.paidAmountGroup, 170);
//     expect(summary[profile1.id]!.paidAmountItself, 80);
//     expect(summary[profile1.id]!.toReceiveNet, 50);
//     expect(summary[profile1.id]!.toReceiveGross, 90);
//     expect(summary[profile1.id]!.movements.length, 1);
//     expect(summary[profile1.id]!.balanceMovements.length, 0);

//     // Profile 2:
//     expect(summary[profile2.id]!.paidAmountGroup, 100);
//     expect(summary[profile2.id]!.paidAmountItself, 20);
//     expect(summary[profile2.id]!.toReceiveNet, 35);
//     expect(summary[profile2.id]!.toReceiveGross, 80);    
//     expect(summary[profile2.id]!.movements.length, 1);
//     expect(summary[profile2.id]!.balanceMovements.length, 0);
    
//     // Profile 3:
//     expect(summary[profile3.id]!.paidAmountGroup, 0);
//     expect(summary[profile3.id]!.paidAmountItself, 0);
//     expect(summary[profile3.id]!.toReceiveNet, -85);
//     expect(summary[profile3.id]!.toReceiveGross, 0);
//     expect(summary[profile3.id]!.movements.length, 2);
//     expect(summary[profile3.id]!.balanceMovements.length, 2);
//     expect(summary[profile3.id]!.balanceMovements.first, isNotNull);
//     expect(summary[profile3.id]!.balanceMovements.last, isNotNull);
//     expect(summary[profile3.id]!.balanceMovements.first.otherUserId, profile1.id);
//     expect(summary[profile3.id]!.balanceMovements.first.amount, 50);
//     expect(summary[profile3.id]!.balanceMovements.last.otherUserId, profile2.id);
//     expect(summary[profile3.id]!.balanceMovements.last.amount, 35);
//   });

//   test('computeParticipantsSummary test: 3 partecipants, 4 transactions by 3 profiles', () {
//     // Crea un'istanza della classe (se serve)
//     final profile1 = ProfileModel(id: 'profile1', name: 'profile1', username: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now());
//     final profile2 = ProfileModel(id: 'profile2', name: 'profile2', username: 'profile2', createdAt: DateTime.now(), updatedAt: DateTime.now());
//     final profile3 = ProfileModel(id: 'profile3', name: 'profile3', username: 'profile3', createdAt: DateTime.now(), updatedAt: DateTime.now());

//     // Prepara dati di test
//     final transactions = [
//       GroupTransactionModel(
//         id: 'e1',
//         groupId: 'g1',
//         profileModel: profile1,
//         merchant: MerchantModel(id: 'merchant1', name: 'merchant1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         category: CategoryModel(id: 'category1', name: 'category1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         paidAmount: 40,
//         totalAmount: 70,
//         splitRate: null,
//         transactionType: TransactionTypeEnum.EXPENSE,
//         createdAt: DateTime.now(),
//         updatedAt: DateTime.now(),
//       ),
//       GroupTransactionModel(
//         id: 'e2',
//         groupId: 'g1',
//         profileModel: profile1,
//         merchant: MerchantModel(id: 'merchant1', name: 'merchant1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         category: CategoryModel(id: 'category1', name: 'category1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         paidAmount: 40,
//         totalAmount: 100,
//         splitRate: null,
//         transactionType: TransactionTypeEnum.EXPENSE,
//         createdAt: DateTime.now(),
//         updatedAt: DateTime.now(),
//       ),
//       GroupTransactionModel(
//         id: 'e3',
//         groupId: 'g1',
//         profileModel: profile2,
//         merchant: MerchantModel(id: 'merchant1', name: 'merchant1', userId: 'profile2', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         category: CategoryModel(id: 'category1', name: 'category1', userId: 'profile2', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         paidAmount: 20,
//         totalAmount: 100,
//         splitRate: null,
//         transactionType: TransactionTypeEnum.EXPENSE,
//         createdAt: DateTime.now(),
//         updatedAt: DateTime.now(),
//       ),
//       GroupTransactionModel(
//         id: 'e4',
//         groupId: 'g1',
//         profileModel: profile3,
//         merchant: MerchantModel(id: 'merchant1', name: 'merchant1', userId: 'profile3', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         category: CategoryModel(id: 'category1', name: 'category1', userId: 'profile3', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         paidAmount: 50,
//         totalAmount: 50,
//         splitRate: null,
//         transactionType: TransactionTypeEnum.EXPENSE,
//         createdAt: DateTime.now(),
//         updatedAt: DateTime.now(),
//       ),
//     ];

//     final groupParticipants = [
//       GroupParticipantModel(userId: 'profile1', profile: profile1),
//       GroupParticipantModel(userId: 'profile2', profile: profile2),
//       GroupParticipantModel(userId: 'profile3', profile: profile3)
//     ];

//     final summary = GroupTransactionsUtil.computeParticipantsSummary(transactions: transactions, participants: groupParticipants);
    
//     expect(summary, isNotNull);
//     expect(summary.entries.length, 3);

//     expect(summary[profile1.id], isNotNull);
//     expect(summary[profile2.id], isNotNull);
//     expect(summary[profile3.id], isNotNull);
    
//     // Profile 1:
//     expect(summary[profile1.id]!.paidAmountGroup, 170);
//     expect(summary[profile1.id]!.paidAmountItself, 80);
//     expect(summary[profile1.id]!.toReceiveNet, 50);
//     expect(summary[profile1.id]!.toReceiveGross, 90);
//     expect(summary[profile1.id]!.movements.length, 1);
//     expect(summary[profile1.id]!.balanceMovements.length, 0);

//     // Profile 2:
//     expect(summary[profile2.id]!.paidAmountGroup, 100);
//     expect(summary[profile2.id]!.paidAmountItself, 20);
//     expect(summary[profile2.id]!.toReceiveNet, 35);
//     expect(summary[profile2.id]!.toReceiveGross, 80);    
//     expect(summary[profile2.id]!.movements.length, 1);
//     expect(summary[profile2.id]!.balanceMovements.length, 0);
    
//     // Profile 3:
//     expect(summary[profile3.id]!.paidAmountGroup, 50);
//     expect(summary[profile3.id]!.paidAmountItself, 50);
//     expect(summary[profile3.id]!.toReceiveNet, -85);
//     expect(summary[profile3.id]!.toReceiveGross, 0);
//     expect(summary[profile3.id]!.movements.length, 2);
//     expect(summary[profile3.id]!.balanceMovements.length, 2);
//     expect(summary[profile3.id]!.balanceMovements.first, isNotNull);
//     expect(summary[profile3.id]!.balanceMovements.last, isNotNull);
//     expect(summary[profile3.id]!.balanceMovements.first.otherUserId, profile1.id);
//     expect(summary[profile3.id]!.balanceMovements.first.amount, 50);
//     expect(summary[profile3.id]!.balanceMovements.last.otherUserId, profile2.id);
//     expect(summary[profile3.id]!.balanceMovements.last.amount, 35);
//   });

//   test('computeParticipantsSummary test infinite decimals numbers: 4 partecipants, 6 transactions by 4 profiles', () {
//     // Crea un'istanza della classe (se serve)
//     final profile1 = ProfileModel(id: 'profile1', name: 'profile1', username: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now());
//     final profile2 = ProfileModel(id: 'profile2', name: 'profile2', username: 'profile2', createdAt: DateTime.now(), updatedAt: DateTime.now());
//     final profile3 = ProfileModel(id: 'profile3', name: 'profile3', username: 'profile3', createdAt: DateTime.now(), updatedAt: DateTime.now());
//     final profile4 = ProfileModel(id: 'profile4', name: 'profile4', username: 'profile4', createdAt: DateTime.now(), updatedAt: DateTime.now());

//     // Prepara dati di test
//     final transactions = [
//       GroupTransactionModel(
//         id: 'e1',
//         groupId: 'g1',
//         profileModel: profile1,
//         merchant: MerchantModel(id: 'merchant1', name: 'merchant1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         category: CategoryModel(id: 'category1', name: 'category1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         paidAmount: 40,
//         totalAmount: 70,
//         splitRate: null,
//         transactionType: TransactionTypeEnum.EXPENSE,
//         createdAt: DateTime.now(),
//         updatedAt: DateTime.now(),
//       ),
//       GroupTransactionModel(
//         id: 'e2',
//         groupId: 'g1',
//         profileModel: profile1,
//         merchant: MerchantModel(id: 'merchant1', name: 'merchant1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         category: CategoryModel(id: 'category1', name: 'category1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         paidAmount: 40,
//         totalAmount: 100,
//         splitRate: null,
//         transactionType: TransactionTypeEnum.EXPENSE,
//         createdAt: DateTime.now(),
//         updatedAt: DateTime.now(),
//       ),
//       GroupTransactionModel(
//         id: 'e3',
//         groupId: 'g1',
//         profileModel: profile2,
//         merchant: MerchantModel(id: 'merchant1', name: 'merchant1', userId: 'profile2', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         category: CategoryModel(id: 'category1', name: 'category1', userId: 'profile2', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         paidAmount: 20,
//         totalAmount: 100,
//         splitRate: null,
//         transactionType: TransactionTypeEnum.EXPENSE,
//         createdAt: DateTime.now(),
//         updatedAt: DateTime.now(),
//       ),
//       GroupTransactionModel(
//           id: 'e4',
//           groupId: 'g1',
//           profileModel: profile3,
//           merchant: MerchantModel(id: 'merchant1', name: 'merchant1', userId: 'profile3', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//           category: CategoryModel(id: 'category1', name: 'category1', userId: 'profile3', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//           paidAmount: 0,
//           totalAmount: 20,
//           splitRate: null,
//           transactionType: TransactionTypeEnum.EXPENSE,
//           createdAt: DateTime.now(),
//           updatedAt: DateTime.now(),
//         ),
//       GroupTransactionModel(
//           id: 'e5',
//           groupId: 'g1',
//           profileModel: profile3,
//           merchant: MerchantModel(id: 'merchant1', name: 'merchant1', userId: 'profile3', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//           category: CategoryModel(id: 'category1', name: 'category1', userId: 'profile3', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//           paidAmount: 20,
//           totalAmount: 180,
//           splitRate: null,
//           transactionType: TransactionTypeEnum.EXPENSE,
//           createdAt: DateTime.now(),
//           updatedAt: DateTime.now(),
//         ),
//       GroupTransactionModel(
//           id: 'e6',
//           groupId: 'g1',
//           profileModel: profile4,
//           merchant: MerchantModel(id: 'merchant1', name: 'merchant1', userId: 'profile4', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//           category: CategoryModel(id: 'category1', name: 'category1', userId: 'profile4', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//           paidAmount: 50,
//           totalAmount: 200,
//           splitRate: null,
//           transactionType: TransactionTypeEnum.EXPENSE,
//           createdAt: DateTime.now(),
//           updatedAt: DateTime.now(),
//         ),
//       ];

//     final groupParticipants = [
//       GroupParticipantModel(userId: 'profile1', profile: profile1),
//       GroupParticipantModel(userId: 'profile2', profile: profile2),
//       GroupParticipantModel(userId: 'profile3', profile: profile3),
//       GroupParticipantModel(userId: 'profile4', profile: profile4)
//     ];

//     final summary = GroupTransactionsUtil.computeParticipantsSummary(transactions: transactions, participants: groupParticipants);
    
//     expect(summary, isNotNull);
//     expect(summary.entries.length, 4);

//     expect(summary[profile1.id], isNotNull);
//     expect(summary[profile2.id], isNotNull);
//     expect(summary[profile3.id], isNotNull);
//     expect(summary[profile4.id], isNotNull);
    
//     // Profile 1:
//     expect(summary[profile1.id]!.paidAmountGroup, 170);
//     expect(summary[profile1.id]!.paidAmountItself, 80);
//     expect(summary[profile1.id]!.toReceiveNet, -46.67);
//     expect(summary[profile1.id]!.toReceiveGross, 90);
//     expect(summary[profile1.id]!.movements.length, 3);
//     expect(summary[profile1.id]!.balanceMovements.length, 2);
//     expect(summary[profile1.id]!.balanceMovements.first, isNotNull);
//     expect(summary[profile1.id]!.balanceMovements.last, isNotNull);
//     expect(summary[profile1.id]!.balanceMovements.first.otherUserId, profile3.id);
//     expect(summary[profile1.id]!.balanceMovements.first.amount, 13.33);
//     expect(summary[profile1.id]!.balanceMovements.last.otherUserId, profile4.id);
//     expect(summary[profile1.id]!.balanceMovements.last.amount, 33.33);

//     // Profile 2:
//     expect(summary[profile2.id]!.paidAmountGroup, 100);
//     expect(summary[profile2.id]!.paidAmountItself, 20);
//     expect(summary[profile2.id]!.toReceiveNet, -60);
//     expect(summary[profile2.id]!.toReceiveGross, 80);    
//     expect(summary[profile2.id]!.movements.length, 3);
//     expect(summary[profile2.id]!.balanceMovements.length, 1);
//     expect(summary[profile2.id]!.balanceMovements.first, isNotNull);
//     expect(summary[profile2.id]!.balanceMovements.first.otherUserId, profile3.id);
//     expect(summary[profile2.id]!.balanceMovements.first.amount, 60);

//     // Profile 3:
//     expect(summary[profile3.id]!.paidAmountGroup, 200);
//     expect(summary[profile3.id]!.paidAmountItself, 20);
//     expect(summary[profile3.id]!.toReceiveNet, 73.33);
//     expect(summary[profile3.id]!.toReceiveGross, 180);    
//     expect(summary[profile3.id]!.movements.length, 3);
//     expect(summary[profile3.id]!.balanceMovements.length, 0);
    
//     // Profile 4:
//     expect(summary[profile4.id]!.paidAmountGroup, 200);
//     expect(summary[profile4.id]!.paidAmountItself, 50);
//     expect(summary[profile4.id]!.toReceiveNet, 33.33);
//     expect(summary[profile4.id]!.toReceiveGross, 150);
//     expect(summary[profile4.id]!.movements.length, 3);
//     expect(summary[profile4.id]!.balanceMovements.length, 0);
//   });
  
//   test('computeParticipantsSummary test infinite decimals numbers (1): 3 partecipants, 2 transactions by 2 profiles', () {
//     // Crea un'istanza della classe (se serve)
//     final profile1 = ProfileModel(id: 'profile1', name: 'profile1', username: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now());
//     final profile2 = ProfileModel(id: 'profile2', name: 'profile2', username: 'profile2', createdAt: DateTime.now(), updatedAt: DateTime.now());
//     final profile3 = ProfileModel(id: 'profile3', name: 'profile3', username: 'profile3', createdAt: DateTime.now(), updatedAt: DateTime.now());

//     // Prepara dati di test
//     final transactions = [
//       GroupTransactionModel(
//         id: 'e1',
//         groupId: 'g1',
//         profileModel: profile1,
//         merchant: MerchantModel(id: 'merchant1', name: 'merchant1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         category: CategoryModel(id: 'category1', name: 'category1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         paidAmount: 80,
//         totalAmount: 192.33,
//         splitRate: null,
//         transactionType: TransactionTypeEnum.EXPENSE,
//         createdAt: DateTime.now(),
//         updatedAt: DateTime.now(),
//       ),
//       GroupTransactionModel(
//         id: 'e2',
//         groupId: 'g1',
//         profileModel: profile2,
//         merchant: MerchantModel(id: 'merchant1', name: 'merchant1', userId: 'profile2', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         category: CategoryModel(id: 'category1', name: 'category1', userId: 'profile2', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         paidAmount: 20,
//         totalAmount: 100,
//         splitRate: null,
//         transactionType: TransactionTypeEnum.EXPENSE,
//         createdAt: DateTime.now(),
//         updatedAt: DateTime.now(),
//       )
//       ];

//     final groupParticipants = [
//       GroupParticipantModel(userId: 'profile1', profile: profile1),
//       GroupParticipantModel(userId: 'profile2', profile: profile2),
//       GroupParticipantModel(userId: 'profile3', profile: profile3),
//     ];

//     final summary = GroupTransactionsUtil.computeParticipantsSummary(transactions: transactions, participants: groupParticipants);
    
//     expect(summary, isNotNull);
//     expect(summary.entries.length, 3);

//     expect(summary[profile1.id], isNotNull);
//     expect(summary[profile2.id], isNotNull);
//     expect(summary[profile3.id], isNotNull);
    
//     // Profile 1:
//     expect(summary[profile1.id]!.paidAmountGroup, 192.33);
//     expect(summary[profile1.id]!.paidAmountItself, 80);
//     expect(summary[profile1.id]!.toReceiveNet, 72.33);
//     expect(summary[profile1.id]!.toReceiveGross, 112.33);
//     expect(summary[profile1.id]!.movements.length, 1);
//     expect(summary[profile1.id]!.movements.first, isNotNull);
//     expect(summary[profile1.id]!.movements.first.otherUserId, profile2.id);
//     expect(summary[profile1.id]!.movements.first.amount, 40.0);
//     expect(summary[profile1.id]!.balanceMovements.length, 0);

//     // Profile 2:
//     expect(summary[profile2.id]!.paidAmountGroup, 100);
//     expect(summary[profile2.id]!.paidAmountItself, 20);
//     expect(summary[profile2.id]!.toReceiveNet, 23.84);
//     expect(summary[profile2.id]!.toReceiveGross, 80);
//     expect(summary[profile2.id]!.movements.length, 1);
//     expect(summary[profile2.id]!.movements.first, isNotNull);
//     expect(summary[profile2.id]!.movements.first.otherUserId, profile1.id);
//     expect(summary[profile2.id]!.movements.first.amount, 56.16);
//     expect(summary[profile2.id]!.balanceMovements.length, 0);

//     // Profile 3:
//     expect(summary[profile3.id]!.paidAmountGroup, 0);
//     expect(summary[profile3.id]!.paidAmountItself, 0);
//     expect(summary[profile3.id]!.toReceiveNet, -96.16);
//     expect(summary[profile3.id]!.toReceiveGross, 0);
//     expect(summary[profile3.id]!.movements.length, 2);
//     expect(summary[profile3.id]!.balanceMovements.length, 2);
//     expect(summary[profile3.id]!.movements.first, isNotNull);
//     expect(summary[profile3.id]!.movements.first.otherUserId, profile1.id);
//     expect(summary[profile3.id]!.movements.first.amount, 56.16);
//     expect(summary[profile3.id]!.movements.last, isNotNull);
//     expect(summary[profile3.id]!.movements.last.otherUserId, profile2.id);
//     expect(summary[profile3.id]!.movements.last.amount, 40.0);
//     expect(summary[profile3.id]!.balanceMovements.first, isNotNull);
//     expect(summary[profile3.id]!.balanceMovements.first.otherUserId, profile1.id);
//     expect(summary[profile3.id]!.balanceMovements.first.amount, 72.33);
//     expect(summary[profile3.id]!.balanceMovements.last, isNotNull);
//     expect(summary[profile3.id]!.balanceMovements.last.otherUserId, profile2.id);
//     expect(summary[profile3.id]!.balanceMovements.last.amount, 23.84);
//   });

//   test('computeParticipantsSummary test infinite decimals numbers (2): 3 partecipants, 2 transactions by 2 profiles', () {
//     // Crea un'istanza della classe (se serve)
//     final profile1 = ProfileModel(id: 'profile1', name: 'profile1', username: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now());
//     final profile2 = ProfileModel(id: 'profile2', name: 'profile2', username: 'profile2', createdAt: DateTime.now(), updatedAt: DateTime.now());
//     final profile3 = ProfileModel(id: 'profile3', name: 'profile3', username: 'profile3', createdAt: DateTime.now(), updatedAt: DateTime.now());

//     // Prepara dati di test
//     final transactions = [
//       GroupTransactionModel(
//         id: 'e1',
//         groupId: 'g1',
//         profileModel: profile1,
//         merchant: MerchantModel(id: 'merchant1', name: 'merchant1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         category: CategoryModel(id: 'category1', name: 'category1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         paidAmount: 80,
//         totalAmount: 175.55,
//         splitRate: null,
//         transactionType: TransactionTypeEnum.EXPENSE,
//         createdAt: DateTime.now(),
//         updatedAt: DateTime.now(),
//       ),
//       GroupTransactionModel(
//         id: 'e2',
//         groupId: 'g1',
//         profileModel: profile2,
//         merchant: MerchantModel(id: 'merchant1', name: 'merchant1', userId: 'profile2', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         category: CategoryModel(id: 'category1', name: 'category1', userId: 'profile2', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         paidAmount: 20,
//         totalAmount: 100,
//         splitRate: null,
//         transactionType: TransactionTypeEnum.EXPENSE,
//         createdAt: DateTime.now(),
//         updatedAt: DateTime.now(),
//       )
//       ];

//     final groupParticipants = [
//       GroupParticipantModel(userId: 'profile1', profile: profile1),
//       GroupParticipantModel(userId: 'profile2', profile: profile2),
//       GroupParticipantModel(userId: 'profile3', profile: profile3),
//     ];

//     final summary = GroupTransactionsUtil.computeParticipantsSummary(transactions: transactions, participants: groupParticipants);
    
//     expect(summary, isNotNull);
//     expect(summary.entries.length, 3);

//     expect(summary[profile1.id], isNotNull);
//     expect(summary[profile2.id], isNotNull);
//     expect(summary[profile3.id], isNotNull);
    
//     // Profile 1:
//     expect(summary[profile1.id]!.paidAmountGroup, 175.55);
//     expect(summary[profile1.id]!.paidAmountItself, 80);
//     expect(summary[profile1.id]!.toReceiveNet, 55.55);
//     expect(summary[profile1.id]!.toReceiveGross, 95.55);
//     expect(summary[profile1.id]!.movements.length, 1);
//     expect(summary[profile1.id]!.movements.first, isNotNull);
//     expect(summary[profile1.id]!.movements.first.otherUserId, profile2.id);
//     expect(summary[profile1.id]!.movements.first.amount, 40.0);
//     expect(summary[profile1.id]!.balanceMovements.length, 0);

//     // Profile 2:
//     expect(summary[profile2.id]!.paidAmountGroup, 100);
//     expect(summary[profile2.id]!.paidAmountItself, 20);
//     expect(summary[profile2.id]!.toReceiveNet, 32.23);
//     expect(summary[profile2.id]!.toReceiveGross, 80);
//     expect(summary[profile2.id]!.movements.length, 1);
//     expect(summary[profile2.id]!.movements.first, isNotNull);
//     expect(summary[profile2.id]!.movements.first.otherUserId, profile1.id);
//     expect(summary[profile2.id]!.movements.first.amount, 47.77);
//     expect(summary[profile2.id]!.balanceMovements.length, 0);

//     // Profile 3:
//     expect(summary[profile3.id]!.paidAmountGroup, 0);
//     expect(summary[profile3.id]!.paidAmountItself, 0);
//     expect(summary[profile3.id]!.toReceiveNet, -87.77);
//     expect(summary[profile3.id]!.toReceiveGross, 0);
//     expect(summary[profile3.id]!.movements.length, 2);
//     expect(summary[profile3.id]!.movements.first, isNotNull);
//     expect(summary[profile3.id]!.movements.first.otherUserId, profile1.id);
//     expect(summary[profile3.id]!.movements.first.amount, 47.77);
//     expect(summary[profile3.id]!.movements.last, isNotNull);
//     expect(summary[profile3.id]!.movements.last.otherUserId, profile2.id);
//     expect(summary[profile3.id]!.movements.last.amount, 40.0);
//     expect(summary[profile3.id]!.balanceMovements.length, 2);
//     expect(summary[profile3.id]!.balanceMovements.first, isNotNull);
//     expect(summary[profile3.id]!.balanceMovements.first.otherUserId, profile1.id);
//     expect(summary[profile3.id]!.balanceMovements.first.amount, 55.55);
//     expect(summary[profile3.id]!.balanceMovements.last, isNotNull);
//     expect(summary[profile3.id]!.balanceMovements.last.otherUserId, profile2.id);
//     expect(summary[profile3.id]!.balanceMovements.last.amount, 32.23);
//   });
  
//   test('computeParticipantsSummary test infinite decimals numbers (3): 3 partecipants, 2 transactions by 2 profiles', () {
//     // Crea un'istanza della classe (se serve)
//     final profile1 = ProfileModel(id: 'profile1', name: 'profile1', username: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now());
//     final profile2 = ProfileModel(id: 'profile2', name: 'profile2', username: 'profile2', createdAt: DateTime.now(), updatedAt: DateTime.now());
//     final profile3 = ProfileModel(id: 'profile3', name: 'profile3', username: 'profile3', createdAt: DateTime.now(), updatedAt: DateTime.now());

//     // Prepara dati di test
//     final transactions = [
//       GroupTransactionModel(
//         id: 'e1',
//         groupId: 'g1',
//         profileModel: profile1,
//         merchant: MerchantModel(id: 'merchant1', name: 'merchant1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         category: CategoryModel(id: 'category1', name: 'category1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         expensePartecipants: [
//           GroupExpenseParticipantModel(groupId: 'g1', transactionId: 'e1', userId: 'profile2', hasPaid: true, createdAt: DateTime.now(), updatedAt: DateTime.now()),
//           GroupExpenseParticipantModel(groupId: 'g1', transactionId: 'e1', userId: 'profile3', hasPaid: true, createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         ],
//         paidAmount: 65.21,
//         totalAmount: 117.87,
//         splitRate: null,
//         transactionType: TransactionTypeEnum.EXPENSE,
//         createdAt: DateTime.now(),
//         updatedAt: DateTime.now(),
//       ),
//       GroupTransactionModel(
//         id: 'e2',
//         groupId: 'g1',
//         profileModel: profile2,
//         merchant: MerchantModel(id: 'merchant1', name: 'merchant1', userId: 'profile2', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         category: CategoryModel(id: 'category1', name: 'category1', userId: 'profile2', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         expensePartecipants: [
//           GroupExpenseParticipantModel(groupId: 'g1', transactionId: 'e2', userId: 'profile1', hasPaid: true, createdAt: DateTime.now(), updatedAt: DateTime.now()),
//           GroupExpenseParticipantModel(groupId: 'g1', transactionId: 'e2', userId: 'profile3', hasPaid: true, createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         ],
//         paidAmount: 20,
//         totalAmount: 100,
//         splitRate: null,
//         transactionType: TransactionTypeEnum.EXPENSE,
//         createdAt: DateTime.now(),
//         updatedAt: DateTime.now(),
//       )
//       ];

//     final groupParticipants = [
//       GroupParticipantModel(userId: 'profile1', profile: profile1),
//       GroupParticipantModel(userId: 'profile2', profile: profile2),
//       GroupParticipantModel(userId: 'profile3', profile: profile3),
//     ];

//     final summary = GroupTransactionsUtil.computeParticipantsSummary(transactions: transactions, participants: groupParticipants);
    
//     expect(summary, isNotNull);
//     expect(summary.entries.length, 3);

//     expect(summary[profile1.id], isNotNull);
//     expect(summary[profile2.id], isNotNull);
//     expect(summary[profile3.id], isNotNull);
    
//     // Profile 1:
//     expect(summary[profile1.id]!.paidAmountGroup, 117.87);
//     expect(summary[profile1.id]!.paidAmountItself, 65.21);
//     expect(summary[profile1.id]!.toReceiveNet, 12.66);
//     expect(summary[profile1.id]!.toReceiveGross, 52.66);
//     expect(summary[profile1.id]!.movements.length, 1);
//     expect(summary[profile1.id]!.movements.first, isNotNull);
//     expect(summary[profile1.id]!.movements.first.otherUserId, profile2.id);
//     expect(summary[profile1.id]!.movements.first.amount, 40.0);
//     expect(summary[profile1.id]!.balanceMovements.length, 0);

//     // Profile 2:
//     expect(summary[profile2.id]!.paidAmountGroup, 100);
//     expect(summary[profile2.id]!.paidAmountItself, 20);
//     expect(summary[profile2.id]!.toReceiveNet, 53.67);
//     expect(summary[profile2.id]!.toReceiveGross, 80);
//     expect(summary[profile2.id]!.movements.length, 1);
//     expect(summary[profile2.id]!.movements.first, isNotNull);
//     expect(summary[profile2.id]!.movements.first.otherUserId, profile1.id);
//     expect(summary[profile2.id]!.movements.first.amount, 26.33);
//     expect(summary[profile2.id]!.balanceMovements.length, 0);

//     // Profile 3:
//     expect(summary[profile3.id]!.paidAmountGroup, 0);
//     expect(summary[profile3.id]!.paidAmountItself, 0);
//     expect(summary[profile3.id]!.toReceiveNet, -66.33);
//     expect(summary[profile3.id]!.toReceiveGross, 0);
//     expect(summary[profile3.id]!.movements.length, 2);
//     expect(summary[profile3.id]!.movements.first, isNotNull);
//     expect(summary[profile3.id]!.movements.first.otherUserId, profile1.id);
//     expect(summary[profile3.id]!.movements.first.amount, 26.33);
//     expect(summary[profile3.id]!.movements.last, isNotNull);
//     expect(summary[profile3.id]!.movements.last.otherUserId, profile2.id);
//     expect(summary[profile3.id]!.movements.last.amount, 40.0);
//     expect(summary[profile3.id]!.balanceMovements.length, 2);
//     expect(summary[profile3.id]!.balanceMovements.first, isNotNull);
//     expect(summary[profile3.id]!.balanceMovements.first.otherUserId, profile2.id);
//     expect(summary[profile3.id]!.balanceMovements.first.amount, 53.67);
//     expect(summary[profile3.id]!.balanceMovements.last, isNotNull);
//     expect(summary[profile3.id]!.balanceMovements.last.otherUserId, profile1.id);
//     expect(summary[profile3.id]!.balanceMovements.last.amount, 12.66);
//   });

//   test('computeParticipantsSummary test infinite decimals numbers (1): 3 partecipants, 3 transactions by 3 profiles', () {
//     // Crea un'istanza della classe (se serve)
//     final profile1 = ProfileModel(id: 'profile1', name: 'profile1', username: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now());
//     final profile2 = ProfileModel(id: 'profile2', name: 'profile2', username: 'profile2', createdAt: DateTime.now(), updatedAt: DateTime.now());
//     final profile3 = ProfileModel(id: 'profile3', name: 'profile3', username: 'profile3', createdAt: DateTime.now(), updatedAt: DateTime.now());

//     // Prepara dati di test
//     final transactions = [
//       GroupTransactionModel(
//         id: 'e1',
//         groupId: 'g1',
//         profileModel: profile1,
//         merchant: MerchantModel(id: 'merchant1', name: 'merchant1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         category: CategoryModel(id: 'category1', name: 'category1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         paidAmount: 65.21,
//         totalAmount: 117.87,
//         splitRate: null,
//         transactionType: TransactionTypeEnum.EXPENSE,
//         createdAt: DateTime.now(),
//         updatedAt: DateTime.now(),
//       ),
//       GroupTransactionModel(
//         id: 'e2',
//         groupId: 'g1',
//         profileModel: profile2,
//         merchant: MerchantModel(id: 'merchant1', name: 'merchant1', userId: 'profile2', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         category: CategoryModel(id: 'category1', name: 'category1', userId: 'profile2', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         paidAmount: 20,
//         totalAmount: 100,
//         splitRate: null,
//         transactionType: TransactionTypeEnum.EXPENSE,
//         createdAt: DateTime.now(),
//         updatedAt: DateTime.now(),
//       ),
//       GroupTransactionModel(
//         id: 'e3',
//         groupId: 'g1',
//         profileModel: profile3,
//         merchant: MerchantModel(id: 'merchant1', name: 'merchant1', userId: 'profile2', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         category: CategoryModel(id: 'category1', name: 'category1', userId: 'profile2', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         paidAmount: 30.2,
//         totalAmount: 75.5,
//         splitRate: null,
//         transactionType: TransactionTypeEnum.EXPENSE,
//         createdAt: DateTime.now(),
//         updatedAt: DateTime.now(),
//       )
//       ];

//     final groupParticipants = [
//       GroupParticipantModel(userId: 'profile1', profile: profile1),
//       GroupParticipantModel(userId: 'profile2', profile: profile2),
//       GroupParticipantModel(userId: 'profile3', profile: profile3),
//     ];

//     final summary = GroupTransactionsUtil.computeParticipantsSummary(transactions: transactions, participants: groupParticipants);
    
//     expect(summary, isNotNull);
//     expect(summary.entries.length, 3);

//     expect(summary[profile1.id], isNotNull);
//     expect(summary[profile2.id], isNotNull);
//     expect(summary[profile3.id], isNotNull);
    
//     // Profile 1:
//     expect(summary[profile1.id]!.paidAmountGroup, 117.87);
//     expect(summary[profile1.id]!.paidAmountItself, 65.21);
//     expect(summary[profile1.id]!.toReceiveNet, -9.99);
//     expect(summary[profile1.id]!.toReceiveGross, 52.66);
//     expect(summary[profile1.id]!.movements.length, 2);
//     expect(summary[profile1.id]!.movements.first, isNotNull);
//     expect(summary[profile1.id]!.movements.first.otherUserId, profile2.id);
//     expect(summary[profile1.id]!.movements.first.amount, 40.0);
//     expect(summary[profile1.id]!.movements.last, isNotNull);
//     expect(summary[profile1.id]!.movements.last.otherUserId, profile3.id);
//     expect(summary[profile1.id]!.movements.last.amount, 22.65);
//     expect(summary[profile1.id]!.balanceMovements.length, 1);
//     expect(summary[profile1.id]!.balanceMovements.first, isNotNull);
//     expect(summary[profile1.id]!.balanceMovements.first.otherUserId, profile2.id);
//     expect(summary[profile1.id]!.balanceMovements.first.amount, 9.99);

//     // Profile 2:
//     expect(summary[profile2.id]!.paidAmountGroup, 100);
//     expect(summary[profile2.id]!.paidAmountItself, 20);
//     expect(summary[profile2.id]!.toReceiveNet, 31.02);
//     expect(summary[profile2.id]!.toReceiveGross, 80);
//     expect(summary[profile2.id]!.movements.length, 2);
//     expect(summary[profile2.id]!.movements.first, isNotNull);
//     expect(summary[profile2.id]!.movements.first.otherUserId, profile1.id);
//     expect(summary[profile2.id]!.movements.first.amount, 26.33);
//     expect(summary[profile2.id]!.movements.last, isNotNull);
//     expect(summary[profile2.id]!.movements.last.otherUserId, profile3.id);
//     expect(summary[profile2.id]!.movements.last.amount, 22.65);
//     expect(summary[profile2.id]!.balanceMovements.length, 0);

//     // Profile 3:
//     expect(summary[profile3.id]!.paidAmountGroup, 75.5);
//     expect(summary[profile3.id]!.paidAmountItself, 30.2);
//     expect(summary[profile3.id]!.toReceiveNet, -21.03);
//     expect(summary[profile3.id]!.toReceiveGross, 45.3);
//     expect(summary[profile3.id]!.movements.length, 2);
//     expect(summary[profile3.id]!.movements.first, isNotNull);
//     expect(summary[profile3.id]!.movements.first.otherUserId, profile1.id);
//     expect(summary[profile3.id]!.movements.first.amount, 26.33);
//     expect(summary[profile3.id]!.movements.last, isNotNull);
//     expect(summary[profile3.id]!.movements.last.otherUserId, profile2.id);
//     expect(summary[profile3.id]!.movements.last.amount, 40.0);
//     expect(summary[profile3.id]!.balanceMovements.length, 1);
//     expect(summary[profile3.id]!.balanceMovements.first, isNotNull);
//     expect(summary[profile3.id]!.balanceMovements.first.otherUserId, profile2.id);
//     expect(summary[profile3.id]!.balanceMovements.first.amount, 21.03);
//   });

// }