import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/data/repositories/meetup/meetup_repository.dart';
import 'package:metal/data/repositories/meetup/meetup_repository_providers.dart';
import 'package:metal/domain/entities/meetup_dto.dart';
import 'package:metal/data/models/user_preferences_model.dart';

/// Create Meetup State
class CreateMeetupState {
  final bool isLoading;
  final bool isSuccess;
  final bool isError;
  final String? errorMessage;
  final MeetupDto? createdMeetup;

  const CreateMeetupState({
    this.isLoading = false,
    this.isSuccess = false,
    this.isError = false,
    this.errorMessage,
    this.createdMeetup,
  });

  factory CreateMeetupState.initial() => const CreateMeetupState();

  factory CreateMeetupState.loading() => const CreateMeetupState(isLoading: true);

  factory CreateMeetupState.success(MeetupDto meetup) {
    return CreateMeetupState(
      isSuccess: true,
      createdMeetup: meetup,
    );
  }

  factory CreateMeetupState.error(String message) {
    return CreateMeetupState(
      isError: true,
      errorMessage: message,
    );
  }

  CreateMeetupState copyWith({
    bool? isLoading,
    bool? isSuccess,
    bool? isError,
    String? errorMessage,
    MeetupDto? createdMeetup,
  }) {
    return CreateMeetupState(
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      isError: isError ?? this.isError,
      errorMessage: errorMessage ?? this.errorMessage,
      createdMeetup: createdMeetup ?? this.createdMeetup,
    );
  }
}

/// Create Meetup ViewModel
class CreateMeetupViewModel extends StateNotifier<CreateMeetupState> {
  final MeetupRepository _repository;

  CreateMeetupViewModel({
    required MeetupRepository repository,
  })  : _repository = repository,
        super(CreateMeetupState.initial());

  Future<bool> createMeetup(CreateMeetupDto createData) async {
    if (state.isLoading) return false;

    state = CreateMeetupState.loading();

    final result = await _repository.createMeetup(createData);

    if (mounted) {
      if (result.isSuccess && result.data != null) {
        state = CreateMeetupState.success(result.data!);
        return true;
      } else {
        state = CreateMeetupState.error(
          result.errorMessage ?? 'Failed to create meetup',
        );
        return false;
      }
    }

    return false;
  }

  void reset() {
    state = CreateMeetupState.initial();
  }
}

/// Create Meetup ViewModel Provider
final createMeetupViewModelProvider =
    StateNotifierProvider<CreateMeetupViewModel, CreateMeetupState>((ref) {
  return CreateMeetupViewModel(
    repository: ref.read(meetupRepositoryProvider),
  );
});
