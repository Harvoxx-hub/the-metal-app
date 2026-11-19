/// Response model for chat assistant suggestions API
class ChatAssistantResponseModel {
  final List<String> suggestions;
  final String tone;
  final String mode;
  final bool fallback;

  ChatAssistantResponseModel({
    required this.suggestions,
    required this.tone,
    required this.mode,
    required this.fallback,
  });

  factory ChatAssistantResponseModel.fromJson(Map<String, dynamic> json) {
    return ChatAssistantResponseModel(
      suggestions: (json['suggestions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      tone: json['tone'] as String? ?? 'casual',
      mode: json['mode'] as String? ?? 'starter',
      fallback: json['fallback'] as bool? ?? false,
    );
  }
}
