import 'package:dartx/dartx.dart';

enum PushType {
  message('new_message'),
  messageDirect('message'),
  new_connection('new_connection'),
  match('match'), // backend may send 'match' for melted; treat same as melted
  profileLiked('profile_liked'),
  melted('melted'),
  sparksSent('sparks_sent'),
  referralJoined('referral_joined'),
  unmetalRequest('unmetal_request'),
  unmetalAcceptance('unmetal_acceptance'),
  unmetalRequiresMoreTime('unmetal_requires_more_time'),
  meltRequest('melt_request'),
  meetupRsvpDeclined('meetup_rsvp_declined'),
  thought_created('thought_created'),
  /// Repost notification (backend `thought.service`); must match FCM `data.type`.
  thoughtRepost('thought_repost'),
  reaction_added('reaction_added'),
  sparks_transaction('sparks_transaction'),
  thought_reminder('thought_reminder'),
  comment('comment'),
  comment_reaction('comment_reaction'),
  community_post('community_post'),
  community_join('community_join'),
  meetup_created('meetup_created'),
  meetup_invite('meetup_invite'),
  meetup_reminder('meetup_reminder'),
  meetup_rsvp_update('meetup_rsvp_update'),
  meetup_capacity_reached('meetup_capacity_reached'),
  promptReaction('prompt_reaction'),
  directMessage('direct_message'),
  unknown('unknown'),
  follow('follow');

  const PushType(this.value);

  final String value;
  @override
  String toString() => value;

  static PushType? valueOf(String? raw) =>
      PushType.values.firstOrNullWhere((e) => e.value == raw);
}
