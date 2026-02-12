import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/data/datasources/remote/remote_data_source_providers.dart';
import 'package:metal/data/repositories/meetup/meetup_repository.dart';

/// Meetup Repository Provider
final meetupRepositoryProvider = Provider<MeetupRepository>((ref) {
  return MeetupRepository(
    remoteDataSource: ref.read(meetupRemoteDataSourceProvider),
  );
});
