class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

class GroupException extends AppException {
  const GroupException(super.message);
}