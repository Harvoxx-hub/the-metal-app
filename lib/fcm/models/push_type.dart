import 'package:dartx/dartx.dart';

enum PushType {
  message('message'),
  new_connection('new_connection'),
  unmetal_request('unmetal_request'),
  thought_created('thought_created'),
  reaction_added('reaction_added'),
  sparks_transaction('sparks_transaction'),
  thought_reminder('thought_reminder'),
  comment('comment'),
  comment_reaction('comment_reaction'),
  unknown('unknown'),
  follow('follow');

  const PushType(this.value);

  final String value;
  @override
  String toString() => value;

  static PushType? valueOf(String? raw) =>
      PushType.values.firstOrNullWhere((e) => e.value == raw);
}
