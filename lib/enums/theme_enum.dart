// ignore_for_file: constant_identifier_names -- This is to allow enum values to be in uppercase, which is a common convention for enums in Dart.
enum ThemeEnum { 
  DARK("DARK"), 
  LIGHT("LIGHT"), 
  SYSTEM("SYSTEM");

  final String value;  
  const ThemeEnum(this.value);
}
