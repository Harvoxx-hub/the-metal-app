import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';
import 'package:metal/features/home_page/provider/send.thoughts.dart';
import 'package:metal/features/my.metals/melt.metal.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/widgets/button/buttons.dart';
import 'package:metal/widgets/button/plain.button.dart';
import 'package:metal/widgets/profile.photo.dart';
import 'package:metal/widgets/text_views.dart';

class PostThought extends ConsumerStatefulWidget {
  const PostThought({super.key, required this.userModel});
  final UserModel userModel;

  @override
  ConsumerState<PostThought> createState() => _PostThoughtState();
}

class _PostThoughtState extends ConsumerState<PostThought> {
  TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final sendThoughtState = ref.watch(sendThoughtProvider);
    ref.listen<SendThoughtState>(sendThoughtProvider, (prev, current) {
      if (current.isSuccess) {
        Navigator.pop(context);
      }
    });
    return Scaffold(
      body: SafeArea(
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
                  photourl: widget.userModel.metal?.img ?? '',
                ),
                TextView(text: widget.userModel.username ?? ''),
                const Gap(5),
                if (widget.userModel.isVerified ?? false)
                  Assets.icons.checkVerified.svg(height: 16),
                Spacer(),
                PlainButton(
                    buttonText: "Post",
                    onPressed: () {
                      ref
                          .read(sendThoughtProvider.notifier)
                          .sendThought(controller.text.trim());
                    },
                    width: 100,
                    loading: sendThoughtState.isLoading),
              ]),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Express your Thought...',
                  border: InputBorder.none, // Remove underline border
                ),
                controller: controller,
                style: TextStyle(fontSize: 18), // Adjust the text size
                autofocus: true, // Automatically focus the text field
                keyboardType: TextInputType.multiline,
                maxLines: null, // Makes it multiline
              ),
            ),
          ],
        ),
      ),
    );
  }
}
