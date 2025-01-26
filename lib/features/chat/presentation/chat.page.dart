import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

import 'package:metal/features/chat/presentation/widget/chat.list.dart';

import 'package:metal/gen/assets.gen.dart';

import 'package:metal/widgets/text.field/edit.from.field.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 140,
          width: double.infinity,
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(0.00, -1.00),
                end: Alignment(0, 1),
                colors: [Color(0xFFDB217A), Color(0xFFF00E3E)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(35),
                bottomRight: Radius.circular(35),
              )),
          child: Padding(
            padding: const EdgeInsets.only(left: 24.0, right: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EditFormField(
                  label: 'Search',
                  keyboardType: TextInputType.emailAddress,
                  autoValidate: false,
                  prefixWidget: SvgPicture.asset(
                    Assets.icons.chatsSearch.path,
                    height: 24,
                    width: 24,
                  ),
                  radius: 34,
                ),
                const Gap(10),
           
              ],
            ),
          ),
        ),
        const Gap(26),
        const Expanded(child: ChatListWidget())
      ],
    );
  }
}
