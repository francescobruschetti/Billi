// ignore_for_file: constant_identifier_names -- This is to allow enum values to be in uppercase, which is a common convention for enums in Dart.
enum SplitRateModeEnum { 
  // TODO: ci sono tutti?
  ONE_QUARTER("ONE_QUARTER"), 
  THREE_QUARTERS("THREE_QUARTERS"),
  HALF("HALF"),

  ZERO("ZERO"), // Hai anticipato per gli altri (es. hai speso 100, ti devono rimborsare 100)
  EQUALLY("EQUALLY"),

  FIXED_1("FIXED_1"), // Paga 1 quota fissa (es. hai speso 100 ed eravate 5, paghi: 100/5 = 20)
  FIXED_2("FIXED_2"), // Paga 2 quote fisse (es. hai speso 100 ed eravate 5, paghi: 100/5 * 2 = 40)
  FIXED_3("FIXED_3"), // Paga 3 quote fisse (es. hai speso 100 ed eravate 5, paghi: 100/5 * 3 = 60)
  FIXED_4("FIXED_4"), // Paga 4 quote fisse (es. hai speso 100 ed eravate 5, paghi: 100/5 * 4 = 80)
  
  CUSTOM("CUSTOM");
  
  final String value;  
  const SplitRateModeEnum(this.value);
}

// TODO: testare il catch Exception
extension SplitRateModeEnumExtension on SplitRateModeEnum {
  static SplitRateModeEnum fromValue(String value) {
    final upperValue = value.toUpperCase();
    return SplitRateModeEnum.values.firstWhere((e) => 
      e.value == upperValue, 
      orElse: () => throw ArgumentError('Invalid SplitRateModeEnum value: $value')
    );
  }
}

