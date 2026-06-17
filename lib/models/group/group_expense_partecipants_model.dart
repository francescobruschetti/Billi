class GroupExpenseParticipantModel {
  final String groupId;
  final String transactionId;
  final String userId;
  final bool hasPaid;
  final DateTime createdAt;
  final DateTime updatedAt;

  GroupExpenseParticipantModel({
    required this.groupId,
    required this.transactionId,
    required this.userId,
    required this.hasPaid,
    required this.createdAt,
    required this.updatedAt,
  });

  factory GroupExpenseParticipantModel.fromMap(Map<String, dynamic> map) {
    return GroupExpenseParticipantModel(
      groupId: map['group_id'],
      transactionId: map['transaction_id'],
      userId: map['user_id'],
      hasPaid: map['has_paid'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}