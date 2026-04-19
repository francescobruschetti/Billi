import 'package:Billy/providers/ui_provider.dart';

class GroupExpenseSplitResponseModel {
  final FilterSelection? filterSelected;
  final int? customPercentage;
  final int? customFixedValue;
  final double? fixedAmount;

  GroupExpenseSplitResponseModel({
    this.filterSelected,
    this.customPercentage,
    this.customFixedValue,
    this.fixedAmount,
  });
}