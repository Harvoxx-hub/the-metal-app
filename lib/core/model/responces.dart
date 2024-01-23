class Response {
  final bool success;
  final String message;
  var data;

  Response({
    required this.success,
    required this.message,
    required this.data,
  });

  factory Response.fromJson(Map<String, dynamic> json) {
    return Response(
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
