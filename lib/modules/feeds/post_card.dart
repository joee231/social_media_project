import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:socialmediaproject/models/post_model.dart';
import 'package:socialmediaproject/modules/cubit/cubit.dart';
import 'package:socialmediaproject/shared/components/compnents.dart';

import '../../shared/style/pasticon_button.dart';
import '../comment_details/comment_details_screen.dart';
import '../post_details_screen/post_details_screen.dart';

class PostCard extends StatefulWidget {
  final PostModel model;
  final int index;
  final Set<String> likedPosts;

  final bool isArchived; // Default value, can be changed based on your logic

  PostCard({
    required this.model,
    required this.index,
    required this.likedPosts,
    this.isArchived = false,
    super.key,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final TextEditingController editPostController = TextEditingController();
  double offsetX = 0.0;
  File? newPostImage;

  Future<void> pickNewPostImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        newPostImage = File(picked.path);
      });
    }
  }

  void showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    final postId = widget.model.postId;
    final isLiked = widget.likedPosts.contains(postId);

    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          offsetX += details.delta.dx; // unlimited dragging
        });
      },
      onPanEnd: (details) {
        if (offsetX.abs() > 150) {
          // Archive post if dragged far
          if (widget.model.isArchived) {
            SocialCubit.get(context).unarchivePost(postId);
            showToast("Unarchived successfully");
          } else {
            SocialCubit.get(context).archivePost(postId);
            showToast("Post archived successfully");
          }
        } else {
          showToast("Already in archive");
        }
        setState(() {
          offsetX = 0; // reset for smooth interaction
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        transform: Matrix4.translationValues(offsetX, 0.0, 0.0),
        child: Card(
          color: Theme.of(context).cardColor,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          elevation: 5.0,
          margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User info
                Row(
                  children: [
                    CircleAvatar(
                      radius: 25.0,
                      backgroundImage: NetworkImage(widget.model.image),
                    ),
                    SizedBox(width: 15.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                widget.model.name,
                                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  height: 1.4,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).textTheme.bodyMedium?.color,
                                ),
                              ),
                              SizedBox(width: 5.0),
                              if (widget.model.isEmailVerified == true)
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.blue,
                                  size: 16.0,
                                ),
                            ],
                          ),
                          Text(
                              SocialCubit.get(context).formatDate(widget.model.dateTime ?? ''),

                            style: Theme.of(context).textTheme.bodySmall!
                                .copyWith(height: 1.4, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 15.0),
                    IconButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (BuildContext context) => DraggableScrollableSheet(
                            initialChildSize: 0.4,
                            minChildSize: 0.25,
                            maxChildSize: 0.8,
                            expand: false,
                            snap: true,
                            snapSizes: [0.25, 0.4, 0.8],
                            builder:
                                (
                                  BuildContext context,
                                  ScrollController scrollController,
                                ) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20.0),
                                        topRight: Radius.circular(20.0),
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        // Handle bar
                                        Container(
                                          width: 40,
                                          height: 4,
                                          margin: EdgeInsets.symmetric(
                                            vertical: 10,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[400],
                                            borderRadius: BorderRadius.circular(
                                              2,
                                            ),
                                          ),
                                        ),
                                        // Scrollable content
                                        Expanded(
                                          child: ListView(
                                            controller: scrollController,
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 16,
                                            ),
                                            children: [
                                              ListTile(
                                                leading: Icon(
                                                  Icons.edit,
                                                  color: Colors.blue,
                                                ),
                                                title: Text('Edit Post'),
                                                onTap: () {
                                                  editPostController.text =
                                                      widget.model.text;
                                                  Navigator.pop(context);
                                                  showDialog(
                                                    context: context,
                                                    builder: (dialogContext) => AlertDialog(
                                                      backgroundColor: Theme.of(dialogContext).dialogTheme.backgroundColor,
                                                      title: Text(
                                                        'Edit Post',
                                                        style: Theme.of(dialogContext).textTheme.titleMedium,
                                                      ),
                                                      content: SingleChildScrollView(
                                                        child: Column(
                                                          children: [
                                                            TextField(
                                                              maxLines: 5,
                                                              controller:
                                                                  editPostController,
                                                              style: Theme.of(dialogContext).textTheme.bodyMedium,
                                                              decoration: InputDecoration(
                                                                hintText:
                                                                    'Edit your post here',
                                                                hintStyle: Theme.of(dialogContext).textTheme.bodySmall,
                                                                border:
                                                                    OutlineInputBorder(),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              height: 10,
                                                            ),
                                                            if (newPostImage !=
                                                                null)
                                                              ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      8,
                                                                    ),
                                                                child: Image.file(
                                                                  newPostImage!,
                                                                  height: 100,
                                                                  width: double
                                                                      .infinity,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                ),
                                                              ),
                                                            if (newPostImage ==
                                                                    null &&
                                                                widget
                                                                        .model
                                                                        .postImage.isNotEmpty)
                                                              TextButton.icon(
                                                                onPressed:
                                                                    pickNewPostImage,
                                                                icon: Icon(
                                                                  Icons.image,
                                                                  color: Colors
                                                                      .blue,
                                                                ),
                                                                label: Text(
                                                                  'Pick New Image',
                                                                  style: TextStyle(
                                                                    color: Colors
                                                                        .blue,
                                                                  ),
                                                                ),
                                                              ),
                                                          ],
                                                        ),
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () => Navigator.pop(dialogContext),
                                                          child: Text('Cancel', style: TextStyle(
                                                            color: Colors.red,
                                                            fontWeight: FontWeight.bold,
                                                          )),
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            SocialCubit.get(dialogContext).editPost(
                                                              postId: widget.model.postId,
                                                              text: editPostController.text,
                                                              newPostImage: newPostImage,
                                                            );
                                                            Navigator.pop(dialogContext);
                                                          },
                                                          child: Text('Save', style: TextStyle(
                                                            color: Colors.blueGrey,
                                                            fontWeight: FontWeight.bold,
                                                          )),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              ),
                                              Divider(),
                                              ListTile(
                                                leading: Icon(
                                                  Icons.archive,
                                                  color: Colors.orange,
                                                ),
                                                title: Text('Archive Post'),
                                                onTap: () {
                                                  Navigator.pop(context);
                                                  if (!widget
                                                      .model
                                                      .isArchived) {
                                                    SocialCubit.get(
                                                      context,
                                                    ).archivePost(
                                                      widget.model.postId,
                                                    );
                                                    showToast(
                                                      "Post archived successfully",
                                                    );
                                                  } else {
                                                    showToast(
                                                      "Post is already archived",
                                                    );
                                                  }
                                                },
                                              ),
                                              ListTile(
                                                leading: Icon(
                                                  Icons.delete_forever,
                                                  color: Colors.red,
                                                ),
                                                title: Text('delete Post'),
                                                onTap: () {
                                                  SocialCubit.get(context)
                                                      .deletePost(
                                                    widget.model.postId,
                                                  );
                                                  Navigator.pop(context);
                                                  // Add share functionality
                                                  showToast(
                                                    "Post deleted successfully",
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
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.more_horiz,
                        size: 16.0,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10),
                InkWell(
                  onTap: () {
                    navigateTo(context, PostDetailsScreen(index: widget.index));
                  },
                  child: Text(
                    widget.model.text,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                if (widget.model.tags.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Wrap(
                      spacing: 5.0,
                      runSpacing: 5.0,
                      children: widget.model.tags.map((tag) {
                        return Chip(
                          label: Text(tag!),
                          backgroundColor: Color.fromRGBO(0, 0, 255, 0.1),
                          labelStyle: TextStyle(color: Colors.blue),
                        );
                      }).toList(),
                    ),
                  ),
                if (widget.model.postImage.isNotEmpty)
                  InkWell(
                    onTap: () {
                      navigateTo(context, PostDetailsScreen(index: widget.index));
;                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Container(
                        height: 140,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4.0),
                          image:
                              widget.model.postImage.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(widget.model.postImage),
                                  fit: BoxFit.cover,
                                  colorFilter: widget.model.isArchived
                                    ? ColorFilter.mode(
                                        Color.fromRGBO(128, 128, 128, 0.6),
                                        BlendMode.saturation,
                                      )
                                    : null,
                                )
                              : null,
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            // Handle like action
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5.0),
                            child: Row(
                              children: [
                                Icon(
                                  IconButtonIcons.heart_check,
                                  size: 14.0,
                                  color: Colors.red,
                                ),
                                SizedBox(width: 5.0),
                                Text(
                                  ' ${SocialCubit.get(context).likes[widget.index]} likes',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodySmall!.copyWith(height: 1.4),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) =>
                                  CommentDetailsScreen(postModel: widget.model),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(
                                  IconButtonIcons.comment,
                                  size: 14.0,
                                  color: Colors.amber,
                                ),
                                SizedBox(width: 5.0),
                                Text(
                                  ' ${SocialCubit.get(context).commentsCount[SocialCubit.get(context).postsId[widget.index]] ?? 0} comments',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodySmall!.copyWith(height: 1.4),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (SocialCubit.get(context).postComments[widget.model.postId]!.length >0)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5.0),
                  child: Container(
                    height: 120.0,
                    child: Builder(
                      builder: (context) {
                        final comments = SocialCubit.get(context).postComments[widget.model.postId] ?? [];
                        final limitedComments = comments.take(3).toList();
                        return InkWell(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) =>
                                  CommentDetailsScreen(postModel: widget.model),
                            );
                          },
                          child: ListView.separated(
                            physics: BouncingScrollPhysics(),
                            itemCount: limitedComments.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 5.0),
                            itemBuilder: (context, index) {
                              final comment = limitedComments[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(comment.image ?? ''),
                                ),
                                title: Text(
                                  comment.name ?? "Unknown User",
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Text(comment.comment),
                                trailing: Text(
                                  SocialCubit.get(context).formatDate(comment.dateTime ?? ''),
                                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                                ),
                              );
                            },
                          ),
                        );

                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Container(
                    width: double.infinity,
                    height: 1.0,
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          // Handle comment action
                        },
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 18.0,
                              backgroundImage: NetworkImage(
                                SocialCubit.get(context).userModel!.image,
                              ),
                            ),
                            SizedBox(width: 15.0),

                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (context) => CommentDetailsScreen(
                                      postModel: widget.model,
                                    ),
                                  );
                                },
                                child: Text(
                                  'write a comment ...',
                                  style: Theme.of(context).textTheme.bodySmall!
                                      .copyWith(
                                        height: 1.4,
                                        color: Theme.of(context).textTheme.bodySmall?.color
                                      ),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                if (isLiked) {
                                  widget.likedPosts.remove(postId);
                                  SocialCubit.get(context).unlikePost(postId);
                                } else {
                                  widget.likedPosts.add(postId);
                                  SocialCubit.get(context).likePost(postId);
                                }
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    isLiked
                                        ? Icons.heart_broken_sharp
                                        : IconButtonIcons.heart_check,
                                    size: 14.0,
                                    color: Colors.red,
                                  ),
                                  SizedBox(width: 5.0),
                                  Text(
                                    isLiked ? 'Unlike' : 'Like',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(height: 1.2 ,
                                    color: Theme.of(context).textTheme.bodySmall?.color),
                                  ),
                                ],
                              ),
                            ),

                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
