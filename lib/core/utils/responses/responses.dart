class Responses<T> {
  final bool? success;
  final String? message;
  final T? data;
  final bool requiresReauth;

  Responses({
    this.success,
    this.message,
    this.data,
    this.requiresReauth = false,
  });
}
