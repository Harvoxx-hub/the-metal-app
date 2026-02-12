/// Chat-related constants to eliminate magic numbers
/// Centralizes all chat configuration values
class ChatConstants {
  ChatConstants._();

  // ============ Message Constraints ============
  /// Maximum length for reply preview text
  static const int maxReplyPreviewLength = 50;

  /// Maximum width for message bubble
  static const double maxMessageBubbleWidth = 280.0;

  /// Minimum width for message bubble
  static const double minMessageBubbleWidth = 80.0;

  // ============ Pagination ============
  /// Number of messages to load per page
  static const int messagesPageSize = 50;

  /// Initial number of messages to load
  static const int initialMessagesLoad = 25;

  // ============ UI Dimensions ============
  /// Profile image size in chat list
  static const double chatListProfileImageSize = 50.0;

  /// Profile image size in chat app bar
  static const double chatAppBarProfileImageSize = 42.0;

  /// Call button size in chat app bar
  static const double callButtonSize = 40.0;

  /// Default icon size
  static const double iconSize = 24.0;

  /// Input field height
  static const double inputFieldHeight = 50.0;

  /// Audio waveform height
  static const double audioWaveformHeight = 50.0;

  // ============ Animation Durations ============
  /// Duration for swipe-to-reply animation
  static const Duration swipeAnimationDuration = Duration(milliseconds: 200);

  /// Duration for scroll-to-message animation
  static const Duration scrollAnimationDuration = Duration(milliseconds: 300);

  /// Duration for message send animation
  static const Duration sendAnimationDuration = Duration(milliseconds: 150);

  // ============ Polling & Timing ============
  /// Interval for polling new messages (REST API fallback)
  static const Duration pollingInterval = Duration(seconds: 3);

  /// Search debounce delay
  static const Duration searchDebounceDelay = Duration(milliseconds: 300);

  /// Typing indicator timeout
  static const Duration typingIndicatorTimeout = Duration(seconds: 3);

  // ============ Audio Recording ============
  /// Audio sample rate
  static const int audioSampleRate = 44100;

  /// Audio bit rate
  static const int audioBitRate = 128000;

  /// Maximum audio recording duration in seconds
  static const int maxAudioDurationSeconds = 120;

  // ============ Border Radius ============
  /// Message bubble border radius
  static const double messageBubbleRadius = 15.0;

  /// Input field border radius
  static const double inputFieldRadius = 25.0;

  /// Chat list item border radius
  static const double chatListItemRadius = 12.0;

  // ============ Padding & Spacing ============
  /// Horizontal padding for messages
  static const double messageHorizontalPadding = 12.0;

  /// Vertical padding for messages
  static const double messageVerticalPadding = 8.0;

  /// Gap between messages from same sender
  static const double sameUserMessageGap = 4.0;

  /// Gap between messages from different senders
  static const double differentUserMessageGap = 12.0;
}
