// ignore_for_file: constant_identifier_names -- This is to allow enum values to be in uppercase, which is a common convention for enums in Dart.
enum GroupRoleEnum { 
  ADMIN('ADMIN'),
  CREATOR('CREATOR'),
  MEMBER('MEMBER');

  final String value;  
  const GroupRoleEnum(this.value);
}
