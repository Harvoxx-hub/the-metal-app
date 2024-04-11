import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:metal/core/state/base.state.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/features/sparks_page/data/repositories/spark.repository.dart';
import 'package:metal/features/sparks_page/domain/entries/spark.model.dart';

class GetSparkNotifier extends StateNotifier<GetsparkState> {
  GetSparkNotifier(
    GetsparkState state,
    this.ref,
  ) : super(state) {
    getSpark();
  }
  final Ref ref;

  //get sparks
  void getSpark() async {
    // try {
    //   state = GetsparkState.loading();
    //   final sparkRepository = ref.watch(sparkRepositoryProvider);
    //   final response = await sparkRepository.getSparkHistory();
    //   final List<SparkModel> spark = [];
    //   response.data.forEach((element) {
    //     spark.add(SparkModel.fromJson(element));
    //   });
    //   state = GetsparkState.success(spark);
    // } catch (e) {
    //   print(e.toString());
    //   state = GetsparkState.error(e.toString());
    // }
  }
}

// Define a type alias
typedef GetsparkState = BaseState<List<SparkModel>>;

final getSparkProvider =
    StateNotifierProvider.autoDispose<GetSparkNotifier, GetsparkState>(
  (ref) => GetSparkNotifier(GetsparkState.initial(), ref),
);
