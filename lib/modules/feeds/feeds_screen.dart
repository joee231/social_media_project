import 'package:animated_conditional_builder/animated_conditional_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialmediaproject/models/post_model.dart';
import 'package:socialmediaproject/modules/comment_details/comment_details_screen.dart';
import 'package:socialmediaproject/modules/cubit/cubit.dart';
import 'package:socialmediaproject/modules/cubit/states.dart';
import 'package:socialmediaproject/shared/style/pasticon_button.dart';

import 'post_card.dart';

class FeedsScreen extends StatelessWidget {
  bool isLiked = false;
  var editPostController = TextEditingController();

  Set<String> likedPosts = {};

  FeedsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SocialCubit, SocialStates>(
      listener: (context, state) {
        // You can handle any specific state changes here if needed
      },
      builder: (context, state) {
        return AnimatedConditionalBuilder(
          condition:
          SocialCubit.get(context).posts.isNotEmpty &&
              SocialCubit.get(context).userModel != null,
          builder:
              (context) => SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
              children: [
                Card(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  elevation: 5.0,
                  margin: EdgeInsets.all(8.0),
                  child: Stack(
                    alignment: AlignmentDirectional.bottomEnd,
                    children: [
                      Image.asset(
                        'assets/images/cat-sunflower-field.png',
                        fit: BoxFit.cover,
                        height: 200.0,
                        width: double.infinity,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Communicate with friends',
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
                ListView.separated(
                  separatorBuilder:
                      (context, index) => SizedBox(height: 8.0),
                  itemBuilder:
                      (context, index) => PostCard(
                        model: SocialCubit.get(context).posts[index],
                        index: index,
                        likedPosts: likedPosts,
                      ),
                  itemCount: SocialCubit.get(context).posts.length,
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                ),
                SizedBox(height: 8.0),
              ],
            ),
          ),
          fallback: (context) => Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

}


