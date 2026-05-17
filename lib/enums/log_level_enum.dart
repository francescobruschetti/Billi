// ignore_for_file: constant_identifier_names -- This is to allow enum values to be in uppercase, which is a common convention for enums in Dart.
enum LogLevelEnum { 
  ERROR('ERROR'),
  WARNING('WARNING'),
  INFO('INFO'),
  FINE('FINE'),
  FINER('FINER'),
  FINEST('FINEST');

  final String value;  
  const LogLevelEnum(this.value);
}
