import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialmediaproject/models/user_model.dart';
import 'package:socialmediaproject/modules/cubit/cubit.dart';
import 'package:socialmediaproject/modules/register/cubit/states.dart';

class SocialRegisterCubit extends Cubit<SocialRegisterStates> {
  SocialRegisterCubit() : super(SocialRegisterInitialState());

  static SocialRegisterCubit get(BuildContext context) => BlocProvider.of(context);

  bool isPassword = true;
  IconData suffix = Icons.visibility_outlined;

  void userRegister({
    required String email,
    required String password,
    required String phone,
    required String name,
    BuildContext? context,
  }) {
    emit(SocialRegisterLoadingState());

    FirebaseAuth.instance
        .createUserWithEmailAndPassword(
      email: email,
      password: password,
    )
        .then((value) {
      print("✅ Registered: ${value.user?.email}");
      print("UID: ${value.user?.uid}");

      userCreate(
        email: email,
        phone: phone,
        name: name,
        uId: value.user!.uid,
        isEmailVerified: value.user!.emailVerified,
        context: context!,

      );
    }).catchError((error) {
      emit(SocialRegisterErrorState(error.toString()));
    });
  }

  void changePasswordVisibility() {
    isPassword = !isPassword;
    suffix = isPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined;
    emit(SocialRegisterChangePasswordVisibilityState());
  }

// In your registration cubit
  void userCreate({
    required String name,
    required String email,
    required String phone,
    required String uId,
    BuildContext? context,
    required bool isEmailVerified,
  }) {
    // Get the current user's verification status from Firebase Auth
    bool isEmailVerified = FirebaseAuth.instance.currentUser?.emailVerified ?? false;

    SocialUserModel model = SocialUserModel(
      name: name,
      email: email,
      phone: phone,
      uId: uId,
      bio: 'write your bio...',
      image: 'https://cdn-icons-png.flaticon.com/512/3177/3177440.png',
      backgrounder: 'https://img.freepik.com/free-photo/white-crumpled-paper-texture-background_1373-159.jpg?w=360',
      isEmailVerified: isEmailVerified, // Set from Firebase Auth
    );

    FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .set(model.toMap())
        .then((value) {
      emit(SocialCreateUserSuccessState());
        }).catchError((error) {
      emit(SocialCreateUserErrorState(error.toString()));
    });
  }
}