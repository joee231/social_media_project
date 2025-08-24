import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialmediaproject/modules/cubit/cubit.dart';
import 'package:socialmediaproject/modules/cubit/states.dart';
import 'package:socialmediaproject/shared/components/compnents.dart';
import 'package:socialmediaproject/shared/style/pasticon_button.dart';

class EditProfileScreen extends StatelessWidget {
  var  nameController = TextEditingController();
  var bioController = TextEditingController();
  var phoneController = TextEditingController();

  EditProfileScreen({super.key});




  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SocialCubit, SocialStates>(
      listener: (context, state) {
        if (state is SocialUpdateUserSuccessState) {
          showToast(
            text: 'Profile updated successfully',
            state: ToastStates.SUCCESS,
          );
        }
      },
      builder: (context, state) {
        var userModel = SocialCubit.get(context).userModel;
        var profileImage = SocialCubit.get(context).profileImage;
        var coverImage = SocialCubit.get(context).coverImage;

        nameController.text = userModel!.name;
        bioController.text = userModel.bio;
        phoneController.text = userModel.phone;


        return Scaffold(
          appBar: defaultAppBar(
            context: context,
            title: 'edit profile',
            actions: [
              defaultTextButton(
                function: ()
                {
                  SocialCubit.get(context).updateUser(
                    name: nameController.text,
                    bio: bioController.text,
                    phone: phoneController.text,


                  );
                  SocialCubit.get(context).getProfileImage;
                  SocialCubit.get(context).getCoverImage;

                },
                text: 'update',
                color: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  if (state is SocialUpdateUserLoadingState)
                    LinearProgressIndicator(
                      color: Colors.blueGrey,
                      backgroundColor: Colors.grey[300],
                    ),
                    SizedBox(
                    height: 10.0,
                    ),

                    SizedBox(
                    height: 200,
                    child: Stack(
                      alignment: AlignmentDirectional.bottomCenter,
                      children: [

                        Align(
                          alignment: AlignmentDirectional.topCenter,
                          child: Stack(
                            alignment: AlignmentDirectional.topEnd,
                            children: [
                              Container(
                                height: 150,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: coverImage != null
                                        ? FileImage(coverImage)
                                        : NetworkImage(userModel.backgrounder) ,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: ()
                                {
                                  SocialCubit.get(context).getCoverImage(name: nameController.text, phone:      phoneController.text, bio: bioController.text);
                                },
                                icon: CircleAvatar(
                                  backgroundColor: Colors.blue,
                                  radius: 20.0,
                                  child: Icon(
                                    Icons.camera_alt_outlined,
                                    size: 16.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Profile image
                        Stack(
                          alignment: AlignmentDirectional.bottomEnd,
                          children: [

                            CircleAvatar(
                              radius: 64,
                              backgroundColor:
                                  Theme.of(context).scaffoldBackgroundColor,
                              child: CircleAvatar(
                                radius: 60,
                                backgroundImage: profileImage != null
                              ? FileImage(profileImage)
                                : NetworkImage(userModel.image) ,

              ),
                            ),
                            IconButton(
                              onPressed: ()
                              {
                                SocialCubit.get(context).getProfileImage(name: nameController.text, phone: phoneController.text, bio: bioController.text ) ;

                              },
                              icon: CircleAvatar(
                                backgroundColor: Colors.blue,
                                radius: 20.0,
                                child: Icon(
                                  Icons.camera_alt_outlined,
                                  size: 16.0,
                                ),
                              ),
                            ),

                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  if (SocialCubit.get(context).profileImage !=null ||SocialCubit.get(context).coverImage != null)

// Inside the Row for upload buttons
                    Row(
                      children: [
                        if (SocialCubit.get(context).profileImage != null)
                          Expanded(
                            child: Column(
                              children: [
                                defaultButton(
                                  function: () {
                                    SocialCubit.get(context).uploadProfileImageToSupabase(
                                      profileImage!,
                                      name: nameController.text,
                                      phone: phoneController.text,
                                      bio: bioController.text,
                                    );
                                  },
                                  text: 'upload profile',
                                ),
                                if (state is SocialUploadProfileImageLoadingState)
                                  LinearProgressIndicator(
                                    color: Colors.blueGrey,
                                    backgroundColor: Colors.grey[300],
                                  ),
                                SizedBox(height: 5.0),

                              ],
                            ),
                          ),
                        SizedBox(width: 5.0),
                        if (SocialCubit.get(context).coverImage != null)
                          Expanded(
                            child: Column(
                              children: [
                                defaultButton(
                                  function: () {
                                    SocialCubit.get(context).uploadCoverImageToSupabase(
                                      coverImage!,
                                      name: nameController.text,
                                      phone: phoneController.text,
                                      bio: bioController.text,
                                    );
                                  },
                                  text: 'upload cover',
                                ),
                                if (state is SocialUploadCoverImageLoadingState)
                                  LinearProgressIndicator(
                                    color: Colors.blueGrey,
                                    backgroundColor: Colors.grey[300],
                                  ),
                                SizedBox(height: 5.0),

                              ],
                            ),
                          ),
                      ],
                    ),
                  SizedBox(
                    height: 20.0,
                  ),
                  defaultFormField
                    (
                      context: context,
                      controller: nameController,
                      textColor: Theme.of(context).textTheme.bodyMedium!.color,
                      iconColor: Theme.of(context).iconTheme.color,
                      type: TextInputType.name,
                      validate: (String ? value) {
                        if (value!.isEmpty) {
                          return 'Name must not be empty';
                        }
                        return null;
                      },
                      label: 'Name',
                      prefix: IconButtonIcons.person2,
                      obsecure: false
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  defaultFormField(
                      context: context,
                      controller: bioController,
                      textColor: Theme.of(context).textTheme.bodyMedium!.color,
                      iconColor: Theme.of(context).iconTheme.color,
                      type: TextInputType.name,
                      validate: (String ? value) {
                        if (value!.isEmpty) {
                          return 'Name must not be empty';
                        }
                        return null;
                      },
                      label: 'Bio',
                      prefix: Icons.info_outline,
                      obsecure: false
                  ),
                  SizedBox(
                    height: 10.0,
                  ),

                  defaultFormField(
                      context: context,
                      controller: phoneController,
                      textColor: Theme.of(context).textTheme.bodyMedium!.color,
                      iconColor: Theme.of(context).iconTheme.color,
                      type: TextInputType.phone,
                      validate: (String ? value) {
                        if (value!.isEmpty) {
                          return 'Name must not be empty';
                        }
                        return null;
                      },
                      label: 'Phone',
                      prefix: Icons.phone,
                      obsecure: false
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
