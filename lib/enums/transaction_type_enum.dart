// ignore_for_file: constant_identifier_names -- This is to allow enum values to be in uppercase, which is a common convention for enums in Dart.
enum TransactionTypeEnum { 
  EXPENSE("EXPENSE"), 
  INCOME("INCOME");

  final String value;
  const TransactionTypeEnum(this.value);
}

// TODO: testare il catch Exception
extension TransactionTypeEnumExtension on TransactionTypeEnum {
  static TransactionTypeEnum fromValue(String value) {
    final upperValue = value.toUpperCase();
    return TransactionTypeEnum.values.firstWhere((e) => 
      e.value == upperValue, 
      orElse: () => throw ArgumentError('Invalid TransactionTypeEnum value: $value')
    );
  }
}