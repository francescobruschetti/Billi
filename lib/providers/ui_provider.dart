import 'package:Billy/enums/split_rate_mode_enum.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/* Note: Perché NON metterlo nel widget?
 * - viene ricreato ogni rebuild
 * - stato instabile
 * - difficile da riusare
 */

// -------------------------------------------------------------------------------------------------------------------------
// Used to handle Tabs in Split Rate vs Paid Amount bottom sheet
final splitRateAndPaidAmountTabProvider = NotifierProvider<SplitRateAndPaidAmountTabNotifier, int>(
  SplitRateAndPaidAmountTabNotifier.new,
);

class SplitRateAndPaidAmountTabNotifier extends Notifier<int> {
  @override
  int build() {
    return 0;
  }

  void setTab(int tabIndex) {
    state = tabIndex;
  }
}

// -------------------------------------------------------------------------------------------------------------------------
// Used to handle Transaction splitRate or FixedAmount in Split Rate vs Paid Amount bottom sheet
final splitRateModeProvider = NotifierProvider<SplitRateModeNotifier, SplitRateModeEnum?>(
  SplitRateModeNotifier.new,
);

class SplitRateModeNotifier extends Notifier<SplitRateModeEnum?> {
  @override
  SplitRateModeEnum? build() {
    return null;
  }

  void setMode(SplitRateModeEnum? mode) {
    state = mode;
  }
}
