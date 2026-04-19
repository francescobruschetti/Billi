import 'package:flutter_riverpod/flutter_riverpod.dart';

/* Note: Perché NON metterlo nel widget?
 * - viene ricreato ogni rebuild
 * - stato instabile
 * - difficile da riusare
 */
final tabProviderProve = StateProvider<int>((ref) => 0);