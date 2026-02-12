import 'package:metal/core/error_handling/error_handler.dart';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/data/datasources/remote/report_remote_data_source.dart';
import 'package:metal/data/repositories/report/report_repository_abstract.dart';
import 'package:metal/domain/entities/report_dto.dart';

/// Repository for report operations
/// Implements business logic for reporting users and content
class ReportRepository implements ReportRepositoryAbstract {
  final ReportRemoteDataSource _remoteDataSource;

  ReportRepository({
    required ReportRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<BaseState<bool>> reportUser({
    required UserReportDto report,
  }) async {
    try {
      await _remoteDataSource.reportUser(report: report);
      return BaseState.success(true);
    } catch (e) {
      return ErrorHandler.handleError<bool>(e);
    }
  }

  @override
  Future<BaseState<bool>> reportContent({
    required ContentReportDto report,
  }) async {
    try {
      await _remoteDataSource.reportContent(report: report);
      return BaseState.success(true);
    } catch (e) {
      return ErrorHandler.handleError<bool>(e);
    }
  }
}
