class Responses {
  bool? success;
  String? message;
  var data;
  String? action;

  Responses({this.success, this.message, this.data, this.action});

  factory Responses.fromJson(Map<String, dynamic> json) {
    return Responses(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      action: json['action'] ?? '',
      data: json['data'] ?? {},
    );
  }

  @override
  String toString() {
    return 'Response{success: $success, message: $message, data: $data}';
  }
}
