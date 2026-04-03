import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/data/models/chat_assistant_model.dart';
import 'package:metal/data/repositories/chat/chat_repository_abstract.dart';
import 'package:metal/domain/entities/message_dto.dart';

// ── Enums ────────────────────────────────────────────────────────────────────

enum AssistantMode { starter, reply, booster, interactive }

enum AssistantTone { casual, funny, deep, flirty }

enum InteractiveKind { wouldYouRather, thisOrThat, hotTake, guessFavorite }

extension AssistantModeX on AssistantMode {
  String get apiValue => name;
}

extension AssistantToneX on AssistantTone {
  String get apiValue => name;
}

extension InteractiveKindX on InteractiveKind {
  String get apiValue {
    switch (this) {
      case InteractiveKind.wouldYouRather:
        return 'would_you_rather';
      case InteractiveKind.thisOrThat:
        return 'this_or_that';
      case InteractiveKind.hotTake:
        return 'hot_take';
      case InteractiveKind.guessFavorite:
        return 'guess_favorite';
    }
  }

  String get label {
    switch (this) {
      case InteractiveKind.wouldYouRather:
        return 'Would You Rather';
      case InteractiveKind.thisOrThat:
        return 'This or That';
      case InteractiveKind.hotTake:
        return 'Hot Takes 🔥';
      case InteractiveKind.guessFavorite:
        return 'Guess My Favorite';
    }
  }
}

// ── State ────────────────────────────────────────────────────────────────────

class ChatAssistantState {
  final List<String> suggestions;
  final AssistantMode mode;
  final AssistantTone tone;
  final InteractiveKind? interactiveKind;
  final bool isLoading;
  final bool usedFallback;
  final bool showInteractiveMenu;

  const ChatAssistantState({
    this.suggestions = const [],
    this.mode = AssistantMode.starter,
    this.tone = AssistantTone.casual,
    this.interactiveKind,
    this.isLoading = false,
    this.usedFallback = false,
    this.showInteractiveMenu = false,
  });

  ChatAssistantState copyWith({
    List<String>? suggestions,
    AssistantMode? mode,
    AssistantTone? tone,
    InteractiveKind? interactiveKind,
    bool? isLoading,
    bool? usedFallback,
    bool? showInteractiveMenu,
    bool clearInteractiveKind = false,
  }) {
    return ChatAssistantState(
      suggestions: suggestions ?? this.suggestions,
      mode: mode ?? this.mode,
      tone: tone ?? this.tone,
      interactiveKind:
          clearInteractiveKind ? null : (interactiveKind ?? this.interactiveKind),
      isLoading: isLoading ?? this.isLoading,
      usedFallback: usedFallback ?? this.usedFallback,
      showInteractiveMenu: showInteractiveMenu ?? this.showInteractiveMenu,
    );
  }
}

// ── Static fallbacks ─────────────────────────────────────────────────────────

const _starterFallbacks = [
  "What's something fun you did today?",
  "If you could travel anywhere right now, where would it be?",
  "What's your vibe today?",
  "What show are you binging right now?",
  "What's your go-to comfort food?",
];

const _replyFallbacks = [
  "That's cool! Tell me more",
  "No way, really?",
  "Haha nice 😄",
  "I feel that",
  "Same honestly",
];

const _boosterFallbacks = [
  "Ask about their hobbies 👀",
  "Share something random about your day",
  "Try '2 truths and a lie'",
  "Switch it up with a random question 🎲",
  "Ask what music they're into",
];

List<String> _getFallbackSuggestions(AssistantMode mode) {
  switch (mode) {
    case AssistantMode.starter:
      return _starterFallbacks;
    case AssistantMode.reply:
      return _replyFallbacks;
    case AssistantMode.booster:
      return _boosterFallbacks;
    case AssistantMode.interactive:
      return [
        "Would you rather travel to the past or the future?",
        "Sunrise or sunset?",
        "Hot take: pineapple on pizza is actually good 🔥",
        "Guess my favorite color 🎨",
      ];
  }
}

// ── Notifier ─────────────────────────────────────────────────────────────────

class ChatAssistantNotifier extends StateNotifier<ChatAssistantState> {
  final ChatRepositoryAbstract _repository;
  final String connectionId;

  Timer? _debounceTimer;
  Timer? _idleTimer;
  DateTime? _lastMessageTime;

  /// Simple in-memory cache: cacheKey → suggestions
  final Map<String, List<String>> _cache = {};

  static const _debounceDuration = Duration(milliseconds: 500);
  static const _idleThreshold = Duration(seconds: 45);
  static const _shortReplyMaxLength = 12;
  static const _shortReplyMaxWords = 3;

  ChatAssistantNotifier({
    required ChatRepositoryAbstract repository,
    required this.connectionId,
  })  : _repository = repository,
        super(const ChatAssistantState());

  // ── Public API ──────────────────────────────────────────────────────────

  /// Called when messages change. Determines mode and fetches suggestions.
  void onMessagesChanged(List<MessageDto> messages, String? currentUserId) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(_debounceDuration, () {
      _evaluateMode(messages, currentUserId);
    });
  }

  void setTone(AssistantTone tone) {
    if (tone == state.tone) return;
    state = state.copyWith(tone: tone);
    _fetchSuggestions();
  }

  void selectInteractiveKind(InteractiveKind kind) {
    state = state.copyWith(
      mode: AssistantMode.interactive,
      interactiveKind: kind,
      showInteractiveMenu: false,
    );
    _fetchSuggestions();
  }

  void toggleInteractiveMenu() {
    state = state.copyWith(showInteractiveMenu: !state.showInteractiveMenu);
  }

  void refresh() {
    _fetchSuggestions();
  }

  // ── Mode evaluation ─────────────────────────────────────────────────────

  void _evaluateMode(List<MessageDto> messages, String? currentUserId) {
    if (messages.isEmpty) {
      _setMode(AssistantMode.starter);
      return;
    }

    final lastMsg = messages.first; // messages are newest-first
    _lastMessageTime = lastMsg.timestamp;

    // Check for short/low-effort last outgoing message
    if (lastMsg.senderId == currentUserId && lastMsg.type == MessageType.text) {
      final text = lastMsg.message.trim();
      final wordCount = text.split(RegExp(r'\s+')).length;
      if (text.length <= _shortReplyMaxLength ||
          wordCount <= _shortReplyMaxWords) {
        _setMode(AssistantMode.booster);
        return;
      }
    }

    // If last message is from the other user → reply mode
    if (lastMsg.senderId != currentUserId) {
      _setMode(AssistantMode.reply);
      _startIdleTimer(messages, currentUserId);
      return;
    }

    // Default: check idle, otherwise starter-like
    _startIdleTimer(messages, currentUserId);
    _setMode(AssistantMode.reply);
  }

  void _setMode(AssistantMode mode) {
    if (state.mode == mode && state.suggestions.isNotEmpty) return;
    state = state.copyWith(mode: mode, clearInteractiveKind: true);
    _fetchSuggestions();
  }

  void _startIdleTimer(List<MessageDto> messages, String? currentUserId) {
    _idleTimer?.cancel();
    if (_lastMessageTime == null) return;

    final elapsed = DateTime.now().difference(_lastMessageTime!);
    if (elapsed >= _idleThreshold) {
      if (state.mode != AssistantMode.booster) {
        state = state.copyWith(mode: AssistantMode.booster);
        _fetchSuggestions();
      }
      return;
    }

    final remaining = _idleThreshold - elapsed;
    _idleTimer = Timer(remaining, () {
      if (mounted) {
        state = state.copyWith(mode: AssistantMode.booster);
        _fetchSuggestions();
      }
    });
  }

  // ── API call ────────────────────────────────────────────────────────────

  String get _cacheKey =>
      '${state.mode.apiValue}:${state.tone.apiValue}:${state.interactiveKind?.apiValue ?? ''}';

  Future<void> _fetchSuggestions() async {
    // Check cache first
    final cached = _cache[_cacheKey];
    if (cached != null && cached.isNotEmpty) {
      state = state.copyWith(
        suggestions: cached,
        isLoading: false,
        usedFallback: false,
      );
      return;
    }

    state = state.copyWith(isLoading: true);

    final result = await _repository.getChatSuggestions(
      connectionId: connectionId,
      mode: state.mode.apiValue,
      tone: state.tone.apiValue,
      interactiveKind: state.interactiveKind?.apiValue,
    );

    if (!mounted) return;

    if (result.isSuccess && result.data != null) {
      final data = result.data as ChatAssistantResponseModel;
      _cache[_cacheKey] = data.suggestions;
      state = state.copyWith(
        suggestions: data.suggestions,
        isLoading: false,
        usedFallback: data.fallback,
      );
    } else {
      // Fallback
      final fallbacks = _getFallbackSuggestions(state.mode);
      state = state.copyWith(
        suggestions: fallbacks,
        isLoading: false,
        usedFallback: true,
      );
    }
  }

  // ── Dispose ─────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _idleTimer?.cancel();
    super.dispose();
  }
}
