class GroupSettlementProfileModel {
  final String id;
  final String username;
  final String name;

  GroupSettlementProfileModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        username = json['username'],
        name = json['name'];
}

class GroupSettlementProfileDetailsModel {
  final String id;
  final String groupId;
  final GroupSettlementProfileModel payer;
  final GroupSettlementProfileModel receiver;
  final double amount;
  final String? note;
  final DateTime settledAt;
  final DateTime createdAt;

  GroupSettlementProfileDetailsModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        groupId = json['group_id'],
        payer = GroupSettlementProfileModel.fromJson(json['payer']),
        receiver = GroupSettlementProfileModel.fromJson(json['receiver']),
        amount = (json['amount'] as num).toDouble(),
        note = json['note'],
        settledAt = DateTime.parse(json['settled_at']),
        createdAt = DateTime.parse(json['created_at']);
}

class GroupSettlementsTotalsModel {
  final double totalSettled;
  final int count;

  GroupSettlementsTotalsModel.fromJson(Map<String, dynamic> json)
      : totalSettled = (json['total_settled'] as num).toDouble(),
        count = json['count'];
}

class GroupSettlementsHistoryPageModel {
  final List<GroupSettlementProfileDetailsModel> settlements;
  final GroupSettlementsTotalsModel totals;

  GroupSettlementsHistoryPageModel()    
  : settlements = [], totals = GroupSettlementsTotalsModel.fromJson({'total_settled': 0, 'count': 0});
  
  GroupSettlementsHistoryPageModel.fromJson(Map<String, dynamic> json)
      : settlements = (json['settlements'] as List)
            .map((e) => GroupSettlementProfileDetailsModel.fromJson(e))
            .toList(),
        totals = GroupSettlementsTotalsModel.fromJson(json['totals']);
}