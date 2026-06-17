import 'package:Billy/models/group/group_participant_summary_balance_model.dart';
import 'package:Billy/models/group/group_participant_summary_movement_model.dart';
import 'package:Billy/models/profile_model.dart';
import 'package:Billy/utils/number_util.dart';

class GroupParticipantSummaryModel {
  final String userId;
  final ProfileModel profile;
  double paidAmountGroup; // Physically spent by the participant
  double paidAmountItself; // Physically spent for itself
  double toReceiveNet; // Net Amount that participant shall pay to others
  double toReceiveGross; // Gross Amount that participant shall receive from others
  double expectedtoReceiveNet; // FOR FUTURE USE: Amount that participant should pay based on how much it contributed to the transactions
  List<GroupTransactionSummaryMovementModel> movementModels = []; // List of all movements this user has to execute to balance the transactions (to pay other participants)
  List<GroupTransactionSummaryBalanceModel> balanceModels = []; // List of all movements this user has to execute to balance the transactions (to receive from other participants)

  GroupParticipantSummaryModel({
    required this.userId,
    required this.profile,
    required this.paidAmountGroup, 
    required this.paidAmountItself,
    required this.toReceiveNet,
    required this.toReceiveGross,
    required this.expectedtoReceiveNet,
    required this.movementModels,
    required this.balanceModels,
  });
  
  GroupParticipantSummaryModel.basic({
    required this.userId,
    required this.profile,
  }) : 
    paidAmountGroup = 0.0,
    paidAmountItself = 0.0,
    toReceiveNet = 0.0,
    toReceiveGross = 0.0,
    expectedtoReceiveNet = 0.0,
    movementModels = [],
    balanceModels = [];

  GroupParticipantSummaryModel duplicate() {
    return GroupParticipantSummaryModel(
      userId: userId,
      profile: profile,
      paidAmountGroup: paidAmountGroup,
      paidAmountItself: paidAmountItself,
      toReceiveNet: toReceiveNet,
      toReceiveGross: toReceiveGross,
      expectedtoReceiveNet: expectedtoReceiveNet,
      movementModels: List<GroupTransactionSummaryMovementModel>.from(movementModels),
      balanceModels: List<GroupTransactionSummaryBalanceModel>.from(balanceModels)
    );
  }

  // --- Setters
  set updatePaidAmountGroup(double amount) {
    paidAmountGroup = amount;
  }

  set updatePaidAmountItself(double amount) {
    paidAmountItself = amount;
  }

  set updatetoReceiveNet(double amount) {
    toReceiveNet = amount;
  }

  set updatetoReceiveGross(double amount) {
    toReceiveGross = amount;
  }

  set updateExpectedtoReceiveNet(double amount) {
    expectedtoReceiveNet = amount;
  }

  // --- Methods to increment values
  void increasePaidAmountGroup(double amount) {
    paidAmountGroup = NumberUtil.roundToDecimals(value: paidAmountGroup + amount);
  }

  void increasePaidAmountItself(double amount) {
    paidAmountItself = NumberUtil.roundToDecimals(value: paidAmountItself + amount);
  }

  void increasetoReceiveNet(double amount) {
    toReceiveNet = NumberUtil.roundToDecimals(value: toReceiveNet + amount);
  }

  void increasetoReceiveGross(double amount) {
    toReceiveGross = NumberUtil.roundToDecimals(value: toReceiveGross + amount);
  }

  void increaseExpectedtoReceiveNet(double amount) {
    expectedtoReceiveNet = NumberUtil.roundToDecimals(value: expectedtoReceiveNet + amount);
  }

  GroupParticipantSummaryModel copyWith({
    List<GroupTransactionSummaryBalanceModel>? balanceModels,
  }) {
    return GroupParticipantSummaryModel(
      userId: userId,
      profile: profile,
      paidAmountGroup: paidAmountGroup,
      paidAmountItself: paidAmountItself,
      toReceiveNet: toReceiveNet,
      toReceiveGross: toReceiveGross,
      expectedtoReceiveNet: expectedtoReceiveNet,
      movementModels: movementModels,
      balanceModels: balanceModels ?? this.balanceModels,
    );
  }

  GroupParticipantSummaryModel merge(GroupParticipantSummaryModel value) {
    return GroupParticipantSummaryModel(
      userId: userId,
      profile: profile,
      paidAmountGroup: NumberUtil.roundToDecimals(value: paidAmountGroup + value.paidAmountGroup),
      paidAmountItself: NumberUtil.roundToDecimals(value: paidAmountItself + value.paidAmountItself),
      toReceiveNet: NumberUtil.roundToDecimals(value: toReceiveNet + value.toReceiveNet),
      toReceiveGross: NumberUtil.roundToDecimals(value: toReceiveGross + value.toReceiveGross),
      expectedtoReceiveNet: NumberUtil.roundToDecimals(value: expectedtoReceiveNet + value.expectedtoReceiveNet),
      movementModels: [...movementModels, ...value.movementModels],
      balanceModels: [],
    );
  }
}