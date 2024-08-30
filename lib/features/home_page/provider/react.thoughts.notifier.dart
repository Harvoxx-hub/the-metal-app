import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:metal/core/state/base.state.dart';

import 'package:metal/features/home_page/data/repositories/home.repository.dart';
import 'package:metal/features/home_page/domain/entries/thought.model.dart';

class ReactThoughtNotifier extends StateNotifier<ReactThoughtState> {
  ReactThoughtNotifier(
    super.state,
    this.ref,
  );
  final Ref ref;

  void reactThought(int thoughtid, String emoji) async {
    try {
      final homeRepository = ref.watch(homeRepositoryProvider);
      final response =
          await homeRepository.reactThought(thoughtid, emojiToUnicode(emoji));
           print(response.data['data'][0]);
      if (mounted) {
       
        state = ReactThoughtState.success(
            ThoughtModel.fromJson(response.data['data'][0]));
      }
    } catch (e) {
      print(e.toString());
      state = ReactThoughtState.error(e.toString());
    }
  }

  String emojiToUnicode(String emoji) {
    return emoji.runes.map((rune) => rune.toRadixString(16)).join('-');
  }
}

// Define a type alias
typedef ReactThoughtState = BaseState<ThoughtModel>;

final reactThoughtProvider =
    StateNotifierProvider.autoDispose<ReactThoughtNotifier, ReactThoughtState>(
  (ref) => ReactThoughtNotifier(ReactThoughtState.initial(), ref),
);
