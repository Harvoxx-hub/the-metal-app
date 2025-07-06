import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
 
import 'package:metal/widgets/build_user_info.dart';
import 'package:metal/widgets/text_views.dart';
import 'package:metal/features/home_page/domain/entries/thought.model.dart';
import 'package:metal/features/home_page/provider/comment.provider.dart';
 
import 'package:metal/features/home_page/provider/get.user.notifier.dart';
import 'package:metal/features/authentication/provider/user_state_notifier.dart';
 
import 'package:metal/gen/assets.gen.dart';
 
import 'package:metal/features/home_page/widget/comment_reaction_section.dart';

class CommentBottomSheet extends ConsumerStatefulWidget {
  final ThoughtModel thought;

  const CommentBottomSheet({
    Key? key,
    required this.thought,
  }) : super(key: key);

  @override
  ConsumerState<CommentBottomSheet> createState() => _CommentBottomSheetState();
}

class _CommentBottomSheetState extends ConsumerState<CommentBottomSheet> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final commentsState = ref.watch(commentProvider(widget.thought.id));
    final currentUser = ref.watch(userStateProvider).data;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(35),
            topRight: Radius.circular(35),
          ),
        ),
        child: Column(
          children: [
            // Header with pink gradient
            Container(
              height: 60,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(0.00, -1.00),
                  end: Alignment(0, 1),
                  colors: [Color(0xFFDB217A), Color(0xFFF00E3E)],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(35),
                  topRight: Radius.circular(35),
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const TextView(
                    text: "Comments",
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ],
              ),
            ),

            // Comments list
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await ref
                      .read(commentProvider(widget.thought.id).notifier)
                      .getComments();
                },
                child: commentsState.isLoading
                    ? const Center(child: CircularProgressIndicator.adaptive())
                    : commentsState.isError
                        ? Center(
                            child: TextView(
                                text: commentsState.errorMessage ??
                                    "Error loading comments"))
                        : commentsState.data == null ||
                                commentsState.data!.isEmpty
                            ? const Center(
                                child: TextView(text: "No comments yet"))
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: commentsState.data!.length,
                                itemBuilder: (context, index) {
                                  final comment = commentsState.data![index];
                                  return Consumer(
                                    builder: (context, ref, child) {
                                      final userState = ref.watch(
                                          getUserProvider(comment.userId));

                                      if (userState.isLoading) {
                                        return const Center(child: SizedBox());
                                      }

                                      if (userState.isError) {
                                        return TextView(
                                            text: userState.errorMessage ??
                                                "Error loading user");
                                      }

                                      final user = userState.data;
                                      if (user == null) {
                                        return const SizedBox();
                                      }

                                      return Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 16),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            BuildUserInfo(
                                                userId: comment.userId,
                                                thought: widget.thought,
                                                date: comment.createdAt,
                                                commentId: comment.id,
                                                onDeleteComment: (commentId) {
                                                  ref
                                                      .read(commentProvider(
                                                              widget.thought.id)
                                                          .notifier)
                                                      .deleteComment(commentId);
                                                }),
                                            TextView(
                                              text: comment.content,
                                              fontSize: 14,
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                CommentReactionSection(
                                                  thoughtId: widget.thought.id,
                                                  commentId: comment.id,
                                                  reactions: comment.reactions,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
              ),
            ),

            // Comment input
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Write a comment...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: SvgPicture.asset(
                      Assets.icons.send.path,
                      color: Color(0xFFD2128B),
                    ),
                    onPressed: () {
                      //dismiss keyboard
                      FocusScope.of(context).unfocus();
                      if (_commentController.text.trim().isNotEmpty) {
                        ref
                            .read(commentProvider(widget.thought.id).notifier)
                            .addComment(_commentController.text.trim());
                        _commentController.clear();
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
