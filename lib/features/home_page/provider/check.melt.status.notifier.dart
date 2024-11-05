import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/core/state/base.state.dart';

import 'package:metal/features/home_page/data/repositories/home.repository.dart';

enum CheckStatus {
  REQUESTED,
  NOMELT,
  MUTUAL,
}

class CheckMeltStatusNotifier extends StateNotifier<CheckMeltState> {
  CheckMeltStatusNotifier(super.state, this.ref, this.id) {
    checkStatus();
  }
  final Ref ref;
  final String id;

  // Function to map the string status to the CheckStatus enum
  CheckStatus _mapStringToCheckStatus(String status) {
    switch (status) {
      case "4oGg4oGgUkVRVUVTVEVE":
        return CheckStatus.REQUESTED;
      case "4oGgTk9NRUxU":
        return CheckStatus.NOMELT;
      case "TVVUVUFM":
        return CheckStatus.MUTUAL;
      default:
         
 
        throw Exception("Unknown status: $status");
    }
  }

  // Fetch status from the repository
  void checkStatus() async {
    try {
      state = CheckMeltState.loading();
      final repository = ref.watch(homeRepositoryProvider);

      final response = await repository.checkMelt(userId: id);
Codec<String, String> stringToBase64 = utf8.fuse(base64);
      // Map the response string to the CheckStatus enum
      final status = _mapStringToCheckStatus(stringToBase64.encode(response.data["status"]));

      state = CheckMeltState.success(status);
    } catch (e, s) {
      state = CheckMeltState.error(e.toString(), stackTrace: s);
    }
  }
}

// Define a type alias
typedef CheckMeltState = BaseState<CheckStatus>;

final checkMeltProvider = StateNotifierProvider.family
    .autoDispose<CheckMeltStatusNotifier, CheckMeltState, String>(
  (ref, id) => CheckMeltStatusNotifier(CheckMeltState.initial(), ref, id),
);
