class Responses {
  final bool success;
  final String message;
  var data;

  Responses({
    required this.success,
    required this.message,
    required this.data,
  });

  factory Responses.fromJson(Map<String, dynamic> json) {
    return Responses(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] ?? {},
    );
  }

  @override
  String toString() {
    return 'Response{success: $success, message: $message, data: $data}';
  }
}
