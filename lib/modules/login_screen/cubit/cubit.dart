import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialmediaproject/modules/login_screen/cubit/states.dart';

import '../../../shared/components/constants.dart';
import '../../cubit/cubit.dart';
import '../../cubit/states.dart';

class SocialLoginCubit extends Cubit<SocialLoginStates> {
  SocialLoginCubit() : super(SocialLoginInitialState());

  static SocialLoginCubit get(BuildContext context) => BlocProvider.of(context);

  bool isPassword = true;
  IconData suffix = Icons.visibility_outlined;

  void userLogin({
    required String email,
    required String password,
    required BuildContext context,
  }) {
    emit(SocialLoginLoadingState());

    print('📨 Sending login request...');
    print('Email: $email');
    print('Password: $password');

    FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    ).then((value) {
      print(value.user?.email);
      print(value.user?.uid);
      uId = value.user!.uid; // Set uId after successful login
      resetAndInitializeUser(context);
      emit(SocialLoginSuccessState(value.user!.uid));
    }).catchError((error) {
      print("Login error: $error");
      if (error is FirebaseAuthException) {
        String errorMessage;
        switch (error.code) {
          case 'user-not-found':
            errorMessage = 'No user found for that email.';
            break;
          case 'wrong-password':
            errorMessage = 'Incorrect password.';
            break;
          case 'invalid-email':
            errorMessage = 'The email address is not valid.';
            break;
          default:
            errorMessage = 'Login failed: ${error.message}';
        }
        emit(SocialLoginErrorState(errorMessage));
      } else {
        emit(SocialLoginErrorState('An unexpected error occurred.'));
      }
    });
  }

  void ChangePasswordVisibility() {
    isPassword = !isPassword;
    suffix = isPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined;
    emit(SocialLoginChangePasswordVisibilityState());
  }
  void resetAndInitializeUser(BuildContext context) {
    print("🔄 Resetting and initializing user data...");

    // Clear old data
    SocialCubit.get(context).userModel = null;
    SocialCubit.get(context).posts = [];
    SocialCubit.get(context).likes = [];

    // Emit reset state
    emit(SocialLoginInitialState());

    // Fetch new user data (uId should already be set)
    if (uId != null && uId!.isNotEmpty) {
      SocialCubit.get(context).getUserData();
      SocialCubit.get(context).getPosts();
    }
  }
}