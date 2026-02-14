class NumberUtil {

  static double roundToTwoDecimals({required double value, int precision = 2}) {
    return double.parse(value.toStringAsFixed(precision));
  }
}