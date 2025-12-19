import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/data/datasources/remote/remote_data_source_providers.dart';
import 'package:metal/data/repositories/feedback/feedback_repository.dart';

final feedbackRepositoryProvider = Provider<FeedbackRepository>((ref) {
  final remoteDataSource = ref.watch(feedbackRemoteDataSourceProvider);
  return FeedbackRepository(remoteDataSource: remoteDataSource);
});
