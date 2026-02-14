import 'package:logging/logging.dart';
import 'package:flutter/foundation.dart';

final Logger log = Logger('Billy');

void setupLogging({Level? overrideLevel}) {
  Logger.root.level = overrideLevel ?? 
    (kReleaseMode 
      ? Level.WARNING // in prod solo warning/error
      : Level.FINE // Use ALL to see all logs // In debug/test: tutti i log
    );

  Logger.root.onRecord.listen((record) {
    // In produzione puoi inviare i log a un servizio esterno (Sentry, Crashlytics, ecc.)

    // Print to console
    print('[${record.level.name}] ${record.time}: ${record.loggerName}: ${record.message}');
  });
}
