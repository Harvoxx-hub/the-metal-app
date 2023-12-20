import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/gen/assets.gen.dart';
import 'package:metal/pages/authentication/presentation/login/forgot_password.screen.dart';
import 'package:metal/pages/authentication/presentation/signup/account.setting.dart';
import 'package:metal/pages/dashboard.dart/dashboard.dart';
import 'package:metal/res/res.dart';
import 'package:metal/widgets/agree.click.dart';
import 'package:metal/widgets/app.text.field.dart';
import 'package:metal/widgets/button/buttons.dart';
import 'package:metal/widgets/text_views.dart';

import '../../../../utils/input/validators/email_validator.dart';
import '../../../../utils/input/validators/validators.dart';
import '../../../../widgets/text.field/edit.from.field.dart';

class LoginPage extends ConsumerStatefulWidget {
  LoginPage({Key? key}) : super(key: key);
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
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
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
              Gap(52.h),
              Image.asset(
                Assets.images.logo.path,
                height: 53.h,
                width: 53.w,
              ),
              Gap(22.h),
              TextView(
                  text: " 👋 Welcome Back",
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w500),
              Gap(8.h),
              TextView(
                  text: "Let’s log you in, you’ve been missed!",
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400),
              Gap(52.h),
              Form(
                  key: _form,
                  child: Column(
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
                        // validator: EmailValidator.validate(email),
                        radius: 10,
                        // fillColor: AppColors.appGrey,
                      ),
                      Gap(16.h),
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
                        // validator: EmailValidator.validate(email),
                        radius: 10,
                      ),
                      Gap(16.h),
                      CustomCheckWidget(
                        title: 'Keep me logged in',
                        initialValue: false,
                        onChanged: (bool value) {
                          print('Value changed to $value');
                        },
                      ),
                      Gap(64.h),
                    ],
                  )),
              BaseButton(
                buttonText: "Login",
                onPressed: () {
                  context.pushNamed(DashboardPage.name);
                },
                // enabled: _emailController.text.isNotEmpty &&
                //     _passwordController.text.isNotEmpty,
              ),
              Gap(31.h),
              TextView(
                onTap: () {
                  context.pushNamed(ForgetPasswordPage.name);
                },
                text: "Forgot Password?",
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
              Gap(14.sp),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextView(
                    text: "Not a User?",
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: AppColors.metaltext,
                  ),
                  TextView(
                    onTap: () {
                      context.pushNamed(AccountSetting.name);
                    },
                    text: "  Create account",
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ],
              )
            ],
          ),
        ));
  }
//   void _login(WidgetRef ref) {
//   if (_form.currentState!.validate()) {
//     // Move the `_login()` method outside of the build() method.
//     _loginOnPressed(ref);
//   }
// }

// void _loginOnPressed(WidgetRef ref) {
//   ref.read(loginControllerProvider.notifier).login(
//       email: _emailController.text,
//       password: _passwordController.text,
//     );
// }
}
