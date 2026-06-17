// ignore_for_file: constant_identifier_names -- This is to allow enum values to be in uppercase, which is a common convention for enums in Dart.
enum SplitRateModeEnum { 
  // Tab: Split Rate
  ONE_QUARTER('ONE_QUARTER'),
  HALF('HALF'),
  THREE_QUARTERS('THREE_QUARTERS'),
  EVENLY('EVENLY'),
  ZERO('ZERO'), // Hai anticipato tu e ti devono rimborsare il 100%
  CUSTOM_PERCENTAGE('CUSTOM_PERCENTAGE'),
  
  FIXED_1('FIXED_1'), // Paga 1 quota fissa (es. hai speso 100 ed eravate 5, paghi: 100/5 = 20)
  FIXED_2('FIXED_2'), // Paga 2 quote fisse (es. hai speso 100 ed eravate 5, paghi: 100/5 * 2 = 40)
  FIXED_3('FIXED_3'), 
  FIXED_4('FIXED_4'),
  CUSTOM_FIXED('CUSTOM_FIXED'),

  // Tab: Paid Amount
  FIXED_AMOUNT('FIXED_AMOUNT');
  
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

