import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
 
import 'package:metal/features/chat/presentation/widget/chat.list.dart';
 
import 'package:metal/features/chat/presentation/widget/status/status.widget.dart';
import 'package:metal/gen/assets.gen.dart';
 
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';
import 'package:metal/widgets/text_views.dart';
 

class ChatPage extends ConsumerStatefulWidget {
  ChatPage({super.key});

 
 
  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    // if (widget._converWidgetList.isEmpty) getMoreConverWidgetList();
    // registerConverUpdate();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 240.h,
              width: double.infinity,
              decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment(0.00, -1.00),
                    end: Alignment(0, 1),
                    colors: [Color(0xFFDB217A), Color(0xFFF00E3E)],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(35.sp),
                    bottomRight: Radius.circular(35.sp),
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
                    Gap(10.h),
                    TextView(
                      text: "My Metals",
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.metalWhite,
                    ),
                    Gap(10.h),
                    StatusWidget()
                  ],
                ),
              ),
            ),
            Gap(26.h),
         ChatListWidget()
               ],
        ),
      ],
    );
  }
 }
