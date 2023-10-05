import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:metal/base/page/base_page_state.dart';
import 'package:metal/gen/assets.gen.dart';
 
 

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

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
 
  bool _autoValidate = false;

@override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
 }
  @override
  Widget build(BuildContext context,) {
  //  final _LoginState = ref.watch(loginControllerProvider);
    

    // ref.listen<LoginState>(
    //   loginControllerProvider,
    //   (_, state) => {
    //     if(state.status == StateStatus.loaded)
    //   context.pushReplacementNamed(Dashboard.name)
    //   },
    // );


    return BaseScreen(
       // isLoading: _LoginState.status == StateStatus.loading,
       authFlow: true,
       bgImage: Assets.images.bg2.path,
        appBarEnabled: false,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header(
            //     title: 'Hello welcome back',
            //     subTitle: 'Please enter you email and password to sign-in'),
            // Gap(20),
            // Form(
            //   key: _form,
            //   child: Column(
            //     crossAxisAlignment: CrossAxisAlignment.start,
            //     children: [
            //       Gap(10.h),
            //       EditFormField(
            //         floatingLabel: 'Email',
            //         label: 'Enter your email address',
            //         controller: _emailController,
            //         keyboardType: TextInputType.emailAddress,
            //         autoValidate: _autoValidate,
            //         validator: Validators.validateString(),
            //         radius: 10,
            //         fillColor: AppColors.appGrey,
            //       ),
            //       Gap(30.h),
            //       EditFormField(
            //         floatingLabel: 'Password',
            //         label: 'Enter your Password',
            //         controller: _passwordController,
            //         keyboardType: TextInputType.visiblePassword,
            //         autoValidate: _autoValidate,
            //         obscureText: true,
            //         validator: Validators.validatePlainPassword(),
            //         fillColor: AppColors.appGrey,
            //         radius: 10,
            //       ),
            //       Gap(16.h),
            //     ],
            //   ),
            // ),
            // Gap(20.h),
            // Align(
            //   alignment: Alignment.center,
            //   child: TextView(
            //     text: 'Forgot Password?',
            //     fontSize: 14.sp,
            //     onTap: () {
            //       // context.pushNamed(ResetPassworPage.name);
            //     },
            //   ),
            // ),
            // Gap(340.h),
            // BaseButton(
            //     buttonText: 'Contuine',
            //     onPressed: (){ _login( ref);})
         
          ],
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
