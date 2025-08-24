import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialmediaproject/modules/cubit/cubit.dart';
import 'package:socialmediaproject/modules/cubit/states.dart';
import 'package:socialmediaproject/modules/edit_profile/edit_profile.dart';
import 'package:socialmediaproject/shared/components/compnents.dart';
import 'package:socialmediaproject/shared/style/pasticon_button.dart';
import 'dart:io';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SocialCubit, SocialStates>(
      listener: (context, state) {},
      builder: (context, state) {
        var userModel = SocialCubit.get(context).userModel;


        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  height: 200,
                  child: Stack(
                    alignment: AlignmentDirectional.bottomCenter,
                    children: [
                      // Background image
                      Align(
                        alignment: AlignmentDirectional.topCenter,
                        child: Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(userModel!.backgrounder),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      // Profile image
                      CircleAvatar(
                        radius: 64,
                        backgroundColor:
                        Theme.of(context).scaffoldBackgroundColor,
                        child: CircleAvatar(
                          radius: 60,
                          backgroundImage: NetworkImage(userModel.image),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                userModel.name,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Text(
                userModel.bio,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      child: Column(
                        children: [
                          Text('100', style: Theme.of(context).textTheme.titleLarge),
                          const Text('Posts'),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      child: Column(
                        children: [
                          Text('250', style: Theme.of(context).textTheme.titleLarge),
                          const Text('Followers'),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      child: Column(
                        children: [
                          Text('180', style: Theme.of(context).textTheme.titleLarge),
                          const Text('Following'),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      child: Column(
                        children: [
                          Text('180', style: Theme.of(context).textTheme.titleLarge),
                          const Text('photos'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding:  EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.blue,
                            ),
                            onPressed: () {
                              SocialCubit.get(context).addPhoto();
                            },
                            child:  Text('add photos'),
                          ),
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blue,

                          ),
                            onPressed: ()
                            {
                              navigateTo(
                                  context,
                                  EditProfileScreen()
                              );



                            },

                            child: Icon(
                                IconButtonIcons.edit3,
                              size: 15.0,
                            )
                        ),
                      ],
                    ),
                    BlocBuilder<SocialCubit, SocialStates>(
                      builder: (context, state) {
                        final photoUrls = SocialCubit.get(context).photoUrls;
                        if (photoUrls.isEmpty) {
                          return SizedBox.shrink();
                        }
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 4,
                            mainAxisSpacing: 4,
                          ),
                          itemCount: photoUrls.length,
                          itemBuilder: (context, index) {
                            final url = photoUrls[index];
                            final tag = url;
                            return InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  PageRouteBuilder(
                                    opaque: false,
                                    pageBuilder: (_, __, ___) => FullImageView(url: url, tag: tag),
                                    transitionsBuilder: (_, animation, __, child) {
                                      return FadeTransition(opacity: animation, child: child);
                                    },
                                  ),
                                );
                              },
                              onLongPress: ()
                              {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text('Delete Photo'),
                                      content: const Text('Are you sure you want to delete this photo?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text('Cancel'),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            color: Colors.red,
                                          ),
                                          margin: const EdgeInsets.all(8.0),
                                          child: TextButton(
                                            onPressed: () {
                                              SocialCubit.get(context).removePhoto(url);
                                              Navigator.of(context).pop();
                                            },
                                            child:  Text('Delete',
                                                style: TextStyle(color: Colors.white)),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Hero(
                                tag: tag,
                                child: Image.network(
                                  url,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),

                  ],
                ),
              ),

            ],
          ),
        );
      },
    );
  }
}

class FullImageView extends StatelessWidget {
  final String url;
  final String tag;
  const FullImageView({required this.url, required this.tag, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Scaffold(
        backgroundColor: Colors.black.withOpacity(0.95),
        body: Center(
          child: Hero(
            tag: tag,
            child: Image.network(url, fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Icon(Icons.broken_image, color: Colors.white, size: 80),
            ),
          ),
        ),
      ),
    );
  }
}
