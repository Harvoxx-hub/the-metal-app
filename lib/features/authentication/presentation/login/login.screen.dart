import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
 
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';

import 'package:metal/base/page/base_page_state.dart';

import 'package:metal/core/utils/input/validators/validators.dart';

import 'package:metal/features/authentication/presentation/signup/verfication.argument.dart';
import 'package:metal/features/authentication/presentation/signup/verfication.page.dart';

import 'package:metal/features/authentication/provider/login.notifier.dart';

import 'package:metal/gen/assets.gen.dart';

import 'package:metal/res/res.dart';
import 'package:metal/route/routes.dart';
import 'package:metal/widgets/agree.click.dart';

import 'package:metal/widgets/button/buttons.dart';
import 'package:metal/widgets/text.field/edit.from.field.dart';
import 'package:metal/widgets/text_views.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});
  static const name = 'loginPage';
  static const route = '/$name';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _GettingStartedPageState();
}

class _GettingStartedPageState extends ConsumerState<LoginPage> {
  static final GlobalKey<FormState> _form = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final bool _autoValidate = false;

  @override
  Widget build(
    BuildContext context,
  ) {
    final LoginState = ref.watch(loginProvider);
    ref.listen<LoginStates>(loginProvider, (prev, current) {
      if (current.isSuccess) {
        current.data!.profile_updated ?? false
            ? Navigator.pushNamed(
                context,
                AppRoutes.dashboardPage,
              )
            : Navigator.pushNamed(
                context,
                AppRoutes.welcomePage,
              );
      }
      if (current.isError) {
       
        if (current.errorMessage == "Account not activated") {
          Navigator.pushNamed(context, AppRoutes.notificationEnablePage,
              arguments: VerificationSentArgument(
                  type: RouteFrom.AccountSetting,
                  code: current.errorData!["OTP"],
                  uuid: current.errorData!["UUID"],
                  phoneNumber: current.errorData!["phone"]));
        }
      }
    });
    return BaseScreen(
        // isLoading: _LoginState.status == StateStatus.loading,
        authFlow: true,
        Header: "Login",
        bgImage: Assets.images.bg2.path,
        appBarEnabled: false,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Gap(52),
              Image.asset(
                Assets.images.logo.path,
                height: 53,
                width: 53,
              ),
              const Gap(22),
              const TextView(
                  text: " 👋 Welcome Back",
                  fontSize: 22,
                  fontWeight: FontWeight.w500),
              const Gap(8),
              const TextView(
                  text: "Let’s log you in, you’ve been missed!",
                  fontSize: 16,
                  fontWeight: FontWeight.w400),
              const Gap(52),
              Form(
                  key: _form,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      EditFormField(
                        floatingLabel: 'Email address/Phone number/User name',
                        label: 'Enter your email address',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        autoValidate: _autoValidate,
                        prefixWidget: SvgPicture.asset(
                          Assets.icons.user.path,
                          height: 24,
                          width: 24,
                        ),
                        validator: Validators.validateEmail(),
                      ),
                      const Gap(16),
                      EditFormField(
                        floatingLabel: 'Password',
                        label: '*************',
                        controller: _passwordController,
                        keyboardType: TextInputType.visiblePassword,
                        autoValidate: _autoValidate,
                        prefixWidget: SvgPicture.asset(
                          Assets.icons.passwordIcon.path,
                          height: 24,
                          width: 24,
                        ),
                        validator: Validators.validatePlainPassword(),
                      ),
                      const Gap(16),
                      CustomCheckWidget(
                        title: 'Keep me logged in',
                        initialValue: false,
                        onChanged: (bool value) {
                          print('Value changed to $value');
                        },
                      ),
                      const Gap(64),
                    ],
                  )),
              BaseButton(
                buttonText: "Login",
                loading: LoginState.isLoading,
                onPressed: () {
                  ref.read(loginProvider.notifier).login(
                        email: _emailController.text,
                        password: _passwordController.text,
                      );
                },
              ),
              const Gap(31),
              TextView(
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.forgetPassword,
                  );
                },
                text: "Forgot Password?",
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              const Gap(14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const TextView(
                    text: "Not a User?",
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.metaltext,
                  ),
                  TextView(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.accountSetting,
                      );
                    },
                    text: "  Create account",
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ],
              )
            ],
          ),
        ));
  }
}
