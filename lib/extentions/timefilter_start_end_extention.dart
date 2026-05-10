import 'package:Billy/enums/time_filter_enum.dart';

extension TimefilterStartEndExtention on TimeFilterEnum {
   (DateTime, DateTime) get dateRange {
    final now = DateTime.now();
    
    return switch (this) { // TODO: da testare
      TimeFilterEnum.ONE_DAY => (DateTime(now.year, now.month, now.day), now),
      TimeFilterEnum.CURRENT_WEEK => (now.subtract(Duration(days: now.weekday - 1)), now),
      TimeFilterEnum.CURRENT_MONTH => (DateTime(now.year, now.month, 1), now),
      TimeFilterEnum.CURRENT_YEAR => (DateTime(now.year, 1, 1), now),
      
      TimeFilterEnum.ONE_WEEK => throw UnimplementedError(), // TODO: Handle this case.
      TimeFilterEnum.ONE_MONTH => throw UnimplementedError(), // TODO: Handle this case.
      TimeFilterEnum.ONE_YEAR => throw UnimplementedError(), // TODO: Handle this case.
      TimeFilterEnum.RANGE => throw UnimplementedError(), // TODO: Handle this case.
    };
  }
}