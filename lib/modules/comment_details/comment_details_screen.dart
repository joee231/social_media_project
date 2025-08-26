import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/comment_model.dart';
import '../../models/post_model.dart';
import '../cubit/cubit.dart';
import '../cubit/states.dart';


class CommentDetailsScreen extends StatelessWidget {
  final PostModel postModel;
  final TextEditingController commentController = TextEditingController();

  CommentDetailsScreen({super.key, required this.postModel});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SocialCubit, SocialStates>(
      listener: (context, state) {
        if (state is SocialAddCommentPostSuccessState) {
          commentController.clear();
          SocialCubit.get(context).getCommentsPost(postModel.postId);
        }
      },
      builder: (context, state) {
        var comments = SocialCubit.get(context).postComments[postModel.postId] ?? [];
        var cubit = SocialCubit.get(context);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Comments'),
            centerTitle: true,
          ),
          body: Column(
            children: [
              // comments list
              Expanded(
                child: comments.isEmpty
                    ? const Center(child: Text("No comments yet"))
                    : ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(16.0),
                  itemCount: comments.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    CommentModel comment = comments[index];
                    return InkWell(
                      onLongPress: () {
                        // Show delete option if the comment belongs to the current user
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Delete Comment'),
                              content: const Text('Are you sure you want to delete this comment?'),
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
                                      if (cubit.userModel!.uId == comment.uId) {
                                        cubit.deleteCommentPost(
                                          postId: postModel.postId,
                                          commentId: comment.commentId,
                                        );
                                        Navigator.of(context).pop();
                                      }
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
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(comment.image ?? ''),
                        ),
                        title: Text(
                          comment.name ?? "Unknown User",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(comment.comment ?? ''),
                        trailing: Text(
                          SocialCubit.get(context).formatDate(comment.dateTime ?? ''),
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // input field
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: buildCommentInput(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildCommentInput(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey, width: 1.0),
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18.0,
            backgroundImage: NetworkImage(
              SocialCubit.get(context).userModel!.image,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: commentController,
              decoration:  InputDecoration(
                border: InputBorder.none,
                hintText: 'Write a comment...',
                hintStyle: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6)
                )
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blue, size: 20.0),
            onPressed: () {
              if (commentController.text.isNotEmpty) {
                SocialCubit.get(context).addCommentPost(
                  postId: PostModel.fromJson(postModel.toMap()).postId,

                  text: commentController.text,

                );
              }
            },
          ),
        ],
      ),
    );
  }
}
