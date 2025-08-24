import 'package:animated_conditional_builder/animated_conditional_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialmediaproject/shared/components/compnents.dart';
import '../../layout/social_layout.dart';
import '../../modules/register/cubit/cubit.dart';
import '../cubit/cubit.dart';
import 'cubit/states.dart';


class RegisterScreen extends StatelessWidget {
  var formKey = GlobalKey<FormState>();
  var namecontroller = TextEditingController();
  var emailcontroller = TextEditingController();
  var phonecontroller = TextEditingController();
  var passwordcontroller = TextEditingController();

  RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isPassword;
    return BlocProvider(
      create: (BuildContext context) => SocialRegisterCubit(),
      child: BlocConsumer<SocialRegisterCubit , SocialRegisterStates>(
          listener: (context , state)
          {
            if (state is SocialCreateUserSuccessState)
            {
              SocialCubit.get(context).getUserData();
              navigateAndFinish(
                  context,
                  SocialLayout());
            }
          }
 ,
          builder: (context , state)
          {
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
                            "Register to our Application",
                            style: Theme.of(
                              context,
                            ).textTheme.headlineSmall?.copyWith(
                              color: SocialCubit.get(context).isDark ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Register now to Communicate with your friends",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          SizedBox(height: 30.0),
                          defaultFormField(
                            context: context,
                            textColor: SocialCubit.get(context).isDark ? Colors.white : Colors.black,


                            controller: namecontroller,
                            type: TextInputType.name,
                            iconColor: SocialCubit.get(context).isDark ? Colors.white : Colors.black,
                            validate: (String? value) {
                              if (value!.isEmpty) {
                                return 'Name must not be empty';
                              }
                              return null;
                            },
                            label: 'Name',
                            prefix: Icons.person,
                            obsecure: isPassword = false,
                              //textColor: SocialCubit.get(context).isDark ? Colors.black : Colors.white

                          ),
                          SizedBox(height: 15.0),
                          defaultFormField(
                            context: context,
                            textColor: SocialCubit.get(context).isDark ? Colors.white : Colors.black,
                            iconColor: SocialCubit.get(context).isDark ? Colors.white : Colors.black,

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
                              //textColor: SocialCubit.get(context).isDark ? Colors.black : Colors.white

                          ),
                          SizedBox(height: 15.0),
                          defaultFormField(
                            context: context,
                            textColor: SocialCubit.get(context).isDark ? Colors.white : Colors.black,
                            iconColor: SocialCubit.get(context).isDark ? Colors.white : Colors.black,

                            controller: passwordcontroller,
                            type: TextInputType.visiblePassword,
                            suffix: SocialRegisterCubit.get(context).suffix,
                            isPassword: SocialRegisterCubit.get(context).isPassword,
                            suffixPressed: () {
                              SocialRegisterCubit.get(
                                context,
                              );
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
                          SizedBox(height: 15.0),
                          defaultFormField(
                            context: context,
                            textColor: SocialCubit.get(context).isDark ? Colors.white : Colors.black,
                            iconColor: SocialCubit.get(context).isDark ? Colors.white : Colors.black,

                            controller: phonecontroller,
                            type: TextInputType.phone,
                            validate: (String? value) {
                              if (value!.isEmpty) {
                                return 'Phone must not be empty';
                              }
                              return null;
                            },
                            label: 'Phone',
                            prefix: Icons.phone,
                            obsecure: false,
                            //textColor: SocialCubit.get(context).isDark ? Colors.black : Colors.white
                          ),
                          SizedBox(height: 30.0),
                          AnimatedConditionalBuilder(
                            condition: state is! SocialRegisterLoadingState,
                            builder:
                                (context) => defaultButton(
                              function: () {
                                if (formKey.currentState!.validate()) {
                                  SocialRegisterCubit.get(context).userRegister(
                                    name: namecontroller.text.trim(),
                                    email: emailcontroller.text.trim(),
                                    password: passwordcontroller.text,
                                    phone: phonecontroller.text.trim(),
                                    context: context,
                                  );
                                }
                              },
                              text: 'Register',

                              isUpperCase: true,
                              background: Colors.blueGrey,
                            ),
                            fallback:
                                (context) =>
                                Center(child: CircularProgressIndicator()),
                          ),

                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
      ),
    );
  }
}
