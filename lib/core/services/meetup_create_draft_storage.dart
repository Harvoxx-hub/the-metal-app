import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

const _kKey = 'meetup_create_draft_v1';
const _kMaxAge = Duration(days: 30);

/// Persisted state for [CreateMeetupScreen] so drafts survive app kill / logout.
class MeetupCreateDraft {
  final DateTime savedAt;
  final String title;
  final String description;
  final DateTime selectedDate;
  final DateTime focusedMonth;
  final int guestCapacity;
  final int broadcastRadius;
  final String inviteType;
  final List<String> selectedFriendIds;
  final String? pickedPlaceName;
  final double? pickedLat;
  final double? pickedLng;
  final String? communityId;

  const MeetupCreateDraft({
    required this.savedAt,
    required this.title,
    required this.description,
    required this.selectedDate,
    required this.focusedMonth,
    required this.guestCapacity,
    required this.broadcastRadius,
    required this.inviteType,
    required this.selectedFriendIds,
    this.pickedPlaceName,
    this.pickedLat,
    this.pickedLng,
    this.communityId,
  });

  bool get isStale =>
      DateTime.now().difference(savedAt) > _kMaxAge;

  /// Worth offering "resume" vs empty new form.
  bool get hasMeaningfulContent {
    if (title.trim().isNotEmpty) return true;
    if (description.trim().isNotEmpty) return true;
    if (pickedLat != null && pickedLng != null) return true;
    if (inviteType == 'select_friends' && selectedFriendIds.isNotEmpty) {
      return true;
    }
    return false;
  }

  Map<String, dynamic> toJson() => {
        'v': 1,
        'savedAt': savedAt.toIso8601String(),
        'title': title,
        'description': description,
        'selectedDate': selectedDate.toIso8601String(),
        'focusedMonth': focusedMonth.toIso8601String(),
        'guestCapacity': guestCapacity,
        'broadcastRadius': broadcastRadius,
        'inviteType': inviteType,
        'selectedFriendIds': selectedFriendIds,
        'pickedPlaceName': pickedPlaceName,
        'pickedLat': pickedLat,
        'pickedLng': pickedLng,
        'communityId': communityId,
      };

  static MeetupCreateDraft? fromJsonString(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      if (m['v'] != 1) return null;
      final savedAt = DateTime.tryParse(m['savedAt'] as String? ?? '');
      if (savedAt == null) return null;
      final selectedDate =
          DateTime.tryParse(m['selectedDate'] as String? ?? '') ?? savedAt;
      final focusedMonth =
          DateTime.tryParse(m['focusedMonth'] as String? ?? '') ?? selectedDate;
      final ids = (m['selectedFriendIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          <String>[];
      double? lat;
      double? lng;
      final pl = m['pickedLat'];
      final png = m['pickedLng'];
      if (pl is num) lat = pl.toDouble();
      if (png is num) lng = png.toDouble();

      return MeetupCreateDraft(
        savedAt: savedAt,
        title: m['title'] as String? ?? '',
        description: m['description'] as String? ?? '',
        selectedDate: selectedDate,
        focusedMonth: focusedMonth,
        guestCapacity: (m['guestCapacity'] as num?)?.toInt() ?? 8,
        broadcastRadius: (m['broadcastRadius'] as num?)?.toInt() ?? 25,
        inviteType: m['inviteType'] as String? ?? 'broadcast',
        selectedFriendIds: ids,
        pickedPlaceName: m['pickedPlaceName'] as String?,
        pickedLat: lat,
        pickedLng: lng,
        communityId: m['communityId'] as String?,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<MeetupCreateDraft?> load(SharedPreferences prefs) async {
    final raw = prefs.getString(_kKey);
    final d = fromJsonString(raw);
    if (d == null) return null;
    if (d.isStale) {
      await clear(prefs);
      return null;
    }
    return d;
  }

  static Future<void> save(SharedPreferences prefs, MeetupCreateDraft draft) {
    return prefs.setString(_kKey, jsonEncode(draft.toJson()));
  }

  static Future<void> clear(SharedPreferences prefs) {
    return prefs.remove(_kKey);
  }
}
