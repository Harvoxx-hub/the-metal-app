import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
 
import 'package:metal/features/dashboard.dart/widget/complete.profile.dialog.dart';
import 'package:metal/features/authentication/provider/user_state_notifier.dart';
import 'package:metal/features/home_page/provider/send.thoughts.dart';
import 'package:metal/features/home_page/provider/edit.thoughts.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/widgets/button/plain.button.dart';
import 'package:metal/widgets/dialog/custom.dialog.dart';
import 'package:metal/widgets/profile.photo.dart';
import 'package:metal/widgets/text_views.dart';
import 'package:metal/features/home_page/domain/entries/thought.model.dart';

class PostThought extends ConsumerStatefulWidget {
  const PostThought({
    super.key,
    this.thoughtModel,
  });

  final ThoughtModel? thoughtModel;

  @override
  ConsumerState<PostThought> createState() => _PostThoughtState();
}

class _PostThoughtState extends ConsumerState<PostThought> {
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller =
        TextEditingController(text: widget.thoughtModel?.content ?? '');
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sendThoughtState = ref.watch(sendThoughtProvider);
    final editThoughtState = ref.watch(editThoughtProvider);
    final userModel = ref.watch(userStateProvider).data!;

    ref.listen<SendThoughtState>(sendThoughtProvider, (prev, current) {
      if (current.isSuccess) {
        Navigator.pop(context);
      }
    });

    ref.listen<EditThoughtState>(editThoughtProvider, (prev, current) {
      if (current.isSuccess) {
        Navigator.pop(context);
      }
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  ProfilePhoto(
                    verfly: false,
                    size: 24,
                    meltId: userModel.metal!,
                  ),
                  TextView(text: userModel.username ?? ''),
                  const Gap(5),
                  if (userModel.isVerified ?? false)
                    Assets.icons.checkVerified.svg(height: 16),
                  const Spacer(),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: controller,
                    builder: (context, value, child) {
                      final isTextNotEmpty = value.text.trim().isNotEmpty;
                      return PlainButton(
                        enabled: isTextNotEmpty,
                        buttonText:
                            widget.thoughtModel == null ? "Post" : "Update",
                        onPressed: isTextNotEmpty
                            ? () {
                                FocusScope.of(context).unfocus();

                                if (!(userModel.completedProfile ?? false)) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return const CustomDialog(
                                        content: ComplecteProfileDialog(),
                                      );
                                    },
                                  );
                                } else {
                                  if (widget.thoughtModel == null) {
                                    ref
                                        .read(sendThoughtProvider.notifier)
                                        .sendThought(controller.text.trim());
                                  } else {
                                    ref
                                        .read(editThoughtProvider.notifier)
                                        .editThought(widget.thoughtModel!.id, {
                                      'content': controller.text.trim(),
                                      'updatedAt':
                                          DateTime.now().toIso8601String(),
                                    });
                                  }
                                }
                              }
                            : null,
                        width: 100,
                        loading: sendThoughtState.isLoading ||
                            editThoughtState.isLoading,
                      );
                    },
                  ),
                ]),
              ),
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: widget.thoughtModel == null
                          ? 'Express your Thought...'
                          : 'Edit your Thought...',
                      border: InputBorder.none,
                    ),
                    controller: controller,
                    style: const TextStyle(fontSize: 18),
                    autofocus: true,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
