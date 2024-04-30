import 'package:dartx/dartx.dart';

enum PushType {
  message('message'),
  pushmelt('pushMelt');
  // comment('comment'),
  // follow('follow');

  const PushType(this.value);

  final String value;
  @override
  String toString() => value;

  static PushType? valueOf(String? raw) =>
      PushType.values.firstOrNullWhere((e) => e.value == raw);
}
