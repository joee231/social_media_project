import 'package:animated_conditional_builder/animated_conditional_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialmediaproject/modules/login_screen/cubit/cubit.dart';
import 'package:socialmediaproject/modules/login_screen/cubit/states.dart';
import 'package:socialmediaproject/modules/register/register_screen.dart';
import 'package:socialmediaproject/shared/components/compnents.dart';
import 'package:socialmediaproject/shared/network/local/cash_helper.dart';

import '../../layout/social_layout.dart';
import '../cubit/cubit.dart';

class SocialLoginScreen extends StatelessWidget {
  var formKey = GlobalKey<FormState>();
  var emailcontroller = TextEditingController();
  var passwordcontroller = TextEditingController();

  SocialLoginScreen({super.key});
  @override
  Widget build(BuildContext context) {
    bool isPassword;
    return BlocProvider(
      create: (BuildContext context) => SocialLoginCubit(),
      child: BlocConsumer<SocialLoginCubit , SocialLoginStates>(
        listener: (context , state)
        {
          if (state is SocialLoginSuccessState) {
          CashHelper.saveData(
                key: 'uID',
                value: state.uId
            ).then((value)
            {
              navigateAndFinish(
                context,
                SocialLayout(),
              );
            });
          } else if (state is SocialLoginErrorState) {
            // Handle login error
            showToast(
              text: state.error,
              state: ToastStates.ERROR,
            );
          }
        },
        builder: (context , state){
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Login to Your Account",
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(
                             color: SocialCubit.get(context).isDark ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Login now to Communicate with your friends",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        SizedBox(height: 30.0),
                        defaultFormField(
                            textColor: SocialCubit.get(context).isDark ? Colors.white : Colors.black,
                            iconColor: SocialCubit.get(context).isDark ? Colors.white : Colors.black,
                            context: context,
                          controller: emailcontroller,
                          type: TextInputType.emailAddress,
                          validate: (String? value) {
                            if (value!.isEmpty) {
                              return 'Email must not be empty';
                            }
                            return null;
                          },
                          label: 'Email Address',
                          prefix: Icons.email_outlined,
                          obsecure: isPassword = false,

                        ),
                        SizedBox(height: 15.0),
                        defaultFormField(
                          context: context,
                          textColor: SocialCubit.get(context).isDark ? Colors.white : Colors.black,
                          iconColor: SocialCubit.get(context).isDark ? Colors.white : Colors.black,
                          controller: passwordcontroller,
                          type: TextInputType.visiblePassword,
                          suffix: SocialLoginCubit.get(context).suffix,
                          isPassword: SocialLoginCubit.get(context).isPassword,
                          suffixPressed: () {
                            SocialLoginCubit.get(context).ChangePasswordVisibility();
                          },
                          onSubmitted: (value) {
                            if (formKey.currentState!.validate()) {
                              //SocialLoginCubit.get(context).userLogin(
                              /*                            email: emailcontroller.text.trim(),
                                password: passwordcontroller.text
                              );*/
                            }
                          },
                          validate: (String? value) {
                            if (value!.isEmpty) {
                              return 'Password must not be empty';
                            }
                            return null;
                          },
                          label: 'password',
                          prefix: Icons.lock_outline,

                          obsecure: null,
                          //textColor: SocialCubit.get(context).isDark ? Colors.black : Colors.white
                        ),
                        SizedBox(height: 30.0),
                        AnimatedConditionalBuilder(
                          condition: state is! SocialLoginLoadingState,
                          builder:
                              (context) => defaultButton(
                            function: () {
                              if (formKey.currentState!.validate()) {
                                SocialLoginCubit.get(context).userLogin(
                                email: emailcontroller.text.trim(),
                                password: passwordcontroller.text,
                                context: context,
                              );
                              }
                            },
                            text: 'Login',

                            isUpperCase: true,
                            background: Colors.blueGrey,
                          ),
                          fallback:
                              (context) =>
                              Center(child: CircularProgressIndicator()),
                        ),
                        SizedBox(height: 30.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("don't have an account?"),
                            defaultTextButton(
                              function: ()
                              {
                                navigateTo(
                                  context,
                                  RegisterScreen(),
                                );
                              },
                              text: 'Register',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
