// TODO: implementare expensePartecipants 
// import 'package:Billy/enums/split_rate_mode_enum.dart';
// import 'package:Billy/enums/transaction_type_enum.dart';
// import 'package:Billy/models/category/category_model.dart';
// import 'package:Billy/models/group/group_transaction_model.dart';
// import 'package:Billy/models/group/group_participant_model.dart';
// import 'package:Billy/models/merchant_model.dart';
// import 'package:Billy/models/profile_model.dart';
// import 'package:Billy/utils/group_transactions_util.dart';
// import 'package:flutter_test/flutter_test.dart';

// void main() {
//   test('computeParticipantsSummary test: 3 partecipants, 1 transactions by 1 profile, splitRate: ZERO', () {
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
//         paidAmount: 0,
//         totalAmount: 100,
//         splitRate: SplitRateModeEnum.ZERO.name,
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
//     expect(summary[profile1.id]!.paidAmountGroup, 100);
//     expect(summary[profile1.id]!.paidAmountItself, 0);
//     expect(summary[profile1.id]!.toReceiveNet, 100);
//     expect(summary[profile1.id]!.toReceiveGross, 100);
//     expect(summary[profile1.id]!.movements.length, 0);
//     expect(summary[profile1.id]!.balanceMovements.length, 0);

//     // Profile 2:
//     expect(summary[profile2.id]!.paidAmountGroup, 0);
//     expect(summary[profile2.id]!.paidAmountItself, 0);
//     expect(summary[profile2.id]!.toReceiveNet, -50.0);
//     expect(summary[profile2.id]!.toReceiveGross, 0);    
//     expect(summary[profile2.id]!.movements.length, 1);
//     expect(summary[profile2.id]!.balanceMovements.length, 1);
//     expect(summary[profile2.id]!.balanceMovements.first, isNotNull);
//     expect(summary[profile2.id]!.balanceMovements.first.otherUserId, profile1.id);
//     expect(summary[profile2.id]!.balanceMovements.first.amount, 50.0);
    
//     // Profile 3:
//     expect(summary[profile3.id]!.paidAmountGroup, 0);
//     expect(summary[profile3.id]!.paidAmountItself, 0);
//     expect(summary[profile3.id]!.toReceiveNet, -50.0);
//     expect(summary[profile3.id]!.toReceiveGross, 0);    
//     expect(summary[profile3.id]!.movements.length, 1);
//     expect(summary[profile3.id]!.balanceMovements.length, 1);
//     expect(summary[profile3.id]!.balanceMovements.first, isNotNull);
//     expect(summary[profile3.id]!.balanceMovements.first.otherUserId, profile1.id);
//     expect(summary[profile3.id]!.balanceMovements.first.amount, 50.0);
//   });
  
//   test('computeParticipantsSummary test: 3 partecipants, 1 transactions by 1 profile, splitRate: ONE_QUARTER', () {
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
//         paidAmount: 0,
//         totalAmount: 100,
//         splitRate: SplitRateModeEnum.ONE_QUARTER.name,
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
//     expect(summary[profile1.id]!.paidAmountGroup, 100);
//     expect(summary[profile1.id]!.paidAmountItself, 25);
//     expect(summary[profile1.id]!.toReceiveNet, 75);
//     expect(summary[profile1.id]!.toReceiveGross, 75);
//     expect(summary[profile1.id]!.movements.length, 0);
//     expect(summary[profile1.id]!.balanceMovements.length, 0);

//     // Profile 2:
//     expect(summary[profile2.id]!.paidAmountGroup, 0);
//     expect(summary[profile2.id]!.paidAmountItself, 0);
//     expect(summary[profile2.id]!.toReceiveNet, -37.5);
//     expect(summary[profile2.id]!.toReceiveGross, 0);    
//     expect(summary[profile2.id]!.movements.length, 1);
//     expect(summary[profile2.id]!.balanceMovements.length, 1);
//     expect(summary[profile2.id]!.balanceMovements.first, isNotNull);
//     expect(summary[profile2.id]!.balanceMovements.first.otherUserId, profile1.id);
//     expect(summary[profile2.id]!.balanceMovements.first.amount, 37.5);
    
//     // Profile 3:
//     expect(summary[profile3.id]!.paidAmountGroup, 0);
//     expect(summary[profile3.id]!.paidAmountItself, 0);
//     expect(summary[profile3.id]!.toReceiveNet, -37.5);
//     expect(summary[profile3.id]!.toReceiveGross, 0);    
//     expect(summary[profile3.id]!.movements.length, 1);
//     expect(summary[profile3.id]!.balanceMovements.length, 1);
//     expect(summary[profile3.id]!.balanceMovements.first, isNotNull);
//     expect(summary[profile3.id]!.balanceMovements.first.otherUserId, profile1.id);
//     expect(summary[profile3.id]!.balanceMovements.first.amount, 37.5);
//   });
  
//   test('computeParticipantsSummary test: 3 partecipants, 2 transactions by 1 profile, splitRate: ONE_QUARTER, HALF', () {
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
//         paidAmount: 0,
//         totalAmount: 100,
//         splitRate: SplitRateModeEnum.ONE_QUARTER.name,
//         transactionType: TransactionTypeEnum.EXPENSE,
//         createdAt: DateTime.now(),
//         updatedAt: DateTime.now(),
//       ),
//       GroupTransactionModel(
//         id: 'e1',
//         groupId: 'g1',
//         profileModel: profile1,
//         merchant: MerchantModel(id: 'merchant1', name: 'merchant1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         category: CategoryModel(id: 'category1', name: 'category1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         paidAmount: 0,
//         totalAmount: 100,
//         splitRate: SplitRateModeEnum.HALF.name,
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
//     expect(summary[profile1.id]!.paidAmountItself, 75);
//     expect(summary[profile1.id]!.toReceiveNet, 125);
//     expect(summary[profile1.id]!.toReceiveGross, 125);
//     expect(summary[profile1.id]!.movements.length, 0);
//     expect(summary[profile1.id]!.balanceMovements.length, 0);

//     // Profile 2:
//     expect(summary[profile2.id]!.paidAmountGroup, 0);
//     expect(summary[profile2.id]!.paidAmountItself, 0);
//     expect(summary[profile2.id]!.toReceiveNet, -62.5);
//     expect(summary[profile2.id]!.toReceiveGross, 0);    
//     expect(summary[profile2.id]!.movements.length, 1);
//     expect(summary[profile2.id]!.balanceMovements.length, 1);
//     expect(summary[profile2.id]!.balanceMovements.first, isNotNull);
//     expect(summary[profile2.id]!.balanceMovements.first.otherUserId, profile1.id);
//     expect(summary[profile2.id]!.balanceMovements.first.amount, 62.5);
    
//     // Profile 3:
//     expect(summary[profile3.id]!.paidAmountGroup, 0);
//     expect(summary[profile3.id]!.paidAmountItself, 0);
//     expect(summary[profile3.id]!.toReceiveNet, -62.5);
//     expect(summary[profile3.id]!.toReceiveGross, 0);    
//     expect(summary[profile3.id]!.movements.length, 1);
//     expect(summary[profile3.id]!.balanceMovements.length, 1);
//     expect(summary[profile3.id]!.balanceMovements.first, isNotNull);
//     expect(summary[profile3.id]!.balanceMovements.first.otherUserId, profile1.id);
//     expect(summary[profile3.id]!.balanceMovements.first.amount, 62.5);
//   });
  
//   test('computeParticipantsSummary test: 3 partecipants, 3 transactions by 1 profile, splitRate: ONE_QUARTER, HALF, FIXED_2', () {
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
//         paidAmount: 0,
//         totalAmount: 100,
//         splitRate: SplitRateModeEnum.ONE_QUARTER.name,
//         transactionType: TransactionTypeEnum.EXPENSE,
//         createdAt: DateTime.now(),
//         updatedAt: DateTime.now(),
//       ),
//       GroupTransactionModel(
//         id: 'e1',
//         groupId: 'g1',
//         profileModel: profile1,
//         merchant: MerchantModel(id: 'merchant1', name: 'merchant1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         category: CategoryModel(id: 'category1', name: 'category1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         paidAmount: 0,
//         totalAmount: 100,
//         splitRate: SplitRateModeEnum.HALF.name,
//         transactionType: TransactionTypeEnum.EXPENSE,
//         createdAt: DateTime.now(),
//         updatedAt: DateTime.now(),
//       ),
//       GroupTransactionModel(
//         id: 'e1',
//         groupId: 'g1',
//         profileModel: profile1,
//         merchant: MerchantModel(id: 'merchant1', name: 'merchant1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         category: CategoryModel(id: 'category1', name: 'category1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         paidAmount: 0,
//         totalAmount: 150,
//         splitRate: SplitRateModeEnum.FIXED_2.name,
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
//     expect(summary[profile1.id]!.paidAmountGroup, 350);
//     expect(summary[profile1.id]!.paidAmountItself, 175);
//     expect(summary[profile1.id]!.toReceiveNet, 175);
//     expect(summary[profile1.id]!.toReceiveGross, 175);
//     expect(summary[profile1.id]!.movements.length, 0);
//     expect(summary[profile1.id]!.balanceMovements.length, 0);

//     // Profile 2:
//     expect(summary[profile2.id]!.paidAmountGroup, 0);
//     expect(summary[profile2.id]!.paidAmountItself, 0);
//     expect(summary[profile2.id]!.toReceiveNet, -87.5);
//     expect(summary[profile2.id]!.toReceiveGross, 0);    
//     expect(summary[profile2.id]!.movements.length, 1);
//     expect(summary[profile2.id]!.balanceMovements.length, 1);
//     expect(summary[profile2.id]!.balanceMovements.first, isNotNull);
//     expect(summary[profile2.id]!.balanceMovements.first.otherUserId, profile1.id);
//     expect(summary[profile2.id]!.balanceMovements.first.amount, 87.5);
    
//     // Profile 3:
//     expect(summary[profile3.id]!.paidAmountGroup, 0);
//     expect(summary[profile3.id]!.paidAmountItself, 0);
//     expect(summary[profile3.id]!.toReceiveNet, -87.5);
//     expect(summary[profile3.id]!.toReceiveGross, 0);    
//     expect(summary[profile3.id]!.movements.length, 1);
//     expect(summary[profile3.id]!.balanceMovements.length, 1);
//     expect(summary[profile3.id]!.balanceMovements.first, isNotNull);
//     expect(summary[profile3.id]!.balanceMovements.first.otherUserId, profile1.id);
//     expect(summary[profile3.id]!.balanceMovements.first.amount, 87.5);
//   });
  
//   test('computeParticipantsSummary test: 3 partecipants, 3 transactions by 1 profile, infinite decimals, splitRate: THREE_QUARTERS, HALF, FIXED_2', () {
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
//         paidAmount: 0,
//         totalAmount: 100,
//         splitRate: SplitRateModeEnum.THREE_QUARTERS.name,
//         transactionType: TransactionTypeEnum.EXPENSE,
//         createdAt: DateTime.now(),
//         updatedAt: DateTime.now(),
//       ),
//       GroupTransactionModel(
//         id: 'e1',
//         groupId: 'g1',
//         profileModel: profile1,
//         merchant: MerchantModel(id: 'merchant1', name: 'merchant1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         category: CategoryModel(id: 'category1', name: 'category1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         paidAmount: 0,
//         totalAmount: 100,
//         splitRate: SplitRateModeEnum.HALF.name,
//         transactionType: TransactionTypeEnum.EXPENSE,
//         createdAt: DateTime.now(),
//         updatedAt: DateTime.now(),
//       ),
//       GroupTransactionModel(
//         id: 'e1',
//         groupId: 'g1',
//         profileModel: profile1,
//         merchant: MerchantModel(id: 'merchant1', name: 'merchant1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         category: CategoryModel(id: 'category1', name: 'category1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         paidAmount: 0,
//         totalAmount: 100,
//         splitRate: SplitRateModeEnum.FIXED_2.name,
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
//     expect(summary[profile1.id]!.paidAmountGroup, 300);
//     expect(summary[profile1.id]!.paidAmountItself, 191.67);
//     expect(summary[profile1.id]!.toReceiveNet, 108.33);
//     expect(summary[profile1.id]!.toReceiveGross, 108.33);
//     expect(summary[profile1.id]!.movements.length, 0);
//     expect(summary[profile1.id]!.balanceMovements.length, 0);

//     // Profile 2:
//     expect(summary[profile2.id]!.paidAmountGroup, 0);
//     expect(summary[profile2.id]!.paidAmountItself, 0);
//     expect(summary[profile2.id]!.toReceiveNet, -54.16);
//     expect(summary[profile2.id]!.toReceiveGross, 0);    
//     expect(summary[profile2.id]!.movements.length, 1);
//     expect(summary[profile2.id]!.balanceMovements.length, 1);
//     expect(summary[profile2.id]!.balanceMovements.first, isNotNull);
//     expect(summary[profile2.id]!.balanceMovements.first.otherUserId, profile1.id);
//     expect(summary[profile2.id]!.balanceMovements.first.amount, 54.16);
    
//     // Profile 3:
//     expect(summary[profile3.id]!.paidAmountGroup, 0);
//     expect(summary[profile3.id]!.paidAmountItself, 0);
//     expect(summary[profile3.id]!.toReceiveNet, -54.16);
//     expect(summary[profile3.id]!.toReceiveGross, 0);    
//     expect(summary[profile3.id]!.movements.length, 1);
//     expect(summary[profile3.id]!.balanceMovements.length, 1);
//     expect(summary[profile3.id]!.balanceMovements.first, isNotNull);
//     expect(summary[profile3.id]!.balanceMovements.first.otherUserId, profile1.id);
//     expect(summary[profile3.id]!.balanceMovements.first.amount, 54.17); // TODO: dovrebbe essere uguale a -toReceiveNet
//   });

//   test('computeParticipantsSummary test: 3 partecipants, 4 transactions by 2 profile, infinite decimals, splitRate: THREE_QUARTERS, HALF, FIXED_2, ZERO', () {
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
//         paidAmount: 0,
//         totalAmount: 100,
//         splitRate: SplitRateModeEnum.THREE_QUARTERS.name,
//         transactionType: TransactionTypeEnum.EXPENSE,
//         createdAt: DateTime.now(),
//         updatedAt: DateTime.now(),
//       ),
//       GroupTransactionModel(
//         id: 'e1',
//         groupId: 'g1',
//         profileModel: profile1,
//         merchant: MerchantModel(id: 'merchant1', name: 'merchant1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         category: CategoryModel(id: 'category1', name: 'category1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         paidAmount: 0,
//         totalAmount: 100,
//         splitRate: SplitRateModeEnum.HALF.name,
//         transactionType: TransactionTypeEnum.EXPENSE,
//         createdAt: DateTime.now(),
//         updatedAt: DateTime.now(),
//       ),
//       GroupTransactionModel(
//         id: 'e1',
//         groupId: 'g1',
//         profileModel: profile1,
//         merchant: MerchantModel(id: 'merchant1', name: 'merchant1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         category: CategoryModel(id: 'category1', name: 'category1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         paidAmount: 0,
//         totalAmount: 125,
//         splitRate: SplitRateModeEnum.FIXED_2.name,
//         transactionType: TransactionTypeEnum.EXPENSE,
//         createdAt: DateTime.now(),
//         updatedAt: DateTime.now(),
//       ),
//       GroupTransactionModel(
//         id: 'e2',
//         groupId: 'g1',
//         profileModel: profile2,
//         merchant: MerchantModel(id: 'merchant1', name: 'merchant1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         category: CategoryModel(id: 'category1', name: 'category1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         paidAmount: 0,
//         totalAmount: 100,
//         splitRate: SplitRateModeEnum.ZERO.name,
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
//     expect(summary[profile1.id]!.paidAmountGroup, 325);
//     expect(summary[profile1.id]!.paidAmountItself, 208.33);
//     expect(summary[profile1.id]!.toReceiveNet, 66.67);
//     expect(summary[profile1.id]!.toReceiveGross, 116.67);
//     expect(summary[profile1.id]!.movements.length, 1);
//     expect(summary[profile1.id]!.movements.first, isNotNull);
//     expect(summary[profile1.id]!.movements.first.otherUserId, profile2.id);
//     expect(summary[profile1.id]!.movements.first.amount, 50.0);
//     expect(summary[profile1.id]!.balanceMovements.length, 0);

//     // Profile 2:
//     expect(summary[profile2.id]!.paidAmountGroup, 100);
//     expect(summary[profile2.id]!.paidAmountItself, 0);
//     expect(summary[profile2.id]!.toReceiveNet, 41.66);
//     expect(summary[profile2.id]!.toReceiveGross, 100);
//     expect(summary[profile2.id]!.movements.length, 1);
//     expect(summary[profile2.id]!.movements.first, isNotNull);
//     expect(summary[profile2.id]!.movements.first.otherUserId, profile1.id);
//     expect(summary[profile2.id]!.movements.first.amount, 58.34);
//     expect(summary[profile2.id]!.balanceMovements.length, 0);
    
//     // Profile 3:
//     expect(summary[profile3.id]!.paidAmountGroup, 0);
//     expect(summary[profile3.id]!.paidAmountItself, 0);
//     expect(summary[profile3.id]!.toReceiveNet, -108.34);
//     expect(summary[profile3.id]!.toReceiveGross, 0);    
//     expect(summary[profile3.id]!.movements.length, 2);
//     expect(summary[profile3.id]!.movements.first, isNotNull);
//     expect(summary[profile3.id]!.movements.first.otherUserId, profile1.id);
//     expect(summary[profile3.id]!.movements.first.amount, 58.34);
//     expect(summary[profile3.id]!.movements.last, isNotNull);
//     expect(summary[profile3.id]!.movements.last.otherUserId, profile2.id);
//     expect(summary[profile3.id]!.movements.last.amount, 50.0);
//     expect(summary[profile3.id]!.balanceMovements.length, 2);
//     expect(summary[profile3.id]!.balanceMovements.first, isNotNull);
//     expect(summary[profile3.id]!.balanceMovements.first.otherUserId, profile1.id);
//     expect(summary[profile3.id]!.balanceMovements.first.amount, 66.67);
//     expect(summary[profile3.id]!.balanceMovements.last, isNotNull);
//     expect(summary[profile3.id]!.balanceMovements.last.otherUserId, profile2.id);
//     expect(summary[profile3.id]!.balanceMovements.last.amount, 41.66);
//   });

//   // TODO: i valoti sono diversi da quelli attesi nel test: 9, foglio: https://docs.google.com/spreadsheets/d/1sSD2cqKpuK4onoznpVnXd1A2KqF4pa9s6lfeVviDpy0/edit?gid=1930678752#gid=1930678752
//   test('computeParticipantsSummary test: 3 partecipants, 4 transactions by 2 profile, infinite decimals, splitRate: THREE_QUARTERS, HALF, FIXED_2, FIXED_1', () {
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
//         paidAmount: 0,
//         totalAmount: 100,
//         splitRate: SplitRateModeEnum.THREE_QUARTERS.name,
//         transactionType: TransactionTypeEnum.EXPENSE,
//         createdAt: DateTime.now(),
//         updatedAt: DateTime.now(),
//       ),
//       GroupTransactionModel(
//         id: 'e1',
//         groupId: 'g1',
//         profileModel: profile1,
//         merchant: MerchantModel(id: 'merchant1', name: 'merchant1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         category: CategoryModel(id: 'category1', name: 'category1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         paidAmount: 0,
//         totalAmount: 100,
//         splitRate: SplitRateModeEnum.HALF.name,
//         transactionType: TransactionTypeEnum.EXPENSE,
//         createdAt: DateTime.now(),
//         updatedAt: DateTime.now(),
//       ),
//       GroupTransactionModel(
//         id: 'e1',
//         groupId: 'g1',
//         profileModel: profile1,
//         merchant: MerchantModel(id: 'merchant1', name: 'merchant1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         category: CategoryModel(id: 'category1', name: 'category1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         paidAmount: 0,
//         totalAmount: 112.6,
//         splitRate: SplitRateModeEnum.FIXED_2.name,
//         transactionType: TransactionTypeEnum.EXPENSE,
//         createdAt: DateTime.now(),
//         updatedAt: DateTime.now(),
//       ),
//       GroupTransactionModel(
//         id: 'e2',
//         groupId: 'g1',
//         profileModel: profile2,
//         merchant: MerchantModel(id: 'merchant1', name: 'merchant1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         category: CategoryModel(id: 'category1', name: 'category1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         paidAmount: 0,
//         totalAmount: 100,
//         splitRate: SplitRateModeEnum.FIXED_1.name,
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
//     expect(summary[profile1.id]!.paidAmountGroup, 312.6);
//     expect(summary[profile1.id]!.paidAmountItself, 200.07);
//     expect(summary[profile1.id]!.toReceiveNet, 79.19);
//     expect(summary[profile1.id]!.toReceiveGross, 112.53);
//     expect(summary[profile1.id]!.movements.length, 1);
//     expect(summary[profile1.id]!.movements.first, isNotNull);
//     expect(summary[profile1.id]!.movements.first.otherUserId, profile2.id);
//     expect(summary[profile1.id]!.movements.first.amount, 33.34);
//     expect(summary[profile1.id]!.balanceMovements.length, 0);

//     // Profile 2:
//     expect(summary[profile2.id]!.paidAmountGroup, 100);
//     expect(summary[profile2.id]!.paidAmountItself, 33.33);
//     expect(summary[profile2.id]!.toReceiveNet, 10.4);
//     expect(summary[profile2.id]!.toReceiveGross, 66.67);
//     expect(summary[profile2.id]!.movements.length, 1);
//     expect(summary[profile2.id]!.movements.first, isNotNull);
//     expect(summary[profile2.id]!.movements.first.otherUserId, profile1.id);
//     expect(summary[profile2.id]!.movements.first.amount, 56.27);
//     expect(summary[profile2.id]!.balanceMovements.length, 0);
    
//     // Profile 3:
//     expect(summary[profile3.id]!.paidAmountGroup, 0);
//     expect(summary[profile3.id]!.paidAmountItself, 0);
//     expect(summary[profile3.id]!.toReceiveNet, -89.61);
//     expect(summary[profile3.id]!.toReceiveGross, 0);    
//     expect(summary[profile3.id]!.movements.length, 2);
//     expect(summary[profile3.id]!.movements.first, isNotNull);
//     expect(summary[profile3.id]!.movements.first.otherUserId, profile1.id);
//     expect(summary[profile3.id]!.movements.first.amount, 56.27);
//     expect(summary[profile3.id]!.movements.last, isNotNull);
//     expect(summary[profile3.id]!.movements.last.otherUserId, profile2.id);
//     expect(summary[profile3.id]!.movements.last.amount, 33.34);
//     expect(summary[profile3.id]!.balanceMovements.length, 2);
//     expect(summary[profile3.id]!.balanceMovements.first, isNotNull);
//     expect(summary[profile3.id]!.balanceMovements.first.otherUserId, profile1.id);
//     expect(summary[profile3.id]!.balanceMovements.first.amount, 79.19);
//     expect(summary[profile3.id]!.balanceMovements.last, isNotNull);
//     expect(summary[profile3.id]!.balanceMovements.last.otherUserId, profile2.id);
//     expect(summary[profile3.id]!.balanceMovements.last.amount, 10.4);
//   });

//   // TODO: i valoti sono diversi da quelli attesi nel test: 9, foglio: https://docs.google.com/spreadsheets/d/1sSD2cqKpuK4onoznpVnXd1A2KqF4pa9s6lfeVviDpy0/edit?gid=1930678752#gid=1930678752
//   test('computeParticipantsSummary test: 3 partecipants, 6 transactions by 3 profile, infinite decimals, splitRate: THREE_QUARTERS, HALF, FIXED_2, FIXED_2, THREE_QUARTERS', () {
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
//         paidAmount: 0,
//         totalAmount: 100,
//         splitRate: SplitRateModeEnum.THREE_QUARTERS.name,
//         transactionType: TransactionTypeEnum.EXPENSE,
//         createdAt: DateTime.now(),
//         updatedAt: DateTime.now(),
//       ),
//       GroupTransactionModel(
//         id: 'e1',
//         groupId: 'g1',
//         profileModel: profile1,
//         merchant: MerchantModel(id: 'merchant1', name: 'merchant1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         category: CategoryModel(id: 'category1', name: 'category1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         paidAmount: 0,
//         totalAmount: 100,
//         splitRate: SplitRateModeEnum.HALF.name,
//         transactionType: TransactionTypeEnum.EXPENSE,
//         createdAt: DateTime.now(),
//         updatedAt: DateTime.now(),
//       ),
//       GroupTransactionModel(
//         id: 'e1',
//         groupId: 'g1',
//         profileModel: profile1,
//         merchant: MerchantModel(id: 'merchant1', name: 'merchant1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         category: CategoryModel(id: 'category1', name: 'category1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         paidAmount: 0,
//         totalAmount: 121,
//         splitRate: SplitRateModeEnum.FIXED_2.name,
//         transactionType: TransactionTypeEnum.EXPENSE,
//         createdAt: DateTime.now(),
//         updatedAt: DateTime.now(),
//       ),
//       GroupTransactionModel(
//         id: 'e2',
//         groupId: 'g1',
//         profileModel: profile2,
//         merchant: MerchantModel(id: 'merchant1', name: 'merchant1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         category: CategoryModel(id: 'category1', name: 'category1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         paidAmount: 0,
//         totalAmount: 100,
//         splitRate: SplitRateModeEnum.FIXED_1.name,
//         transactionType: TransactionTypeEnum.EXPENSE,
//         createdAt: DateTime.now(),
//         updatedAt: DateTime.now(),
//       ),
//       GroupTransactionModel(
//         id: 'e3',
//         groupId: 'g1',
//         profileModel: profile3,
//         merchant: MerchantModel(id: 'merchant1', name: 'merchant1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         category: CategoryModel(id: 'category1', name: 'category1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         paidAmount: 0,
//         totalAmount: 150,
//         splitRate: SplitRateModeEnum.FIXED_2.name,
//         transactionType: TransactionTypeEnum.EXPENSE,
//         createdAt: DateTime.now(),
//         updatedAt: DateTime.now(),
//       ),
//       GroupTransactionModel(
//         id: 'e3',
//         groupId: 'g1',
//         profileModel: profile3,
//         merchant: MerchantModel(id: 'merchant1', name: 'merchant1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         category: CategoryModel(id: 'category1', name: 'category1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
//         paidAmount: 0,
//         totalAmount: 150,
//         splitRate: SplitRateModeEnum.THREE_QUARTERS.name,
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
//     expect(summary[profile1.id]!.paidAmountGroup, 321);
//     expect(summary[profile1.id]!.paidAmountItself, 205.67);
//     expect(summary[profile1.id]!.toReceiveNet, 38.24);
//     expect(summary[profile1.id]!.toReceiveGross, 115.33);
//     expect(summary[profile1.id]!.movements.length, 2);
//     expect(summary[profile1.id]!.movements.first, isNotNull);
//     expect(summary[profile1.id]!.movements.first.otherUserId, profile2.id);
//     expect(summary[profile1.id]!.movements.first.amount, 33.34);
//     expect(summary[profile1.id]!.movements.last, isNotNull);
//     expect(summary[profile1.id]!.movements.last.otherUserId, profile3.id);
//     expect(summary[profile1.id]!.movements.last.amount, 43.75);
//     expect(summary[profile1.id]!.balanceMovements.length, 0);

//     // Profile 2:
//     expect(summary[profile2.id]!.paidAmountGroup, 100);
//     expect(summary[profile2.id]!.paidAmountItself, 33.33);
//     expect(summary[profile2.id]!.toReceiveNet, -34.74);
//     expect(summary[profile2.id]!.toReceiveGross, 66.67);
//     expect(summary[profile2.id]!.movements.length, 2);
//     expect(summary[profile2.id]!.movements.first, isNotNull);
//     expect(summary[profile2.id]!.movements.first.otherUserId, profile1.id);
//     expect(summary[profile2.id]!.movements.first.amount, 57.66);
//     expect(summary[profile2.id]!.movements.last, isNotNull);
//     expect(summary[profile2.id]!.movements.last.otherUserId, profile3.id);
//     expect(summary[profile2.id]!.movements.last.amount, 43.75);
//     expect(summary[profile2.id]!.balanceMovements.length, 1);
//     expect(summary[profile2.id]!.balanceMovements.first, isNotNull);
//     expect(summary[profile2.id]!.balanceMovements.first.otherUserId, profile1.id);
//     expect(summary[profile2.id]!.balanceMovements.first.amount, 34.74);
    
//     // Profile 3:
//     expect(summary[profile3.id]!.paidAmountGroup, 300);
//     expect(summary[profile3.id]!.paidAmountItself, 212.5);
//     expect(summary[profile3.id]!.toReceiveNet, -3.5);
//     expect(summary[profile3.id]!.toReceiveGross, 87.5);    
//     expect(summary[profile3.id]!.movements.length, 2);
//     expect(summary[profile3.id]!.movements.first, isNotNull);
//     expect(summary[profile3.id]!.movements.first.otherUserId, profile1.id);
//     expect(summary[profile3.id]!.movements.first.amount, 57.66);
//     expect(summary[profile3.id]!.movements.last, isNotNull);
//     expect(summary[profile3.id]!.movements.last.otherUserId, profile2.id);
//     expect(summary[profile3.id]!.movements.last.amount, 33.34);
//     expect(summary[profile3.id]!.balanceMovements.length, 1);
//     expect(summary[profile3.id]!.balanceMovements.first, isNotNull);
//     expect(summary[profile3.id]!.balanceMovements.first.otherUserId, profile1.id);
//     expect(summary[profile3.id]!.balanceMovements.first.amount, 3.5);
//   });

// }