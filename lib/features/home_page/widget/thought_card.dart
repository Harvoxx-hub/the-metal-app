import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:metal/core/utils/date.formart.dart';
import 'package:metal/core/utils/input/validators/validators.dart';
import 'package:metal/features/authentication/provider/auth.notifier.dart';
import 'package:metal/features/home_page/domain/entries/thought.model.dart';
import 'package:metal/features/home_page/provider/get.all.users.notifier.dart';
import 'package:metal/features/home_page/provider/get.melt.users.notifier.dart';
import 'package:metal/features/home_page/provider/react.thoughts.notifier.dart';
import 'package:metal/features/my.metals/melted.user.agurment.dart';
import 'package:metal/features/settings/provider/block.user.notifier.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/res/res.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/button/base_button.dart';
import 'package:metal/widgets/dialog/custom.dialog.dart';
import 'package:metal/widgets/profile.photo.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';
import 'package:metal/widgets/text_views.dart';

class ThoughtCard extends ConsumerStatefulWidget {
  final ThoughtModel thoughtModel;

  const ThoughtCard({
    Key? key,
    required this.thoughtModel,
  }) : super(key: key);

  @override
  ConsumerState<ThoughtCard> createState() => _ThoughtCardState();
}

class _ThoughtCardState extends ConsumerState<ThoughtCard> {
  bool melted = false;
  bool _showReactions = false;
  String? _selectedReaction;
  late ThoughtModel thoughtModel;

  @override
  void initState() {
    super.initState();
    thoughtModel = widget.thoughtModel;
  }

  void _toggleReactions() {
    setState(() => _showReactions = !_showReactions);
  }

  void _selectReaction(String reaction) {
    setState(() {
      _selectedReaction = reaction;
      _showReactions = false;
    });

    ref
        .read(reactThoughtProvider.notifier)
        .reactThought(widget.thoughtModel.id!, reaction);
  }

  @override
  Widget build(BuildContext context) {
    final userdata = ref.watch(authProvider).data;
    final meltedUsers = ref.watch(getMeltUserProvider).data;

    melted = (meltedUsers?.any((user) => user.id == widget.thoughtModel.user) ??
            false) ||
        (userdata?.id == widget.thoughtModel.user);

    ref.listen<ReactThoughtState>(reactThoughtProvider, (prev, current) {
      if (current.isSuccess) {
        setState(() {
          thoughtModel = current.data!;
        });
      }
    });

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: _buildThoughtCard(context, userdata),
    );
  }

  Widget _buildThoughtCard(BuildContext context, dynamic userdata) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: _buildBoxDecoration(),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUserInfo(context, userdata),
              const Gap(10),
              TextView(text: thoughtModel.thought!),
              const Gap(10),
              _buildReactionsRow(),
              IconButton(
                onPressed: _toggleReactions,
                icon: const Icon(Icons.favorite_border),
              ),
            ],
          ),
          if (_showReactions) _buildReactionsSelector(),
        ],
      ),
    );
  }

  BoxDecoration _buildBoxDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10.0),
      boxShadow: [
        const BoxShadow(
          color: Colors.black12,
          blurRadius: 10.0,
        ),
      ],
    );
  }

  Widget _buildUserInfo(BuildContext context, dynamic userdata) {
    return GestureDetector(
      onTap: () {
        if (thoughtModel.user != userdata?.id) {
          Navigator.pushNamed(
            context,
            AppRoutes.myMeltedUser,
            arguments: MeltedUserAgurment(
              userId: thoughtModel.user!,
              conversationID: "",
              melted: melted,
            ),
          );
        }
      },
      child: Row(
        children: [
          ProfilePhoto(
            verfly: false,
            size: 40,
            photourl: thoughtModel.userData?.metal?.img ?? '',
          ),
          const Gap(10),
          _buildUserDetails(),
          const Spacer(),
          if (userdata?.id != thoughtModel.user || melted)
            _buildOptionsButton(context),
        ],
      ),
    );
  }

  Column _buildUserDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            TextView(text: thoughtModel.userData?.username ?? ''),
            const Gap(5),
            if (thoughtModel.userData?.verification ?? false)
              Assets.icons.checkVerified.svg(height: 16),
          ],
        ),
        Text(
          formatToWhatsAppChatTime(thoughtModel.created_at!),
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildOptionsButton(BuildContext context) {
    return IconButton(
      onPressed: () {
        showModalBottomSheet(
          backgroundColor: Colors.white,
          context: context,
          builder: (BuildContext context) => _buildOptionsBottomSheet(context),
        );
      },
      icon: const Icon(Icons.more_vert),
    );
  }

  Widget _buildOptionsBottomSheet(BuildContext context) {
    return SafeArea(
      child: Wrap(
        children: <Widget>[
          ListTile(
            title: const Text('Block Metal'),
            onTap: () {
              _showDialog(
                context,
                _blockDialog(context, thoughtModel, ref),
              );
            },
          ),
          ListTile(
            title: const Text('Block and Report'),
            onTap: () {
              _showDialog(
                context,
                _blockAndReportDialog(context, thoughtModel, ref),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReactionsRow() {
    return Row(
      children: [
        for (var reaction in thoughtModel.reactions!)
          Text(
            '${unicodeToEmoji(reaction.reaction ?? '')}',
          ),
       // Text(thoughtModel.reactions![0].users![0].userName!)
      ],
    );
  }

  Widget _buildReactionsSelector() {
    return Positioned(
      bottom: 40,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.metalTabBg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _buildReactionIcons(),
        ),
      ),
    );
  }

  List<Widget> _buildReactionIcons() {
    return [
      ReactionIcon(
        icon: '👍',
        reaction: 'like',
        onTap: () => _selectReaction('👍'),
      ),
      ReactionIcon(
        icon: '❤️',
        reaction: 'love',
        onTap: () => _selectReaction('❤️'),
      ),
      ReactionIcon(
        icon: '😮',
        reaction: 'wow',
        onTap: () => _selectReaction('😮'),
      ),
      ReactionIcon(
        icon: '😂',
        reaction: 'haha',
        onTap: () => _selectReaction('😂'),
      ),
      ReactionIcon(
        icon: '😢',
        reaction: 'sad',
        onTap: () => _selectReaction('😢'),
      ),
      ReactionIcon(
        icon: '😡',
        reaction: 'angry',
        onTap: () => _selectReaction('😡'),
      ),
    ];
  }

  void _showDialog(BuildContext context, Widget dialogContent) {
    showDialog(
      context: context,
      builder: (BuildContext context) => CustomDialog(content: dialogContent),
    );
  }

  String unicodeToEmoji(String unicodeString) {
    // Split the Unicode string on hyphen to handle multiple code points
    List<String> unicodeList = unicodeString.split('-');

    // Convert each Unicode string to an emoji character
    String emoji = '';
    for (String unicode in unicodeList) {
      try {
        // Convert Unicode string to an integer
        int codePoint = int.parse(unicode, radix: 16);
        // Append the emoji character to the result
        emoji += String.fromCharCode(codePoint);
      } catch (e) {
        // Handle any errors in conversion
        print('Error converting Unicode $unicode: $e');
      }
    }

    return emoji;
  }

  Widget _blockDialog(BuildContext context, ThoughtModel data, WidgetRef ref) {
    return _buildDialog(
      context: context,
      data: data,
      ref: ref,
      isReport: false,
    );
  }

  Widget _blockAndReportDialog(
      BuildContext context, ThoughtModel data, WidgetRef ref) {
    return _buildDialog(
      context: context,
      data: data,
      ref: ref,
      isReport: true,
    );
  }

  Widget _buildDialog({
    required BuildContext context,
    required ThoughtModel data,
    required WidgetRef ref,
    bool isReport = false,
  }) {
    TextEditingController _controller = TextEditingController();
    return Column(
      children: [
        const Gap(38),
        SvgPicture.asset(
          Assets.icons.meltedMetalsSmileyXEyes.path,
          height: 45,
          width: 45,
        ),
        const Gap(15),
        TextView(
          text: isReport ? 'Block and Report this User' : 'Block this User',
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
        const Gap(8),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: TextView(
            text:
                'This user will not be able to see or interact with your posts and messages. They will not be notified.',
            maxLines: 3,
            textAlign: TextAlign.center,
          ),
        ),
        const Gap(8),
        if (isReport)
          EditFormField(
            controller: _controller,
            hint: 'Reason for reporting',
            maxLines: 5,
            keyboardType: TextInputType.name,
            minLines: 5,
            validator: Validators.validateString(),
          ),
        const Gap(15),
        const Gap(38),
        BaseButton(
            buttonText: "Block ${data.userData!.username}",
            onPressed: () {
              ref
                  .read(blockUserProvider.notifier)
                  .BlockUser(data.userData!.username!, data.user!);
              ref.read(getAllUserProvider.notifier).removeUser(data.user!);
              Navigator.pop(context);
              Navigator.pop(context);
            }),
        const Gap(23),
        TextView(
          text: "Cancel",
          fontSize: 16,
          fontWeight: FontWeight.w500,
          onTap: () => Navigator.pop(context),
        ),
        const Gap(21),
        const Gap(24),
      ],
    );
  }
}

class ReactionIcon extends StatelessWidget {
  final String icon;
  final String reaction;
  final VoidCallback onTap;

  const ReactionIcon({
    Key? key,
    required this.icon,
    required this.reaction,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 24),
          ),
          Text(
            reaction,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
