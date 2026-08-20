import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/core_providers.dart';
import '../../domain/entities/dashboard_summary.dart';

final dashboardSummaryStreamProvider = StreamProvider<DashboardSummary>((ref) {
  final useCase = ref.watch(getDashboardSummaryUseCaseProvider);
  return useCase.watch();
});
