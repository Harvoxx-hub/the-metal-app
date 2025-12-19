import 'package:metal/core/state/base.state.dart';
import 'package:metal/domain/entities/report_dto.dart';

/// Abstract repository for report operations
abstract class ReportRepositoryAbstract {
  /// Report a user
  Future<BaseState<bool>> reportUser({
    required UserReportDto report,
  });

  /// Report content
  Future<BaseState<bool>> reportContent({
    required ContentReportDto report,
  });
}
