import 'package:flutter_riverpod/flutter_riverpod.dart';

/* Note: Perché NON metterlo nel widget?
 * - viene ricreato ogni rebuild
 * - stato instabile
 * - difficile da riusare
 */
final tabProviderProve = NotifierProvider<TabNotifierProve, int>(
  TabNotifierProve.new,
);

class TabNotifierProve extends Notifier<int> {
  @override
  int build() {
    return 0;
  }

  void setTab(int tabIndex) {
    state = tabIndex;
  }
}
