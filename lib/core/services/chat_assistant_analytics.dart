import 'package:firebase_analytics/firebase_analytics.dart';

/// Lightweight analytics helper for chat assistant events.
class ChatAssistantAnalytics {
  static final _analytics = FirebaseAnalytics.instance;

  static Future<void> logSuggestionsShown({
    required String mode,
    required String tone,
    required int count,
    bool fallback = false,
  }) =>
      _analytics.logEvent(
        name: 'chat_assistant_suggestions_shown',
        parameters: {
          'mode': mode,
          'tone': tone,
          'count': count,
          'fallback': fallback.toString(),
        },
      );

  static Future<void> logSuggestionTapped({
    required String mode,
    required int index,
  }) =>
      _analytics.logEvent(
        name: 'chat_assistant_suggestion_tapped',
        parameters: {
          'mode': mode,
          'index': index,
        },
      );

  static Future<void> logToneSelected({required String tone}) =>
      _analytics.logEvent(
        name: 'chat_assistant_tone_selected',
        parameters: {'tone': tone},
      );

  static Future<void> logBoosterTriggered({required String reason}) =>
      _analytics.logEvent(
        name: 'chat_assistant_booster_triggered',
        parameters: {'reason': reason},
      );

  static Future<void> logFallbackUsed({required String mode}) =>
      _analytics.logEvent(
        name: 'chat_assistant_fallback_used',
        parameters: {'mode': mode},
      );
}
