// ignore_for_file: constant_identifier_names -- This is to allow enum values to be in uppercase, which is a common convention for enums in Dart.
enum TransactionInsertModeEnum { 
  FIX_PAID("FIX_PAID"), 
  SPLIT_RATE("SPLIT_RATE"), 
  INCOME("INCOME");

  final String value;
  const TransactionInsertModeEnum(this.value);
}
