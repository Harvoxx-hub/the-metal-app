// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flentoapp/base/bloc/base_bloc.dart';
// import 'package:flentoapp/build_type.dart';
// import 'package:flentoapp/providers/provider_injector.dart';
// import 'package:google_sign_in/google_sign_in.dart';

// typedef AuthSignInData = Pair<UserCredential, AuthCredential>;

// mixin SocialAuthMixin {
//   final _googleSignIn = GoogleSignIn(
//     clientId: getGoogleClientId(),
//     // ignore: prefer - trailing - comma
//     scopes: [
//       'email',
//       'profile',
//       'openid',
//     ],
//   );

//   void initProxy() {}
//   final _auth = ProviderInjector.instance.auth;

//   Future<AuthSignInData?> authWithGoogle() async {
//     final googleUser = await _googleSignIn.signIn();
//     if (googleUser != null) {
//       final googleAuth = await googleUser.authentication;
//       final credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );

//       final user = await FirebaseAuth.instance.signInWithCredential(credential);

//       log.i("I am updating token");

//       _auth.updateToken((await FirebaseMessaging.instance.getToken()) ?? "");

//       return Pair(user, credential);
//     }

//     return null;
//   }

//   Future<UserCredential> authWithApple() async {
//     final provider = AppleAuthProvider()
//       ..addScope('email')
//       ..addScope('fullName');

//     _auth.updateToken((await FirebaseMessaging.instance.getToken()) ?? "");

//     return FirebaseAuth.instance.signInWithAuthProvider(provider);
//   }
// }
