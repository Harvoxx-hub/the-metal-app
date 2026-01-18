import 'package:metal/core/network/api_routes.dart';
import 'package:metal/core/network/dio_client.dart';
import 'package:metal/data/models/prompt_model.dart';

/// Remote data source for prompt operations
/// Handles API communication for prompts
class PromptRemoteDataSource {
  final DioClient _client;

  PromptRemoteDataSource(this._client);

  /// Get all available prompt questions
  Future<List<PromptQuestionModel>> getAllQuestions() async {
    final response = await _client.get(
      ApiRoutes.buildPath(ApiRoutes.promptQuestions),
    );

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data['data'] as List<dynamic>? ?? response.data;
      
      if (data is List) {
        return data
            .map((item) => PromptQuestionModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      
      throw Exception('Invalid response format');
    }

    throw Exception(response.data?['error'] ?? 'Failed to get questions');
  }

  /// Get user's prompts
  Future<List<UserPromptModel>> getUserPrompts(String userId) async {
    final response = await _client.get(
      '${ApiRoutes.buildPath(ApiRoutes.promptUser)}/$userId',
    );

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data['data'] as List<dynamic>? ?? response.data;
      
      if (data is List) {
        return data
            .map((item) => UserPromptModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      
      // Return empty list if no prompts
      return [];
    }

    throw Exception(response.data?['error'] ?? 'Failed to get user prompts');
  }

  /// Save user prompts
  Future<List<UserPromptModel>> saveUserPrompts(List<UserPromptModel> prompts) async {
    final promptsData = prompts.map((p) => p.toJson()).toList();

    final response = await _client.post(
      ApiRoutes.buildPath(ApiRoutes.promptUser),
      data: {'prompts': promptsData},
    );

    if (response.statusCode == 200 && response.data != null) {
      final data = response.data['data'] as List<dynamic>? ?? response.data;
      
      if (data is List) {
        return data
            .map((item) => UserPromptModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      
      throw Exception('Invalid response format');
    }

    throw Exception(response.data?['error'] ?? 'Failed to save prompts');
  }
}
