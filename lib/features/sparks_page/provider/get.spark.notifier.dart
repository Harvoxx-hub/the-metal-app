import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/sparks_page/data/repositories/spark.repository.dart';
import 'package:metal/features/sparks_page/domain/entries/spark.model.dart';

class GetSparkNotifier extends StateNotifier<GetsparkState> {
  GetSparkNotifier(
    super.state,
    this.ref,
  ) {
    getSpark();
  }
  final Ref ref;

  // Get Sparks sorted by timeline (newest to oldest)
  void getSpark() async {
    try {
      state = GetsparkState.loading();
      final sparkRepository = ref.watch(sparkRepositoryProvider);
      final response = await sparkRepository.getSparkHistory();
      final List<SparkModel> spark = [];

      // Convert JSON response to SparkModel list
      for (var element in response.data) {
        spark.add(SparkModel.fromJson(element));
      }

      // Sort the sparks by timeline in descending order (newest first)
      spark.sort((a, b) {
        final DateTime aTime = DateTime.parse(a.timestamp!);
        final DateTime bTime = DateTime.parse(b.timestamp!);
        return bTime.compareTo(aTime); // Newest first
      });
      if (mounted) {

      state = GetsparkState.success(spark);
      }
    } catch (e, s) {
      if (mounted) {
      state = GetsparkState.error(e.toString(), stackTrace: s);
      }
    }
  }
}

// Define a type alias
typedef GetsparkState = BaseState<List<SparkModel>>;

final getSparkProvider =
    StateNotifierProvider.autoDispose<GetSparkNotifier, GetsparkState>(
  (ref) => GetSparkNotifier(GetsparkState.initial(), ref),
);
