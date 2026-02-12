import 'package:metal/core/state/base.state.dart';

/// Base repository interface
/// All repositories should implement this interface
abstract class BaseRepository {
  // Add common repository methods here if needed
}

/// Repository interface for CRUD operations
abstract class BaseCrudRepository<T> extends BaseRepository {
  Future<BaseState<T>> getById(String id);
  Future<BaseState<List<T>>> getAll();
  Future<BaseState<T>> create(T entity);
  Future<BaseState<T>> update(String id, T entity);
  Future<BaseState<void>> delete(String id);
}

