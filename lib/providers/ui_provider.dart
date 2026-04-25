import 'package:Billy/enums/split_rate_mode_enum.dart';
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
final splitRateModeProvider = StateProvider<SplitRateModeEnum?>((ref) => null);