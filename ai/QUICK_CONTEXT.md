# METAL APP - MIGRATION CONTEXT (Quick Resume)

## PROJECT
Flutter app migration from Firestore to REST API using Clean Architecture.
**Current**: Sprint 1 (Sparks System) - COMPLETE ✅ | Ready for Sprint 2

## CLEAN ARCHITECTURE RULES (STRICT)

### Layer Flow
View → ViewModel → Repository → RemoteDataSource → DioClient → API

### Rule 1: API Calls ONLY in RemoteDataSources
- Location: `lib/data/datasources/remote/[feature]_remote_data_source.dart`
- Uses: DioClient
- FORBIDDEN: API calls in Views, ViewModels, Repositories

### Rule 2: Imports (CRITICAL)
```dart
import 'package:metal/core/state/base.state.dart';           // BaseState
import 'package:metal/core/error_handling/error_handler.dart'; // ErrorHandler
```

### Rule 3: API Routes Centralized
- File: `lib/core/network/api_routes.dart`
- Usage: `ApiRoutes.buildPath(ApiRoutes.endpoint)`

### Rule 4: Error Handling Pattern
```dart
try {
  final response = await _remoteDataSource.method();
  return BaseState.success(response.toDomain());
} catch (e) {
  return ErrorHandler.handleError<T>(e);
}
```

## COMPLETED WORK

### ✅ Sprint 1 - Sparks System (COMPLETE)
✅ Step 1: Domain entities (`lib/domain/entities/spark_dto.dart`)
✅ Step 2: Data models (`lib/data/models/spark_model.dart`)
✅ Step 3: RemoteDataSource (`lib/data/datasources/remote/spark_remote_data_source.dart`)
✅ Step 4: Repository (`lib/data/repositories/spark/`)
✅ Step 5: ViewModel (`lib/presentation/viewmodels/spark/spark_viewmodel.dart`)
✅ Step 6: Views (`lib/presentation/views/spark/`)
✅ Step 7: Dashboard updated to use SparkView
✅ Step 8: Legacy `/lib/features/sparks_page/` deleted

**Files Created**: 11
**Firestore Refs Eliminated**: 95
**Legacy Code Removed**: 500+ lines

### API Routes Added (lines 75-77)
```dart
static const String sparks = '/sparks';
static const String sparksSend = '/sparks/send';
```

## NEXT STEPS (Sprint 2 - Settings & User Management)

**Task 1**: Extend ProfileRemoteDataSource
- Add: `getBlockedUsers(page, limit)` - GET /api/v1/users/me/blocked
- Add: `blockUser(userId, reason)` - POST /api/v1/users/me/blocked/{userId}
- Add: `unblockUser(userId)` - DELETE /api/v1/users/me/blocked/{userId}
- Add: `deleteAccount(password)` - DELETE /api/v1/users/me

**Task 2**: Create ViewModels
- `lib/presentation/viewmodels/settings/blocked_users_viewmodel.dart`
- `lib/presentation/viewmodels/settings/delete_account_viewmodel.dart`

**Task 3**: Create Views
- `lib/presentation/views/settings/blocked_users_view.dart`
- `lib/presentation/views/settings/delete_account_view.dart`

**Task 4**: Delete Legacy
- `lib/features/settings/presentation/blocked.user.dart`
- `lib/features/settings/presentation/delete.screen.dart`
- `lib/features/settings/provider/block.user.notifier.dart`
- `lib/features/settings/provider/get.blocked.user.notifier.dart`

**Impact**: Remove 30 Firestore refs

## REPOSITORY PATTERN (Copy-Paste Template)
```dart
class XRepository implements XRepositoryAbstract {
  final XRemoteDataSource _remoteDataSource;

  XRepository({required XRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<BaseState<XDto>> method() async {
    try {
      final response = await _remoteDataSource.method();
      final dto = response.toDomain();
      return BaseState.success(dto);
    } catch (e) {
      return ErrorHandler.handleError<XDto>(e);
    }
  }
}
```

## VIEWMODEL PATTERN (Copy-Paste Template)
```dart
class XViewModel extends StateNotifier<XState> {
  final XRepository _repository;

  XViewModel({required XRepository repository})
    : _repository = repository,
      super(XState.initial());

  Future<void> loadData() async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.getData();

    if (result.isSuccess && result.data != null) {
      state = state.copyWith(isLoading: false, data: result.data);
    } else {
      state = state.copyWith(isLoading: false, errorMessage: result.errorMessage);
    }
  }
}
```

## PROVIDER PATTERN (Copy-Paste Template)
```dart
final xRemoteDataSourceProvider = Provider<XRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return XRemoteDataSource(dioClient);
});

final xRepositoryProvider = Provider<XRepository>((ref) {
  final remoteDataSource = ref.watch(xRemoteDataSourceProvider);
  return XRepository(remoteDataSource: remoteDataSource);
});

final xViewModelProvider = StateNotifierProvider.autoDispose<XViewModel, XState>((ref) {
  final repository = ref.watch(xRepositoryProvider);
  final viewModel = XViewModel(repository: repository);
  viewModel.loadData();
  return viewModel;
});
```

## KEY FILES
- Master Definition: `ai/system.md`
- Full Plan: `ai/witty-imagining-wind.md` (1372 lines)
 
- API Routes: `lib/core/network/api_routes.dart`
- Dashboard: `lib/presentation/views/dashboard/dashboard_view.dart`

## MIGRATION STATUS
- Features migrated: 4/16 (Home, Chat, Thought, Sparks ✅)
- Firestore refs eliminated: 145/345 (42%)
- Sprint 1 complete: Removed 95 Firestore refs ✅
- Sprint 2 target: Remove 30 Firestore refs from Settings

---

**To resume work**: Paste this summary, then run:
```bash
Read ai/CHECKPOINT_RESUME_POINT_V1.md
```
