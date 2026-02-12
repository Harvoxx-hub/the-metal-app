import 'package:metal/core/state/base.state.dart';
import 'package:metal/domain/entities/prompt_dto.dart';

/// Abstract repository interface for prompt operations
/// Defines the contract for prompt data access
abstract class PromptRepositoryAbstract {
  /// Get all available prompt questions
  Future<BaseState<List<PromptQuestionDto>>> getAllQuestions();

  /// Get user's prompts
  Future<BaseState<List<UserPromptDto>>> getUserPrompts(String userId);

  /// Save user prompts (minimum 3 required)
  Future<BaseState<List<UserPromptDto>>> saveUserPrompts(List<UserPromptDto> prompts);
}
