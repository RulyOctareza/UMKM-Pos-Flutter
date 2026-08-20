import '../../../../core/errors/result.dart';
import '../entities/dashboard_summary.dart';
import '../repositories/dashboard_repository.dart';

class GetDashboardSummaryUseCase {
  final DashboardRepository _repository;
  const GetDashboardSummaryUseCase(this._repository);

  Future<Result<DashboardSummary>> execute() =>
      _repository.getDashboardSummary();
  Stream<DashboardSummary> watch() => _repository.watchDashboardSummary();
}
