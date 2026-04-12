// ignore_for_file: constant_identifier_names -- This is to allow enum values to be in uppercase, which is a common convention for enums in Dart.
enum TimeFilterEnum { 
  ONE_DAY("1g"), 
  ONE_WEEK("1s"), 
  ONE_MONTH("1m"), 
  ONE_YEAR("1a"), 
  CURRENT_WEEK("cs"), 
  CURRENT_MONTH("cm"), 
  CURRENT_YEAR("ca"), 
  RANGE("i");

  final String value;  
  const TimeFilterEnum(this.value);
}
