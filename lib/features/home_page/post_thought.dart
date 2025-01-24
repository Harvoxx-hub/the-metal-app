import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';
import 'package:metal/features/dashboard.dart/widget/complete.profile.dialog.dart';
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
    required this.userModel,
    this.thoughtModel,
  });

  final UserModel userModel;
  final ThoughtModel? thoughtModel;

  @override
  ConsumerState<PostThought> createState() => _PostThoughtState();
}

class _PostThoughtState extends ConsumerState<PostThought> {
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.thoughtModel != null) {
      controller.text = widget.thoughtModel!.content;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sendThoughtState = ref.watch(sendThoughtProvider);
    final editThoughtState = ref.watch(editThoughtProvider);

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
                    meltId: widget.userModel.metal!,
                  ),
                  TextView(text: widget.userModel.username ?? ''),
                  const Gap(5),
                  if (widget.userModel.isVerified ?? false)
                    Assets.icons.checkVerified.svg(height: 16),
                  const Spacer(),
                  PlainButton(
                    buttonText: widget.thoughtModel == null ? "Post" : "Update",
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      if (!(widget.userModel.completedProfile ?? false)) {
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
                            'updatedAt': DateTime.now().toIso8601String(),
                          });
                        }
                      }
                    },
                    width: 100,
                    loading: sendThoughtState.isLoading ||
                        editThoughtState.isLoading,
                  ),
                ]),
              ),
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Express your Thought...',
                      border: InputBorder.none, // Remove underline border
                    ),
                    controller: controller,
                    style:
                        const TextStyle(fontSize: 18), // Adjust the text size
                    autofocus: true, // Automatically focus the text field
                    keyboardType: TextInputType.multiline,
                    maxLines: null, // Makes it multiline
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
