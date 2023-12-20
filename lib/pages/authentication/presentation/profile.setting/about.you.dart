import 'package:bottom_picker/bottom_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/pages/authentication/models/passion.card.model.dart';
import 'package:metal/pages/authentication/presentation/profile.setting/more.about.you.dart';
import 'package:metal/pages/authentication/presentation/widget/create.profile.header1.dart';
import 'package:metal/pages/authentication/presentation/widget/create.profile.header2.dart';
import 'package:metal/res/colors/cr_colors.dart';
import 'package:metal/utils/screen.size.dart';
import 'package:metal/widgets/agree.click.dart';
import 'package:metal/widgets/button/buttons.dart';
import 'package:metal/widgets/dropdown/metal.dropdownMutipleSelection.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';

import '../../../../widgets/dropdown/metal.dropdown.dart';
import '../widget/passions.card.dart';

class AboutYouPage extends ConsumerStatefulWidget {
  AboutYouPage({Key? key}) : super(key: key);
  static const name = 'aboutYou';
  static const route = '$name';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AboutYouPageState();
}

class _AboutYouPageState extends ConsumerState<AboutYouPage> {
  String? maritalStatus;
  String? religion;
  String? profession;
  String? language;
  @override
  Widget build(BuildContext context) {
    return BaseScreen(
        bgImage: Assets.images.bg2.path,
        appBarEnabled: false,
        Header: 'About You',
        authFlow: true,
        body: SingleChildScrollView(
          child: Column(
            children: [
              CreateProfileHeader2(
                  path: Assets.images.aboutYou.path,
                  title: "Just a little more about you",
                  subtitle:
                      "The more we know you, the easier it is to match you!"),
              Gap(40.h),
              MentalDropdown(
                items: const [
                  "Single",
                  "Married",
                  "Divorced",
                  "Widowed",
                  "Separated",
                  "Civil Union",
                  "Annulled",
                  "Common-Law ",
                  "Other",
                ],
                onChanged: (String? value) {
                  maritalStatus = value;
                },
                prefixIcon: SvgPicture.asset(
                  Assets.icons.single.path,
                  height: 24,
                  width: 24,
                ),
                value: maritalStatus,
                hint: "Please Select",
                floatingLabel: "Marital Status",
              ),
              Gap(22.h),
              MentalDropdown(
                items: const [
                  "Christianity",
                  "Hinduism",
                  "Indigenous religion",
                  "Traditional religion",
                  "Others (Please specify)",
                ],
                onChanged: (String? value) {
                  religion = value;
                },
                prefixIcon: SvgPicture.asset(
                  Assets.icons.christianity.path,
                  height: 24,
                  width: 24,
                ),
                value: religion,
                hint: "Please Select",
                floatingLabel: "Religon",
              ),
              Gap(22.h),
              MentalDropdown(
                items: const [
                  "Doctor",
                  "Nurse",
                  "Dentist",
                  "Therapist",
                  "Paramedic",
                  "Web Developer",
                  "Technology Consultant",
                  "Business Consultant",
                  "Entrepreneur",
                  "Finance Professional",
                  "Accountant",
                  "Teacher",
                  "College Professor",
                  "Education Consultant",
                  "School Administrator",
                  "Banker",
                  "Professional",
                  "Artist",
                  "Writer",
                  "Graphic Designer",
                  "Photographer",
                  "Content Developer",
                  "Unemployed",
                  "Marketer",
                  "Public Relations Specialist",
                  "Social Media Manager",
                  "Nanny",
                  "Scientist",
                  "Researcher",
                  "Medical Professional",
                  "Lawyer",
                  "Legal Professional",
                  "Engineering",
                  "Technician",
                  "Fitness Trainer",
                  "Nutritionist",
                  "Military",
                  "Programmer",
                  "Police Officer",
                  "Firefighter",
                  "Social Worker",
                  "Chef",
                  "Bartender",
                  "Event Planner",
                  "Hotel Manager",
                  "Store Management",
                  "Factory Production",
                  "Actor/Actress",
                  "Musician",
                  "Film Producer",
                  "Screenwriter",
                  "Small Business Owner",
                  "Startup Founder",
                  "Consultant",
                  "Government Official",
                  "Electrician",
                  "Plumber",
                  "Carpenter",
                  "Welder",
                  "Mechanic",
                  "Machinist",
                  "Construction Worker",
                  "Stay-at-home Mom",
                  "Stay-at-home Dad",
                  "Undergraduate Student",
                  "Painter",
                  "Postgraduate Student",
                  "Landscaper",
                  "Contractor",
                  "Mason",
                  "Auto Body Technician",
                  "Locksmith",
                  "Heavy Equipment Operator",
                  "Other, please specify"
                ],
                onChanged: (String? value) {
                  profession = value;
                },
                prefixIcon: SvgPicture.asset(
                  Assets.icons.profession.path,
                  height: 24,
                  width: 24,
                ),
                value: profession,
                hint: "Please Select",
                floatingLabel: "Profession",
              ),
              Gap(22.h),
              MentalDropdownMutipleSelection(
                items: [
                  "Mandarin Chinese",
                  "Spanish",
                  "English",
                  "Hindi",
                  "Arabic",
                  "Bengali",
                  "Portuguese",
                  "Russian",
                  "Urdu",
                  "French",
                  "Indonesian",
                  "German",
                  "Japanese",
                  "Swahili",
                  "Turkish",
                  "Telugu",
                  "Marathi",
                  "Tamil",
                  "Vietnamese",
                  "Korean",
                  "Italian",
                  "Tagalog (Filipino)",
                  "Yoruba",
                  "Thai",
                  "Persian (Farsi)",
                  "Malay",
                  "Polish",
                  "Ukrainian",
                  "Dutch",
                  "Javanese",
                  "Gujarati",
                  "Kannada",
                  "Romanian",
                  "Odia (Oriya)",
                  "Burmese",
                  "Malayalam",
                  "Bhojpuri",
                  "Hausa",
                  "Punjabi",
                  "Sundanese",
                  "Nepali",
                  "Sinhala",
                  "Uzbek",
                  "Amharic",
                  "Fula",
                  "Igbo",
                  "Maithili",
                  "Oromo",
                  "Serbo-Croatian",
                  "Azerbaijani",
                  "Hebrew",
                  "Others, please specify"
                ],
                onChanged: (String? value) {
                  setState(() {
                    language = value;
                  });
                },
                prefixIcon: SvgPicture.asset(
                  Assets.icons.profession.path,
                  height: 24,
                  width: 24,
                ),
                value: language,
                hint: "Please Select",
                floatingLabel: "language",
              ),
              Gap(20),
              BaseButton(
                buttonText: "Next 4/5",
                onPressed: _onNextPressed,
              ),
            ],
          ),
        ));
  }

  void _onNextPressed() {
    context.pushNamed(MoreAboutYouPage.name);
  }
}
