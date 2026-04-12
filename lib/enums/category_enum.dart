// ignore_for_file: constant_identifier_names -- This is to allow enum values to be in uppercase, which is a common convention for enums in Dart.
enum CategoryEnum { 
  BILLS('BILLS'),
  CLOTHES('CLOTHES'),
  DONATIONS('DONATIONS'),
  EDUCATION('EDUCATION'),
  ENSURANCE('ENSURANCE'),
  ENTERTAINMENT('ENTERTAINMENT'),
  FOOD_AND_DRINK('FOOD_AND_DRINK'),
  GIFT('GIFT'),
  GROCERIES('GROCERIES'),
  HOME('HOME'),
  HEALTH('HEALTH'),
  INCOME('INCOME'),
  OTHER('OTHER'),
  PENSION('PENSION'),
  PHONE('PHONE'),
  SERVICES('SERVICES'),
  SHOPPING('SHOPPING'),
  SPORT('SPORT'),
  SUBSCRIPTION('SUBSCRIPTION'),
  TAXES('TAXES'),
  TRANSPORTATION('TRANSPORTATION'),
  TRAVEL('TRAVEL');

  final String value;  
  const CategoryEnum(this.value);
}
