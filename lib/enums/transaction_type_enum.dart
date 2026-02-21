// ignore: constant_identifier_names
enum TransactionTypeEnum { EXPENSE, INCOME }

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