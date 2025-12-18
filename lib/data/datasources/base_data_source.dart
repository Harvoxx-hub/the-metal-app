/// Base data source interface
/// All data sources should implement this interface
abstract class BaseDataSource {
  // Add common data source methods here if needed
}

/// Remote data source interface
abstract class BaseRemoteDataSource extends BaseDataSource {
  // Add common remote data source methods here
}

/// Local data source interface
abstract class BaseLocalDataSource extends BaseDataSource {
  // Add common local data source methods here
}

