// ignore_for_file: constant_identifier_names -- This is to allow enum values to be in uppercase, which is a common convention for enums in Dart.
enum TimeFilterEnum { 
  ONE_DAY("ONE_DAY", "1g"), 
  ONE_WEEK("ONE_WEEK", "1s"), 
  ONE_MONTH("ONE_MONTH", "1m"), 
  ONE_YEAR("ONE_YEAR", "1a"), 
  CURRENT_WEEK("CURRENT_WEEK", "c_W"), 
  CURRENT_MONTH("CURRENT_MONTH", "c_M"), 
  CURRENT_YEAR("CURRENT_YEAR", "c_Y"), 
  RANGE("RANGE", "range");

  final String value;  
  final String shortValue;
  const TimeFilterEnum(this.value, this.shortValue);
}
