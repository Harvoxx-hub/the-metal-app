import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:metal/domain/entities/thought_dto.dart';
import 'package:metal/presentation/views/thought/widgets/thought_card.dart';
import 'package:metal/widgets/state.handler/empty.state.dart';
import 'package:metal/widgets/state.handler/loading.state.dart';

/// User Thoughts Tab - displays thoughts posted by the user
class UserThoughtsTab extends ConsumerStatefulWidget {
  final String userId;
  final List<ThoughtDto> thoughts;
  final bool isLoading;
  final bool hasMore;
  final Function({bool isLoadMore}) onLoadMore;
  final Future<void> Function() onRefresh;

  const UserThoughtsTab({
    super.key,
    required this.userId,
    required this.thoughts,
    required this.isLoading,
    required this.hasMore,
    required this.onLoadMore,
    required this.onRefresh,
  });

  @override
  ConsumerState<UserThoughtsTab> createState() => _UserThoughtsTabState();
}

class _UserThoughtsTabState extends ConsumerState<UserThoughtsTab> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        widget.hasMore &&
        !widget.isLoading) {
      widget.onLoadMore(isLoadMore: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading && widget.thoughts.isEmpty) {
      return const LoadingState();
    }

    if (widget.thoughts.isEmpty) {
      return RefreshIndicator(
        onRefresh: widget.onRefresh,
        child: const SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: SizedBox(
     
            child: EmptyState(
              text: 'No thoughts yet\nThis user hasn\'t posted anything yet.',
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: widget.thoughts.length + (widget.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == widget.thoughts.length) {
            // Load more indicator
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Center(child: CircularProgressIndicator.adaptive()),
            );
          }

          final thought = widget.thoughts[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ThoughtCard(
              key: ValueKey(thought.id),
              thoughtModel: thought,
            ),
          );
        },
      ),
    );
  }
}
