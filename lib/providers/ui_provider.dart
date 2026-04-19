import 'package:flutter_riverpod/flutter_riverpod.dart';

/* Note: Perché NON metterlo nel widget?
 * - viene ricreato ogni rebuild
 * - stato instabile
 * - difficile da riusare
 */

// -------------------------------------------------------------------------------------------------------------------------
// Used to handle Tabs in Split Rate vs Paid Amount bottom sheet
final splitRateAndPaidAmountTabProvider = StateProvider<int>((ref) => 0);

// -------------------------------------------------------------------------------------------------------------------------
// Used to handle Transaction splitRate or FixedAmount in Split Rate vs Paid Amount bottom sheet
enum FilterSelection {
  // Tab: Split Rate
  oneQuarter('one quarter'),
  half('half'),
  threeQuarters('three quarters'),
  evenly('evenly'),
  zero('zero'),
  customPercentage('custom percentage'),
  fixed1('fixed1'),
  fixed2('fixed2'),
  fixed3('fixed3'),
  fixed4('fixed4'),
  customFixed('customFixed'),

  // Tab: Paid Amount
  fixedAmount('fixedAmount');

  final String value;
  const FilterSelection(this.value);
}
final filterProvider = StateProvider<FilterSelection?>((ref) => null);