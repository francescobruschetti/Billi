class GroupTransactionSummaryBalanceMovementModel {
  final String userId; // Id of the user this movement is related to (the current user)
  final String otherUserId; // Id of the other participant involved in the movement
  final double amount; // Amount to pay or to receive
  final bool isToPay; // True if the movement is to pay, false if it's to receive

  GroupTransactionSummaryBalanceMovementModel({
    required this.userId,
    required this.otherUserId,
    required this.amount,
    required this.isToPay,
  });
}