import 'package:metal/core/error_handling/error_handler.dart';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/data/datasources/remote/metal_remote_data_source.dart';
import 'package:metal/data/models/metal_properties_model.dart';

/// Metal repository
/// Provides clean interface for metal operations
abstract class IMetalRepository {
  /// Get all metals
  Future<BaseState<List<Metal>>> getMetals();
}

/// Metal repository implementation
class MetalRepository implements IMetalRepository {
  final MetalRemoteDataSource _remoteDataSource;

  MetalRepository(this._remoteDataSource);

  @override
  Future<BaseState<List<Metal>>> getMetals() async {
    try {
      final metals = await _remoteDataSource.getMetals();
      return BaseState.success(metals);
    } catch (e) {
      return ErrorHandler.handleError<List<Metal>>(e);
    }
  }
}





