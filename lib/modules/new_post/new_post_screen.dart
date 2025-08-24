import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialmediaproject/modules/cubit/cubit.dart';
import 'package:socialmediaproject/modules/cubit/states.dart';
import 'package:socialmediaproject/shared/components/compnents.dart';
import 'package:socialmediaproject/shared/style/pasticon_button.dart';

class NewPostScreen extends StatefulWidget {
  const NewPostScreen({super.key});

  @override
  State<NewPostScreen> createState() => _NewPostScreenState();
}

class _NewPostScreenState extends State<NewPostScreen> {
  final TextEditingController textController = TextEditingController();
  List<String> tags = [];

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SocialCubit, SocialStates>(
      listener: (context, state) {
        if (state is SocialCreatePostSuccessState) {
          // Clear input and remove image
          textController.clear();
          SocialCubit.get(context).removePostImage();

          // Refresh posts so feed updates immediately
          SocialCubit.get(context).getPosts();

          // Close NewPostScreen
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        File? postImage = SocialCubit.get(context).postImage;

        return Scaffold(
          appBar: defaultAppBar(
            context: context,
            title: 'Create Post',
            actions: [
              defaultTextButton(
                function: () {
                  if (postImage == null) {
                    SocialCubit.get(context).createPost(
                      dateTime: DateTime.now().toIso8601String(),
                      text: textController.text,
                      tags: tags,
                    );
                  } else {
                    SocialCubit.get(context).uploadPostImage(
                      dateTime: DateTime.now().toIso8601String(),
                      text: textController.text,
                      postImage: postImage,
                      tags: tags, // <-- pass tags here
                    );
                  }
                },
                text: 'Post',
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                if (state is SocialCreatePostLoadingState)
                  const LinearProgressIndicator(),
                const SizedBox(height: 10),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 25.0,
                      backgroundImage: NetworkImage(
                          SocialCubit.get(context).userModel!.image),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        SocialCubit.get(context).userModel!.name,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .copyWith(
                          height: 1.4,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: TextFormField(
                    controller: textController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText: 'What is on your mind ...',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                if (postImage != null)
                  Stack(
                    alignment: AlignmentDirectional.topEnd,
                    children: [
                      Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.0),
                          image: DecorationImage(
                            image: FileImage(postImage),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          SocialCubit.get(context).removePostImage();
                        },
                        icon: const CircleAvatar(
                          backgroundColor: Colors.blue,
                          radius: 20.0,
                          child: Icon(
                            Icons.close,
                            size: 16.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          SocialCubit.get(context).getPostImage();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              IconButtonIcons.camera,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 5),
                            const Text(
                              'Add Photo',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () {
                          final TextEditingController tagController =
                          TextEditingController(text: tags.join(', '));

                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Add Tags'),
                              content: TextField(
                                controller: tagController,
                                decoration: const InputDecoration(
                                  hintText:
                                  'Enter tags separated by commas (#auto)',
                                  hintStyle: TextStyle(
                                    color: Colors.grey,
                                  )
                                ),
                                onChanged: (value) {
                                  tags = value
                                      .split(',')
                                      .map((tag) => tag.trim())
                                      .where((tag) => tag.isNotEmpty)
                                      .map((tag) =>
                                  tag.startsWith('#') ? tag : '#$tag')
                                      .toList();
                                },
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(color: Colors.blueGrey),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    tags = tagController.text
                                        .split(',')
                                        .map((tag) => tag.trim())
                                        .where((tag) => tag.isNotEmpty)
                                        .map((tag) =>
                                    tag.startsWith('#') ? tag : '#$tag')
                                        .toList();
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    'Save Tags',
                                    style: TextStyle(color: Colors.green),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Text(
                          '# Tags',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
