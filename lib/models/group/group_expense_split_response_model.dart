import 'package:Billy/enums/split_rate_mode_enum.dart';

class GroupExpenseSplitResponseModel {
  final SplitRateModeEnum splitRateModeEnum;
  final int? customPercentage;
  final int? customFixedValue;
  final double? fixedAmount;
  final int tabSelectedIndex;

  GroupExpenseSplitResponseModel({
    required this.splitRateModeEnum,
    this.customPercentage,
    this.customFixedValue,
    this.fixedAmount,
    required this.tabSelectedIndex,
  });
}