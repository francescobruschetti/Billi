import 'dart:math';

import 'package:Billy/models/category_model.dart';
import 'package:Billy/models/group_expense_model.dart';
import 'package:Billy/models/group_participant_model.dart';
import 'package:Billy/models/merchant_model.dart';
import 'package:Billy/models/profile_model.dart';
import 'package:Billy/utils/group_expenses_util.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('computeParticipantsSummary test 0', () {
    // Crea un'istanza della classe (se serve)
    final profile1 = ProfileModel(id: 'profile1', name: 'profile1', username: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now());
    final profile2 = ProfileModel(id: 'profile2', name: 'profile2', username: 'profile2', createdAt: DateTime.now(), updatedAt: DateTime.now());
    final profile3 = ProfileModel(id: 'profile3', name: 'profile3', username: 'profile3', createdAt: DateTime.now(), updatedAt: DateTime.now());

    // Prepara dati di esempio
    final expenses = [
      GroupExpenseModel(
        id: 'e1',
        groupId: 'g1',
        profileModel: profile1,
        merchant: MerchantModel(id: 'merchant1', name: 'merchant1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
        category: CategoryModel(id: 'category1', name: 'category1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
        paidAmount: 50,
        totalAmount: 100,
        splitRate: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      GroupExpenseModel(
        id: 'e2',
        groupId: 'g1',
        profileModel: profile1,
        merchant: MerchantModel(id: 'merchant1', name: 'merchant1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
        category: CategoryModel(id: 'category1', name: 'category1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
        paidAmount: 20,
        totalAmount: 100,
        splitRate: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    final groupParticipants = [
      GroupParticipantModel(userId: 'profile1', profile: profile1),
      GroupParticipantModel(userId: 'profile2', profile: profile2),
      GroupParticipantModel(userId: 'profile3', profile: profile3)
    ];

    final summary = GroupExpensesUtil.computeParticipantsSummary(expenses: expenses, groupParticipants: groupParticipants);
    
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
    expect(summary[profile1.id]!.movements.length, 2);
    expect(summary[profile1.id]!.balanceMovements.length, 0);

    // Profile 2:
    expect(summary[profile2.id]!.paidAmountGroup, 0);
    expect(summary[profile2.id]!.paidAmountItself, 0);
    expect(summary[profile2.id]!.toReceiveNet, -65.0);
    expect(summary[profile2.id]!.toReceiveGross, 0);    
    expect(summary[profile2.id]!.movements.length, 2);
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
    expect(summary[profile3.id]!.movements.length, 2);
    expect(summary[profile3.id]!.balanceMovements.length, 1);
    expect(summary[profile3.id]!.balanceMovements.first, isNotNull);
    expect(summary[profile3.id]!.balanceMovements.last, isNotNull);
    expect(summary[profile3.id]!.balanceMovements.first.otherUserId, profile1.id);
    expect(summary[profile3.id]!.balanceMovements.first.amount, 65.0);
  });


  test('computeParticipantsSummary test 1', () {
    // Crea un'istanza della classe (se serve)
    final profile1 = ProfileModel(id: 'profile1', name: 'profile1', username: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now());
    final profile2 = ProfileModel(id: 'profile2', name: 'profile2', username: 'profile2', createdAt: DateTime.now(), updatedAt: DateTime.now());
    final profile3 = ProfileModel(id: 'profile3', name: 'profile3', username: 'profile3', createdAt: DateTime.now(), updatedAt: DateTime.now());

    // Prepara dati di esempio
    final expenses = [
      GroupExpenseModel(
        id: 'e1',
        groupId: 'g1',
        profileModel: profile1,
        merchant: MerchantModel(id: 'merchant1', name: 'merchant1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
        category: CategoryModel(id: 'category1', name: 'category1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
        paidAmount: 40,
        totalAmount: 70,
        splitRate: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      GroupExpenseModel(
        id: 'e2',
        groupId: 'g1',
        profileModel: profile1,
        merchant: MerchantModel(id: 'merchant1', name: 'merchant1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
        category: CategoryModel(id: 'category1', name: 'category1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
        paidAmount: 40,
        totalAmount: 100,
        splitRate: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      GroupExpenseModel(
        id: 'e3',
        groupId: 'g1',
        profileModel: profile2,
        merchant: MerchantModel(id: 'merchant1', name: 'merchant1', userId: 'profile2', createdAt: DateTime.now(), updatedAt: DateTime.now()),
        category: CategoryModel(id: 'category1', name: 'category1', userId: 'profile2', createdAt: DateTime.now(), updatedAt: DateTime.now()),
        paidAmount: 20,
        totalAmount: 100,
        splitRate: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    final groupParticipants = [
      GroupParticipantModel(userId: 'profile1', profile: profile1),
      GroupParticipantModel(userId: 'profile2', profile: profile2),
      GroupParticipantModel(userId: 'profile3', profile: profile3)
    ];

    final summary = GroupExpensesUtil.computeParticipantsSummary(expenses: expenses, groupParticipants: groupParticipants);
    
    expect(summary, isNotNull);
    expect(summary.entries.length, 3);

    expect(summary[profile1.id], isNotNull);
    expect(summary[profile2.id], isNotNull);
    expect(summary[profile3.id], isNotNull);
    
    // Profile 1:
    expect(summary[profile1.id]!.paidAmountGroup, 170);
    expect(summary[profile1.id]!.paidAmountItself, 80);
    expect(summary[profile1.id]!.toReceiveNet, 50);
    expect(summary[profile1.id]!.toReceiveGross, 90);
    expect(summary[profile1.id]!.movements.length, 2);
    expect(summary[profile1.id]!.balanceMovements.length, 0);

    // Profile 2:
    expect(summary[profile2.id]!.paidAmountGroup, 100);
    expect(summary[profile2.id]!.paidAmountItself, 20);
    expect(summary[profile2.id]!.toReceiveNet, 35);
    expect(summary[profile2.id]!.toReceiveGross, 80);    
    expect(summary[profile2.id]!.movements.length, 2);
    expect(summary[profile2.id]!.balanceMovements.length, 0);
    
    // Profile 3:
    expect(summary[profile3.id]!.paidAmountGroup, 0);
    expect(summary[profile3.id]!.paidAmountItself, 0);
    expect(summary[profile3.id]!.toReceiveNet, -85);
    expect(summary[profile3.id]!.toReceiveGross, 0);
    expect(summary[profile3.id]!.movements.length, 2);
    expect(summary[profile3.id]!.balanceMovements.length, 2);
    expect(summary[profile3.id]!.balanceMovements.first, isNotNull);
    expect(summary[profile3.id]!.balanceMovements.last, isNotNull);
    expect(summary[profile3.id]!.balanceMovements.first.otherUserId, profile1.id);
    expect(summary[profile3.id]!.balanceMovements.first.amount, 50);
    expect(summary[profile3.id]!.balanceMovements.last.otherUserId, profile2.id);
    expect(summary[profile3.id]!.balanceMovements.last.amount, 35);
  });

  test('computeParticipantsSummary test 2', () {
    // Crea un'istanza della classe (se serve)
    final profile1 = ProfileModel(id: 'profile1', name: 'profile1', username: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now());
    final profile2 = ProfileModel(id: 'profile2', name: 'profile2', username: 'profile2', createdAt: DateTime.now(), updatedAt: DateTime.now());
    final profile3 = ProfileModel(id: 'profile3', name: 'profile3', username: 'profile3', createdAt: DateTime.now(), updatedAt: DateTime.now());

    // Prepara dati di esempio
    final expenses = [
      GroupExpenseModel(
        id: 'e1',
        groupId: 'g1',
        profileModel: profile1,
        merchant: MerchantModel(id: 'merchant1', name: 'merchant1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
        category: CategoryModel(id: 'category1', name: 'category1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
        paidAmount: 40,
        totalAmount: 70,
        splitRate: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      GroupExpenseModel(
        id: 'e2',
        groupId: 'g1',
        profileModel: profile1,
        merchant: MerchantModel(id: 'merchant1', name: 'merchant1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
        category: CategoryModel(id: 'category1', name: 'category1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
        paidAmount: 40,
        totalAmount: 100,
        splitRate: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      GroupExpenseModel(
        id: 'e3',
        groupId: 'g1',
        profileModel: profile2,
        merchant: MerchantModel(id: 'merchant1', name: 'merchant1', userId: 'profile2', createdAt: DateTime.now(), updatedAt: DateTime.now()),
        category: CategoryModel(id: 'category1', name: 'category1', userId: 'profile2', createdAt: DateTime.now(), updatedAt: DateTime.now()),
        paidAmount: 20,
        totalAmount: 100,
        splitRate: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      GroupExpenseModel(
        id: 'e4',
        groupId: 'g1',
        profileModel: profile3,
        merchant: MerchantModel(id: 'merchant1', name: 'merchant1', userId: 'profile3', createdAt: DateTime.now(), updatedAt: DateTime.now()),
        category: CategoryModel(id: 'category1', name: 'category1', userId: 'profile3', createdAt: DateTime.now(), updatedAt: DateTime.now()),
        paidAmount: 50,
        totalAmount: 50,
        splitRate: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    final groupParticipants = [
      GroupParticipantModel(userId: 'profile1', profile: profile1),
      GroupParticipantModel(userId: 'profile2', profile: profile2),
      GroupParticipantModel(userId: 'profile3', profile: profile3)
    ];

    final summary = GroupExpensesUtil.computeParticipantsSummary(expenses: expenses, groupParticipants: groupParticipants);
    
    expect(summary, isNotNull);
    expect(summary.entries.length, 3);

    expect(summary[profile1.id], isNotNull);
    expect(summary[profile2.id], isNotNull);
    expect(summary[profile3.id], isNotNull);
    
    // Profile 1:
    expect(summary[profile1.id]!.paidAmountGroup, 170);
    expect(summary[profile1.id]!.paidAmountItself, 80);
    expect(summary[profile1.id]!.toReceiveNet, 50);
    expect(summary[profile1.id]!.toReceiveGross, 90);
    expect(summary[profile1.id]!.movements.length, 2);
    expect(summary[profile1.id]!.balanceMovements.length, 0);

    // Profile 2:
    expect(summary[profile2.id]!.paidAmountGroup, 100);
    expect(summary[profile2.id]!.paidAmountItself, 20);
    expect(summary[profile2.id]!.toReceiveNet, 35);
    expect(summary[profile2.id]!.toReceiveGross, 80);    
    expect(summary[profile2.id]!.movements.length, 2);
    expect(summary[profile2.id]!.balanceMovements.length, 0);
    
    // Profile 3:
    expect(summary[profile3.id]!.paidAmountGroup, 50);
    expect(summary[profile3.id]!.paidAmountItself, 50);
    expect(summary[profile3.id]!.toReceiveNet, -85);
    expect(summary[profile3.id]!.toReceiveGross, 0);
    expect(summary[profile3.id]!.movements.length, 2);
    expect(summary[profile3.id]!.balanceMovements.length, 2);
    expect(summary[profile3.id]!.balanceMovements.first, isNotNull);
    expect(summary[profile3.id]!.balanceMovements.last, isNotNull);
    expect(summary[profile3.id]!.balanceMovements.first.otherUserId, profile1.id);
    expect(summary[profile3.id]!.balanceMovements.first.amount, 50);
    expect(summary[profile3.id]!.balanceMovements.last.otherUserId, profile2.id);
    expect(summary[profile3.id]!.balanceMovements.last.amount, 35);
  });

  test('computeParticipantsSummary test 3', () {
    // Crea un'istanza della classe (se serve)
    final profile1 = ProfileModel(id: 'profile1', name: 'profile1', username: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now());
    final profile2 = ProfileModel(id: 'profile2', name: 'profile2', username: 'profile2', createdAt: DateTime.now(), updatedAt: DateTime.now());
    final profile3 = ProfileModel(id: 'profile3', name: 'profile3', username: 'profile3', createdAt: DateTime.now(), updatedAt: DateTime.now());
    final profile4 = ProfileModel(id: 'profile4', name: 'profile4', username: 'profile4', createdAt: DateTime.now(), updatedAt: DateTime.now());

    // Prepara dati di esempio
    final expenses = [
      GroupExpenseModel(
        id: 'e1',
        groupId: 'g1',
        profileModel: profile1,
        merchant: MerchantModel(id: 'merchant1', name: 'merchant1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
        category: CategoryModel(id: 'category1', name: 'category1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
        paidAmount: 40,
        totalAmount: 70,
        splitRate: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      GroupExpenseModel(
        id: 'e2',
        groupId: 'g1',
        profileModel: profile1,
        merchant: MerchantModel(id: 'merchant1', name: 'merchant1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
        category: CategoryModel(id: 'category1', name: 'category1', userId: 'profile1', createdAt: DateTime.now(), updatedAt: DateTime.now()),
        paidAmount: 40,
        totalAmount: 100,
        splitRate: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      GroupExpenseModel(
        id: 'e3',
        groupId: 'g1',
        profileModel: profile2,
        merchant: MerchantModel(id: 'merchant1', name: 'merchant1', userId: 'profile2', createdAt: DateTime.now(), updatedAt: DateTime.now()),
        category: CategoryModel(id: 'category1', name: 'category1', userId: 'profile2', createdAt: DateTime.now(), updatedAt: DateTime.now()),
        paidAmount: 20,
        totalAmount: 100,
        splitRate: null,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      GroupExpenseModel(
          id: 'e4',
          groupId: 'g1',
          profileModel: profile3,
          merchant: MerchantModel(id: 'merchant1', name: 'merchant1', userId: 'profile3', createdAt: DateTime.now(), updatedAt: DateTime.now()),
          category: CategoryModel(id: 'category1', name: 'category1', userId: 'profile3', createdAt: DateTime.now(), updatedAt: DateTime.now()),
          paidAmount: 0,
          totalAmount: 20,
          splitRate: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      GroupExpenseModel(
          id: 'e5',
          groupId: 'g1',
          profileModel: profile3,
          merchant: MerchantModel(id: 'merchant1', name: 'merchant1', userId: 'profile3', createdAt: DateTime.now(), updatedAt: DateTime.now()),
          category: CategoryModel(id: 'category1', name: 'category1', userId: 'profile3', createdAt: DateTime.now(), updatedAt: DateTime.now()),
          paidAmount: 20,
          totalAmount: 180,
          splitRate: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      GroupExpenseModel(
          id: 'e6',
          groupId: 'g1',
          profileModel: profile4,
          merchant: MerchantModel(id: 'merchant1', name: 'merchant1', userId: 'profile4', createdAt: DateTime.now(), updatedAt: DateTime.now()),
          category: CategoryModel(id: 'category1', name: 'category1', userId: 'profile4', createdAt: DateTime.now(), updatedAt: DateTime.now()),
          paidAmount: 50,
          totalAmount: 200,
          splitRate: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

    final groupParticipants = [
      GroupParticipantModel(userId: 'profile1', profile: profile1),
      GroupParticipantModel(userId: 'profile2', profile: profile2),
      GroupParticipantModel(userId: 'profile3', profile: profile3),
      GroupParticipantModel(userId: 'profile4', profile: profile4)
    ];

    final summary = GroupExpensesUtil.computeParticipantsSummary(expenses: expenses, groupParticipants: groupParticipants);
    
    expect(summary, isNotNull);
    expect(summary.entries.length, 4);

    expect(summary[profile1.id], isNotNull);
    expect(summary[profile2.id], isNotNull);
    expect(summary[profile3.id], isNotNull);
    expect(summary[profile4.id], isNotNull);
    
    // Profile 1:
    expect(summary[profile1.id]!.paidAmountGroup, 170);
    expect(summary[profile1.id]!.paidAmountItself, 80);
    expect(summary[profile1.id]!.toReceiveNet, -46.67);
    expect(summary[profile1.id]!.toReceiveGross, 90);
    expect(summary[profile1.id]!.movements.length, 3);
    expect(summary[profile1.id]!.balanceMovements.length, 0);

    // Profile 2:
    expect(summary[profile2.id]!.paidAmountGroup, 100);
    expect(summary[profile2.id]!.paidAmountItself, 20);
    expect(summary[profile2.id]!.toReceiveNet, -60);
    expect(summary[profile2.id]!.toReceiveGross, 80);    
    expect(summary[profile2.id]!.movements.length, 3);
    expect(summary[profile2.id]!.balanceMovements.length, 0);

    // Profile 3:
    expect(summary[profile3.id]!.paidAmountGroup, 200);
    expect(summary[profile3.id]!.paidAmountItself, 20);
    expect(summary[profile3.id]!.toReceiveNet, 73.33);
    expect(summary[profile3.id]!.toReceiveGross, 180);    
    expect(summary[profile3.id]!.movements.length, 3);
    expect(summary[profile3.id]!.balanceMovements.length, 0);
    
    // Profile 4:
    expect(summary[profile4.id]!.paidAmountGroup, 200);
    expect(summary[profile4.id]!.paidAmountItself, 50);
    expect(summary[profile4.id]!.toReceiveNet, 33.33);
    expect(summary[profile4.id]!.toReceiveGross, 150);
    expect(summary[profile4.id]!.movements.length, 3);
    expect(summary[profile4.id]!.balanceMovements.length, 2);
    expect(summary[profile4.id]!.balanceMovements.first, isNotNull);
    expect(summary[profile4.id]!.balanceMovements.last, isNotNull);
    expect(summary[profile3.id]!.balanceMovements.first.otherUserId, profile1.id);
    expect(summary[profile3.id]!.balanceMovements.first.amount, 50);
    expect(summary[profile3.id]!.balanceMovements.last.otherUserId, profile2.id);
    expect(summary[profile3.id]!.balanceMovements.last.amount, 35);
  });
  

}