extension StringToDatetimeExtention on String {
   DateTime toDateTime() {
    try {
      return DateTime.parse(this);
    } 
    catch (e) {
      throw FormatException('Invalid date format: $this');
    }
  }
}

extension DatetimeToStringFormatExtention on DateTime {
  String toDateTimeStr() {
    return '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

   String toDateStr() {
    return '${day.toString().padLeft(2, '0')}/${month.toString().padLeft(2, '0')}/$year';
  }
}