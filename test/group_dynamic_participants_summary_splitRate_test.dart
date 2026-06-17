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
  
//   test('computeDynamicParticipantsSummary test 1: { Time 1: 3 partecipants, 2 transactions by 1 profile, splitRate: ONE_QUARTER, HALF, Time 2: 4 partecipants, 2 transactions by 1 profile, splitRate: ONE_QUARTER, HALF', () {
//     // Crea un'istanza della classe (se serve)
//     final profile1 = ProfileModel(id: 'profile1', name: 'profile1', username: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now());
//     final profile2 = ProfileModel(id: 'profile2', name: 'profile2', username: 'profile2', createdAt: DateTime.now(), updatedAt: DateTime.now());
//     final profile3 = ProfileModel(id: 'profile3', name: 'profile3', username: 'profile3', createdAt: DateTime.now(), updatedAt: DateTime.now());
//     final profile4 = ProfileModel(id: 'profile4', name: 'profile4', username: 'profile4', createdAt: DateTime.now(), updatedAt: DateTime.now());

//     // Prepara dati di test   
//     final groupParticipantsT1 = [
//       GroupParticipantModel(userId: 'profile1', profile: profile1),
//       GroupParticipantModel(userId: 'profile2', profile: profile2),
//       GroupParticipantModel(userId: 'profile3', profile: profile3)
//     ];

//     final transactionsT1 = [
//       GroupTransactionModel(
//         id: 'transaction1',
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
//         id: 'transaction2',
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

//     final summaryT1 = GroupTransactionsUtil.computeParticipantsSummary(transactions: transactionsT1, participants: groupParticipantsT1);
    
//     expect(summaryT1, isNotNull);
//     expect(summaryT1.entries.length, 3);

//     expect(summaryT1[profile1.id], isNotNull);
//     expect(summaryT1[profile2.id], isNotNull);
//     expect(summaryT1[profile3.id], isNotNull);
    
//     // Profile 1:
//     expect(summaryT1[profile1.id]!.paidAmountGroup, 200);
//     expect(summaryT1[profile1.id]!.paidAmountItself, 75);
//     expect(summaryT1[profile1.id]!.toReceiveNet, 125);
//     expect(summaryT1[profile1.id]!.toReceiveGross, 125);
//     expect(summaryT1[profile1.id]!.movements.length, 0);
//     expect(summaryT1[profile1.id]!.balanceMovements.length, 0);

//     // Profile 2:
//     expect(summaryT1[profile2.id]!.paidAmountGroup, 0);
//     expect(summaryT1[profile2.id]!.paidAmountItself, 0);
//     expect(summaryT1[profile2.id]!.toReceiveNet, -62.5);
//     expect(summaryT1[profile2.id]!.toReceiveGross, 0);    
//     expect(summaryT1[profile2.id]!.movements.length, 1);
//     expect(summaryT1[profile2.id]!.balanceMovements.length, 1);
//     expect(summaryT1[profile2.id]!.balanceMovements.first, isNotNull);
//     expect(summaryT1[profile2.id]!.balanceMovements.first.otherUserId, profile1.id);
//     expect(summaryT1[profile2.id]!.balanceMovements.first.amount, 62.5);
    
//     // Profile 3:
//     expect(summaryT1[profile3.id]!.paidAmountGroup, 0);
//     expect(summaryT1[profile3.id]!.paidAmountItself, 0);
//     expect(summaryT1[profile3.id]!.toReceiveNet, -62.5);
//     expect(summaryT1[profile3.id]!.toReceiveGross, 0);    
//     expect(summaryT1[profile3.id]!.movements.length, 1);
//     expect(summaryT1[profile3.id]!.balanceMovements.length, 1);
//     expect(summaryT1[profile3.id]!.balanceMovements.first, isNotNull);
//     expect(summaryT1[profile3.id]!.balanceMovements.first.otherUserId, profile1.id);
//     expect(summaryT1[profile3.id]!.balanceMovements.first.amount, 62.5);

//     final transactionsT2 = [
//       GroupTransactionModel(
//         id: 'transaction3',
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
//         id: 'transaction4',
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

//     final groupParticipantsT2 = [
//       GroupParticipantModel(userId: 'profile2', profile: profile2),
//       GroupParticipantModel(userId: 'profile3', profile: profile3),
//       GroupParticipantModel(userId: 'profile4', profile: profile4)
//     ];
    
//     final summaryT2 = GroupTransactionsUtil.computeParticipantsSummary(transactions: transactionsT2, participants: groupParticipantsT2);
    
//     expect(summaryT2, isNotNull);
//     expect(summaryT2.entries.length, 4);

//     expect(summaryT2[profile1.id], isNotNull);
//     expect(summaryT2[profile2.id], isNotNull);
//     expect(summaryT2[profile3.id], isNotNull);
//     expect(summaryT2[profile4.id], isNotNull);
    
//     // Profile 1:
//     expect(summaryT2[profile1.id]!.paidAmountGroup, 200);
//     expect(summaryT2[profile1.id]!.paidAmountItself, 75);
//     expect(summaryT2[profile1.id]!.toReceiveNet, 125);
//     expect(summaryT2[profile1.id]!.toReceiveGross, 125);
//     expect(summaryT2[profile1.id]!.movements.length, 0);
//     expect(summaryT2[profile1.id]!.balanceMovements.length, 0);

//     // Profile 2:
//     expect(summaryT2[profile2.id]!.paidAmountGroup, 0);
//     expect(summaryT2[profile2.id]!.paidAmountItself, 0);
//     expect(summaryT2[profile2.id]!.toReceiveNet, -41.67);
//     expect(summaryT2[profile2.id]!.toReceiveGross, 0);    
//     expect(summaryT2[profile2.id]!.movements.length, 1);
//     expect(summaryT2[profile2.id]!.balanceMovements.length, 1);
//     expect(summaryT2[profile2.id]!.balanceMovements.first, isNotNull);
//     expect(summaryT2[profile2.id]!.balanceMovements.first.otherUserId, profile1.id);
//     expect(summaryT2[profile2.id]!.balanceMovements.first.amount, 41.67);
    
//     // Profile 3:
//     expect(summaryT2[profile3.id]!.paidAmountGroup, 0);
//     expect(summaryT2[profile3.id]!.paidAmountItself, 0);
//     expect(summaryT2[profile3.id]!.toReceiveNet, -41.67);
//     expect(summaryT2[profile3.id]!.toReceiveGross, 0);    
//     expect(summaryT2[profile3.id]!.movements.length, 1);
//     expect(summaryT2[profile3.id]!.balanceMovements.length, 1);
//     expect(summaryT2[profile3.id]!.balanceMovements.first, isNotNull);
//     expect(summaryT2[profile3.id]!.balanceMovements.first.otherUserId, profile1.id);
//     expect(summaryT2[profile3.id]!.balanceMovements.first.amount, 41.67);

//     // Profile 4:
//     expect(summaryT2[profile4.id]!.paidAmountGroup, 0);
//     expect(summaryT2[profile4.id]!.paidAmountItself, 0);
//     expect(summaryT2[profile4.id]!.toReceiveNet, -41.67);
//     expect(summaryT2[profile4.id]!.toReceiveGross, 0);    
//     expect(summaryT2[profile4.id]!.movements.length, 1);
//     expect(summaryT2[profile4.id]!.balanceMovements.length, 1);
//     expect(summaryT2[profile4.id]!.balanceMovements.first, isNotNull);
//     expect(summaryT2[profile4.id]!.balanceMovements.first.otherUserId, profile1.id);
//     expect(summaryT2[profile4.id]!.balanceMovements.first.amount, 41.66);

//     final mergedSummary = GroupTransactionsUtil.mergeSummaries(summaryT1, summaryT2);
//     GroupTransactionsUtil.computeDynamicParticipantsSummary(summary: mergedSummary);

//     expect(mergedSummary, isNotNull);
//     expect(mergedSummary.entries.length, 4);

//     expect(mergedSummary[profile1.id], isNotNull);
//     expect(mergedSummary[profile2.id], isNotNull);
//     expect(mergedSummary[profile3.id], isNotNull);
//     expect(mergedSummary[profile4.id], isNotNull);
    
//     // Profile 1:
//     expect(mergedSummary[profile1.id]!.paidAmountGroup, 400);
//     expect(mergedSummary[profile1.id]!.paidAmountItself, 150);
//     expect(mergedSummary[profile1.id]!.toReceiveNet, 250);
//     expect(mergedSummary[profile1.id]!.toReceiveGross, 250);
//     expect(mergedSummary[profile1.id]!.movements.length, 0);
//     expect(mergedSummary[profile1.id]!.balanceMovements.length, 0);

//     // Profile 2:
//     expect(mergedSummary[profile2.id]!.paidAmountGroup, 0);
//     expect(mergedSummary[profile2.id]!.paidAmountItself, 0);
//     expect(mergedSummary[profile2.id]!.toReceiveNet, -104.17); // -41.67 + -62.5
//     expect(mergedSummary[profile2.id]!.toReceiveGross, 0);    
//     expect(mergedSummary[profile2.id]!.movements.length, 2);
//     expect(mergedSummary[profile2.id]!.balanceMovements.length, 1);
//     expect(mergedSummary[profile2.id]!.balanceMovements.first, isNotNull);
//     expect(mergedSummary[profile2.id]!.balanceMovements.first.otherUserId, profile1.id);
//     expect(mergedSummary[profile2.id]!.balanceMovements.first.amount, 104.17); // 41.67 + 62.5

//     // Profile 3:
//     expect(mergedSummary[profile3.id]!.paidAmountGroup, 0);
//     expect(mergedSummary[profile3.id]!.paidAmountItself, 0);
//     expect(mergedSummary[profile3.id]!.toReceiveNet, -104.17); // -41.67 + -62.5
//     expect(mergedSummary[profile3.id]!.toReceiveGross, 0);    
//     expect(mergedSummary[profile3.id]!.movements.length, 2);
//     expect(mergedSummary[profile3.id]!.balanceMovements.length, 1);
//     expect(mergedSummary[profile3.id]!.balanceMovements.first, isNotNull);
//     expect(mergedSummary[profile3.id]!.balanceMovements.first.otherUserId, profile1.id);
//     expect(mergedSummary[profile3.id]!.balanceMovements.first.amount, 104.17); // 41.67 + 62.5

//     // Profile 4:
//     expect(mergedSummary[profile4.id]!.paidAmountGroup, 0);
//     expect(mergedSummary[profile4.id]!.paidAmountItself, 0);
//     expect(mergedSummary[profile4.id]!.toReceiveNet, -41.67);
//     expect(mergedSummary[profile4.id]!.toReceiveGross, 0);    
//     expect(mergedSummary[profile4.id]!.movements.length, 1);
//     expect(mergedSummary[profile4.id]!.balanceMovements.length, 1);
//     expect(mergedSummary[profile4.id]!.balanceMovements.first, isNotNull);
//     expect(mergedSummary[profile4.id]!.balanceMovements.first.otherUserId, profile1.id);
//     expect(mergedSummary[profile4.id]!.balanceMovements.first.amount, 41.66);

//   });
  
//   test('computeDynamicParticipantsSummary test 2: { Time 1: 3 partecipants (p1, p2, p3), 4 transactions by 3 profiles, paidAmount, { Time 2: test: 3 partecipants (p2, p3, p4), 4 transactions by 2 profile, infinite decimals, splitRate: THREE_QUARTERS, HALF, FIXED_2, ZERO }', () {
//     // Crea un'istanza della classe (se serve)
//     final profile1 = ProfileModel(id: 'profile1', name: 'profile1', username: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now());
//     final profile2 = ProfileModel(id: 'profile2', name: 'profile2', username: 'profile2', createdAt: DateTime.now(), updatedAt: DateTime.now());
//     final profile3 = ProfileModel(id: 'profile3', name: 'profile3', username: 'profile3', createdAt: DateTime.now(), updatedAt: DateTime.now());
//     final profile4 = ProfileModel(id: 'profile4', name: 'profile4', username: 'profile4', createdAt: DateTime.now(), updatedAt: DateTime.now());

//     // Prepara dati di test
//     final transactionsT1 = [
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
//         totalAmount: 150,
//         splitRate: null,
//         transactionType: TransactionTypeEnum.EXPENSE,
//         createdAt: DateTime.now(),
//         updatedAt: DateTime.now(),
//       ),
//     ];

//     final groupParticipantsT1 = [
//       GroupParticipantModel(userId: 'profile1', profile: profile1),
//       GroupParticipantModel(userId: 'profile2', profile: profile2),
//       GroupParticipantModel(userId: 'profile3', profile: profile3)
//     ];

//     final summaryT1 = GroupTransactionsUtil.computeParticipantsSummary(transactions: transactionsT1, participants: groupParticipantsT1);
    
//     expect(summaryT1, isNotNull);
//     expect(summaryT1.entries.length, 3);

//     expect(summaryT1[profile1.id], isNotNull);
//     expect(summaryT1[profile2.id], isNotNull);
//     expect(summaryT1[profile3.id], isNotNull);
    
//     //   A	B	C			    A	B	C			  A	B	C
//     // A	X	40	50		A	X	0	5		  A	X	0	0
//     // B	45	X	50		B	5	X	10		B	0	X	15
//     // C	45	40	X		C	0	0	X		  C	0	0	X

//     // Profile 1:
//     expect(summaryT1[profile1.id]!.paidAmountGroup, 170);
//     expect(summaryT1[profile1.id]!.paidAmountItself, 80);
//     expect(summaryT1[profile1.id]!.toReceiveNet, 0);
//     expect(summaryT1[profile1.id]!.toReceiveGross, 90);
//     expect(summaryT1[profile1.id]!.movements.length, 2);
//     expect(summaryT1[profile1.id]!.movements.first, isNotNull);
//     expect(summaryT1[profile1.id]!.movements.first.otherUserId, profile2.id);
//     expect(summaryT1[profile1.id]!.movements.first.amount, 40);
//     expect(summaryT1[profile1.id]!.movements.last, isNotNull);
//     expect(summaryT1[profile1.id]!.movements.last.otherUserId, profile3.id);
//     expect(summaryT1[profile1.id]!.movements.last.amount, 50);
//     expect(summaryT1[profile1.id]!.balanceMovements.length, 0);

//     // Profile 2:
//     expect(summaryT1[profile2.id]!.paidAmountGroup, 100);
//     expect(summaryT1[profile2.id]!.paidAmountItself, 20);
//     expect(summaryT1[profile2.id]!.toReceiveNet, -15.0);
//     expect(summaryT1[profile2.id]!.toReceiveGross, 80);    
//     expect(summaryT1[profile2.id]!.movements.length, 2);
//     expect(summaryT1[profile2.id]!.movements.first.otherUserId, profile1.id);
//     expect(summaryT1[profile2.id]!.movements.first.amount, 45);
//     expect(summaryT1[profile2.id]!.movements.last, isNotNull);
//     expect(summaryT1[profile2.id]!.movements.last.otherUserId, profile3.id);
//     expect(summaryT1[profile2.id]!.movements.last.amount, 50);
//     expect(summaryT1[profile2.id]!.balanceMovements.length, 1);
//     expect(summaryT1[profile2.id]!.balanceMovements.first, isNotNull);
//     expect(summaryT1[profile2.id]!.balanceMovements.first.otherUserId, profile3.id);
//     expect(summaryT1[profile2.id]!.balanceMovements.first.amount, 15);
    
//     // Profile 3:
//     expect(summaryT1[profile3.id]!.paidAmountGroup, 150);
//     expect(summaryT1[profile3.id]!.paidAmountItself, 50);
//     expect(summaryT1[profile3.id]!.toReceiveNet, 15);
//     expect(summaryT1[profile3.id]!.toReceiveGross, 100);
//     expect(summaryT1[profile3.id]!.movements.length, 2);
//     expect(summaryT1[profile3.id]!.movements.first.otherUserId, profile1.id);
//     expect(summaryT1[profile3.id]!.movements.first.amount, 45);
//     expect(summaryT1[profile3.id]!.movements.last, isNotNull);
//     expect(summaryT1[profile3.id]!.movements.last.otherUserId, profile2.id);
//     expect(summaryT1[profile3.id]!.movements.last.amount, 40);
//     expect(summaryT1[profile3.id]!.balanceMovements.length, 0);

//     // Prepara dati di test
//     final transactionsT2 = [
//       GroupTransactionModel(
//         id: 'e4',
//         groupId: 'g1',
//         profileModel: profile2,
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
//         id: 'e5',
//         groupId: 'g1',
//         profileModel: profile2,
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
//         id: 'e6',
//         groupId: 'g1',
//         profileModel: profile2,
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
//         profileModel: profile3,
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

//     final groupParticipantsT2 = [
//       GroupParticipantModel(userId: 'profile2', profile: profile2),
//       GroupParticipantModel(userId: 'profile3', profile: profile3),
//       GroupParticipantModel(userId: 'profile4', profile: profile4)
//     ];

//     final summaryT2 = GroupTransactionsUtil.computeParticipantsSummary(transactions: transactionsT2, participants: groupParticipantsT2);
    
//     // 	B	C	D			              B	C	D			            B	C	D
//     // B	X	50	0		          B	X	0	0		            B	X	0	0
//     // C	58.33333333	X	0		  C	8.333333333	X	0		  C	0	X	0
//     // D	58.33333333	50	X		D	58.33333333	50	X		D	66.66666667	41.66666667	X

//     expect(summaryT2, isNotNull);
//     expect(summaryT2.entries.length, 3);

//     expect(summaryT2[profile2.id], isNotNull);
//     expect(summaryT2[profile3.id], isNotNull);
//     expect(summaryT2[profile4.id], isNotNull);
    
//     // Profile 2:
//     expect(summaryT2[profile2.id]!.paidAmountGroup, 325);
//     expect(summaryT2[profile2.id]!.paidAmountItself, 208.33);
//     expect(summaryT2[profile2.id]!.toReceiveNet, 66.67);
//     expect(summaryT2[profile2.id]!.toReceiveGross, 116.67);
//     expect(summaryT2[profile2.id]!.movements.length, 1);
//     expect(summaryT2[profile2.id]!.movements.first, isNotNull);
//     expect(summaryT2[profile2.id]!.movements.first.otherUserId, profile3.id);
//     expect(summaryT2[profile2.id]!.movements.first.amount, 50.0);
//     expect(summaryT2[profile2.id]!.balanceMovements.length, 0);

//     // Profile 3:
//     expect(summaryT2[profile3.id]!.paidAmountGroup, 100);
//     expect(summaryT2[profile3.id]!.paidAmountItself, 0);
//     expect(summaryT2[profile3.id]!.toReceiveNet, 41.66);
//     expect(summaryT2[profile3.id]!.toReceiveGross, 100);
//     expect(summaryT2[profile3.id]!.movements.length, 1);
//     expect(summaryT2[profile3.id]!.movements.first, isNotNull);
//     expect(summaryT2[profile3.id]!.movements.first.otherUserId, profile2.id);
//     expect(summaryT2[profile3.id]!.movements.first.amount, 58.34);
//     expect(summaryT2[profile3.id]!.balanceMovements.length, 0);
    
//     // Profile 4:
//     expect(summaryT2[profile4.id]!.paidAmountGroup, 0);
//     expect(summaryT2[profile4.id]!.paidAmountItself, 0);
//     expect(summaryT2[profile4.id]!.toReceiveNet, -108.34);
//     expect(summaryT2[profile4.id]!.toReceiveGross, 0);    
//     expect(summaryT2[profile4.id]!.movements.length, 2);
//     expect(summaryT2[profile4.id]!.movements.first, isNotNull);
//     expect(summaryT2[profile4.id]!.movements.first.otherUserId, profile2.id);
//     expect(summaryT2[profile4.id]!.movements.first.amount, 58.34);
//     expect(summaryT2[profile4.id]!.movements.last, isNotNull);
//     expect(summaryT2[profile4.id]!.movements.last.otherUserId, profile3.id);
//     expect(summaryT2[profile4.id]!.movements.last.amount, 50.0);
//     expect(summaryT2[profile4.id]!.balanceMovements.length, 2);
//     expect(summaryT2[profile4.id]!.balanceMovements.first, isNotNull);
//     expect(summaryT2[profile4.id]!.balanceMovements.first.otherUserId, profile2.id);
//     expect(summaryT2[profile4.id]!.balanceMovements.first.amount, 66.67);
//     expect(summaryT2[profile4.id]!.balanceMovements.last, isNotNull);
//     expect(summaryT2[profile4.id]!.balanceMovements.last.otherUserId, profile3.id);
//     expect(summaryT2[profile4.id]!.balanceMovements.last.amount, 41.66);

//     final mergedSummary = GroupTransactionsUtil.mergeSummaries(summaryT1, summaryT2);
//     GroupTransactionsUtil.computeDynamicParticipantsSummary(summary: mergedSummary);

//     //   A	B	C	D                       	A	B	C	D
//     // A	X	0	0	0                       A	X	0	0	0
//     // B	0	X	15	0                     B	0	X	0	0
//     // C	0	0	X	0                       C	0	0	X	0
//     // D	0	66.66666667	41.66666667	X   D	0	51.66666667	56.66666667	X

//     expect(mergedSummary, isNotNull);
//     expect(mergedSummary.entries.length, 4);

//     expect(mergedSummary[profile1.id], isNotNull);
//     expect(mergedSummary[profile2.id], isNotNull);
//     expect(mergedSummary[profile3.id], isNotNull);
//     expect(mergedSummary[profile4.id], isNotNull);
    
//     // Profile 1:
//     expect(mergedSummary[profile1.id]!.paidAmountGroup, 170);
//     expect(mergedSummary[profile1.id]!.paidAmountItself, 80);
//     expect(mergedSummary[profile1.id]!.toReceiveNet, 0);
//     expect(mergedSummary[profile1.id]!.toReceiveGross, 90);
//     expect(mergedSummary[profile1.id]!.movements.length, 2);    
//     expect(mergedSummary[profile1.id]!.movements.first, isNotNull);
//     expect(mergedSummary[profile1.id]!.movements.first.otherUserId, profile2.id);
//     expect(mergedSummary[profile1.id]!.movements.first.amount, 40);
//     expect(mergedSummary[profile1.id]!.movements.last, isNotNull);
//     expect(mergedSummary[profile1.id]!.movements.last.otherUserId, profile3.id);
//     expect(mergedSummary[profile1.id]!.movements.last.amount, 50);
//     expect(mergedSummary[profile1.id]!.balanceMovements.length, 0);

//     // Profile 2:
//     expect(mergedSummary[profile2.id]!.paidAmountGroup, 425); 
//     expect(mergedSummary[profile2.id]!.paidAmountItself, 228.33); 
//     expect(mergedSummary[profile2.id]!.toReceiveNet, 51.67); 
//     expect(mergedSummary[profile2.id]!.toReceiveGross, 196.67); 
//     expect(mergedSummary[profile2.id]!.movements.length, 3);
//     expect(mergedSummary[profile2.id]!.movements.first.otherUserId, profile1.id);
//     expect(mergedSummary[profile2.id]!.movements.first.amount, 45);
//     expect(mergedSummary[profile2.id]!.movements[1], isNotNull);
//     expect(mergedSummary[profile2.id]!.movements[1].otherUserId, profile3.id);
//     expect(mergedSummary[profile2.id]!.movements[1].amount, 50);
//     expect(mergedSummary[profile2.id]!.movements.last, isNotNull);
//     expect(mergedSummary[profile2.id]!.movements.last.otherUserId, profile3.id);
//     expect(mergedSummary[profile2.id]!.movements.last.amount, 50.0);
//     expect(mergedSummary[profile2.id]!.balanceMovements.length, 0);

//     // Profile 3:
//     expect(mergedSummary[profile3.id]!.paidAmountGroup, 250);
//     expect(mergedSummary[profile3.id]!.paidAmountItself, 50);
//     expect(mergedSummary[profile3.id]!.toReceiveNet, 56.66);
//     expect(mergedSummary[profile3.id]!.toReceiveGross, 200);
//     expect(mergedSummary[profile3.id]!.movements.length, 3);
//     expect(mergedSummary[profile3.id]!.movements.first.otherUserId, profile1.id);
//     expect(mergedSummary[profile3.id]!.movements.first.amount, 45);
//     expect(mergedSummary[profile3.id]!.movements[1], isNotNull);
//     expect(mergedSummary[profile3.id]!.movements[1].otherUserId, profile2.id);
//     expect(mergedSummary[profile3.id]!.movements[1].amount, 40);
//     expect(mergedSummary[profile3.id]!.movements.last, isNotNull);
//     expect(mergedSummary[profile3.id]!.movements.last.otherUserId, profile2.id);
//     expect(mergedSummary[profile3.id]!.movements.last.amount, 58.34);
//     expect(mergedSummary[profile3.id]!.balanceMovements.length, 0);

//     // Profile 4:
//     expect(mergedSummary[profile4.id]!.paidAmountGroup, 0);
//     expect(mergedSummary[profile4.id]!.paidAmountItself, 0);
//     expect(mergedSummary[profile4.id]!.toReceiveNet, -108.34);
//     expect(mergedSummary[profile4.id]!.toReceiveGross, 0);    
//     expect(mergedSummary[profile4.id]!.movements.length, 2);
//     expect(mergedSummary[profile4.id]!.movements.first, isNotNull);
//     expect(mergedSummary[profile4.id]!.movements.first.otherUserId, profile2.id);
//     expect(mergedSummary[profile4.id]!.movements.first.amount, 58.34);
//     expect(mergedSummary[profile4.id]!.movements.last, isNotNull);
//     expect(mergedSummary[profile4.id]!.movements.last.otherUserId, profile3.id);
//     expect(mergedSummary[profile4.id]!.movements.last.amount, 50.0);
//     expect(mergedSummary[profile4.id]!.balanceMovements.length, 2);
//     expect(mergedSummary[profile4.id]!.balanceMovements.first, isNotNull);
//     expect(mergedSummary[profile4.id]!.balanceMovements.first.otherUserId, profile3.id);
//     expect(mergedSummary[profile4.id]!.balanceMovements.first.amount, 56.66);
//     expect(mergedSummary[profile4.id]!.balanceMovements.last, isNotNull);
//     expect(mergedSummary[profile4.id]!.balanceMovements.last.otherUserId, profile2.id);
//     expect(mergedSummary[profile4.id]!.balanceMovements.last.amount, 51.67);

//   });

// }