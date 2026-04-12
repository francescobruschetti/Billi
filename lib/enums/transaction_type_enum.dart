// ignore_for_file: constant_identifier_names -- This is to allow enum values to be in uppercase, which is a common convention for enums in Dart.
enum TransactionTypeEnum { 
  EXPENSE, INCOME;

  String toValue() {
    switch (this) {
      case TransactionTypeEnum.EXPENSE:
        return 'expense';
      case TransactionTypeEnum.INCOME:
        return 'income';
    }
  }
}

extension TransactionTypeEnumExtension on TransactionTypeEnum {
  static TransactionTypeEnum fromValue(String value) {
    final upperValue = value.toUpperCase();
    switch (upperValue) {
      case 'EXPENSE':
        return TransactionTypeEnum.EXPENSE;
      case 'INCOME':
        return TransactionTypeEnum.INCOME;
      default:
        return TransactionTypeEnum.EXPENSE;
    }
  }
}