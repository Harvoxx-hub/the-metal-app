import 'package:metal/core/error_handling/error_handler.dart';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/data/datasources/remote/prompt_remote_data_source.dart';
import 'package:metal/data/models/prompt_model.dart';
import 'package:metal/data/repositories/prompt/prompt_repository_abstract.dart';
import 'package:metal/domain/entities/prompt_dto.dart';

/// Implementation of prompt repository
/// Coordinates data sources and handles error mapping
class PromptRepository implements PromptRepositoryAbstract {
  final PromptRemoteDataSource _remoteDataSource;

  PromptRepository({
    required PromptRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<BaseState<List<PromptQuestionDto>>> getAllQuestions() async {
    try {
      final response = await _remoteDataSource.getAllQuestions();
      
      // Convert models to DTOs
      final questionDtos = response.map((model) => model.toDto()).toList();

      return BaseState.success(questionDtos);
    } catch (e) {
      return ErrorHandler.handleError<List<PromptQuestionDto>>(e);
    }
  }

  @override
  Future<BaseState<List<UserPromptDto>>> getUserPrompts(String userId) async {
    try {
      final response = await _remoteDataSource.getUserPrompts(userId);
      
      // Convert models to DTOs
      final promptDtos = response.map((model) => model.toDto()).toList();

      return BaseState.success(promptDtos);
    } catch (e) {
      return ErrorHandler.handleError<List<UserPromptDto>>(e);
    }
  }

  @override
  Future<BaseState<List<UserPromptDto>>> saveUserPrompts(List<UserPromptDto> prompts) async {
    try {
      // Convert DTOs to models
      final promptModels = prompts.map((dto) => UserPromptModel(
        questionId: dto.questionId,
        questionText: dto.questionText,
        answer: dto.answer,
      )).toList();

      final response = await _remoteDataSource.saveUserPrompts(promptModels);
      
      // Convert models back to DTOs
      final promptDtos = response.map((model) => model.toDto()).toList();

      return BaseState.success(promptDtos);
    } catch (e) {
      return ErrorHandler.handleError<List<UserPromptDto>>(e);
    }
  }
}
