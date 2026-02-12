import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/base/widget/appbar.state.dart';
import 'package:metal/presentation/viewmodels/connection/connection_providers.dart';
import 'package:metal/presentation/views/connection/widgets/connection_card.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/widgets/state.handler/empty.state.dart';
import 'package:metal/widgets/state.handler/error.state.dart';

/// Screen displaying the list of user's connections (melted metals)
class ConnectionListScreen extends ConsumerStatefulWidget {
  const ConnectionListScreen({super.key});

  static const name = 'connectionListPage';
  static const route = name;

  @override
  ConsumerState<ConnectionListScreen> createState() =>
      _ConnectionListScreenState();
}

class _ConnectionListScreenState extends ConsumerState<ConnectionListScreen> {
  @override
  Widget build(BuildContext context) {
    final connectionState = ref.watch(connectionViewModelProvider);

    return BaseScreen(
      subAppBar: false,
      appBarState: AppBarState.HambugerWithHeader,
      Header: "melted metal",
      body: connectionState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : connectionState.isError
              ? ErrorState(
                  retry: () {
                    ref.read(connectionViewModelProvider.notifier).refresh();
                  },
                  text: connectionState.errorMessage,
                )
              : connectionState.connections.isNotEmpty
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          Assets.images.heartLocks1.path,
                          height: 138,
                          width: 138,
                        ),
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: () async {
                              await ref
                                  .read(connectionViewModelProvider.notifier)
                                  .refresh();
                            },
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: connectionState.connections.length,
                              itemBuilder: (context, index) {
                                return ConnectionCard(
                                  connection: connectionState.connections[index],
                                );
                              },
                            ),
                          ),
                        )
                      ],
                    )
                  : const EmptyState(text: "You have no melted metals yet"),
    );
  }
}
