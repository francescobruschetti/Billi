class ApiResponseModel<T> {
  final bool success;
  final String? message;
  final T data;

  ApiResponseModel({
    required this.success,
    this.message,
    required this.data,
  });

  factory ApiResponseModel.fromMap(Map<String, dynamic> map) {
    return ApiResponseModel(
      success: map['success'],
      message: map['message'],
      data: map['data'],
    );
  }
}