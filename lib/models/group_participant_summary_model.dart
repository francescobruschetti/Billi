import 'package:Billy/models/profile_model.dart';

class GroupParticipantSummaryModel {
  final String userId;
  final ProfileModel profile;
  double paidAmountGroup; // Physically spent by the participant
  double paidAmountItself; // Physically spent for itself
  double toReceive; // Amount that participant shall receive from others
  double toPay; // Amount that participant shall pay to others
  double expectedToPay; // FOR FUTURE USE: Amount that participant should pay based on how much it contributed to the expenses

  GroupParticipantSummaryModel({
    required this.userId,
    required this.profile,
    required this.paidAmountGroup,
    required this.paidAmountItself,
    required this.toPay,
    required this.toReceive,
    required this.expectedToPay,
  });
  
  GroupParticipantSummaryModel.basic({
    required this.userId,
    required this.profile
  }) : 
    paidAmountGroup = 0.0,
    paidAmountItself = 0.0,
    toPay = 0.0,
    toReceive = 0.0,
    expectedToPay = 0.0;

  // --- Setters
  set updatePaidAmountGroup(double amount) {
    paidAmountGroup = amount;
  }

  set updatePaidAmountItself(double amount) {
    paidAmountItself = amount;
  }

  set updateToPay(double amount) {
    toPay = amount;
  }

  set updateToReceive(double amount) {
    toReceive = amount;
  }

  set updateExpectedToPay(double amount) {
    expectedToPay = amount;
  }

  // --- Methods to increment values
  void increasePaidAmountGroup(double amount) {
    paidAmountGroup += amount;
  }

  void increasePaidAmountItself(double amount) {
    paidAmountItself += amount;
  }

  void increaseToPay(double amount) {
    toPay += amount;
  }

  void increaseToReceive(double amount) {
    toReceive += amount;
  }
  
  void increaseExpectedToPay(double amount) {
    expectedToPay += amount;
  }
}