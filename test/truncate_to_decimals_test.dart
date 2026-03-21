
import 'package:Billy/utils/number_util.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('truncateToDecimals test: 1.23456789 with precision 2', () {
    double truncatedValue = NumberUtil.truncateToDecimals(value: 1.23456789, precision: 2);
    expect(truncatedValue, 1.23);
  });
  
  test('truncateToDecimals test: 1.98765432 with precision 3', () {
    double truncatedValue = NumberUtil.truncateToDecimals(value: 1.98765432, precision: 3);
    expect(truncatedValue, 1.987);
  });
  
  test('truncateToDecimals test: 1 with precision 3', () {
    double truncatedValue = NumberUtil.truncateToDecimals(value: 1, precision: 3);
    expect(truncatedValue, 1);
  });
  
  test('truncateToDecimals test: 1.3333 with precision 3', () {
    double truncatedValue = NumberUtil.truncateToDecimals(value: 1.3333, precision: 3);
    expect(truncatedValue, 1.333);
  });
  
  test('truncateToDecimals test: 1.6666 with precision 3', () {
    double truncatedValue = NumberUtil.truncateToDecimals(value: 1.6666, precision: 3);
    expect(truncatedValue, 1.666);
  });
  

}