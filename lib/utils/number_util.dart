import 'dart:math';

class NumberUtil {

  static double roundToDecimals({required double value, int precision = 2}) {
    return double.parse(value.toStringAsFixed(precision));
  }

  static double truncateToDecimals({required double value, int precision = 2}) {
    final factor = pow(10, precision);
    return (value * factor).truncate() / factor;
  }
}