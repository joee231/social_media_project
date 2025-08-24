import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/cubit.dart';
import '../cubit/states.dart' show SocialStates;

class PostDetailsScreen extends StatelessWidget {
  final int index;

  final TextEditingController commentController = TextEditingController();

   PostDetailsScreen({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SocialCubit, SocialStates>(
      builder: (context, state) {
        final post = SocialCubit.get(context).posts[index];

        return Scaffold(
          appBar: AppBar(
            title: const Text('Post Details'),
            elevation: 0,
            foregroundColor: Theme.of(context).appBarTheme.titleTextStyle?.color,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User info header
                Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 25.0,
                        backgroundImage: NetworkImage(post.image),
                      ),
                      const SizedBox(width: 12.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    post.name,
                                    style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).textTheme.bodyMedium?.color,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 5.0),
                                // Verification badge
                                if (post.isEmailVerified == true)
                                  Icon(
                                    Icons.verified,
                                    color: Theme.of(context).colorScheme.primary,
                                    size: 18.0,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 2.0),
                            Text(
                              _formatDate(post.dateTime),
                              style: TextStyle(
                                fontSize: 13.0,
                                color: Theme.of(context).textTheme.bodySmall?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Post content
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 8.0),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Post text
                      if (post.text.isNotEmpty)
                        Text(
                          post.text,
                          style: TextStyle(
                            fontSize: 16.0,
                            height: 1.5,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),

                      // Tags
                      if (post.tags.isNotEmpty) ...[
                        const SizedBox(height: 12.0),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children: post.tags.map((tag) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 6.0,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: (0.1 * 255)),
                              borderRadius: BorderRadius.circular(20.0),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: (0.3 * 255)),
                                width: 1.0,
                              ),
                            ),
                            child: Text(
                              '#$tag',
                              style: TextStyle(
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                              ),
                            ),
                          )).toList(),
                        ),
                      ],

                      // Likes and Comments Row


                      // Post image
                      if (post.postImage.isNotEmpty) ...[
                        const SizedBox(height: 16.0),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.0),
                          child: Image.network(
                            post.postImage,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 200,
                                child: const Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                height: 200,
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Icon(Icons.favorite, color: Colors.red, size: 18.0),
                            const SizedBox(width: 4.0),
                            Text(
                              '${SocialCubit.get(context).likes[index] ?? 0} likes',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(width: 16.0),
                            Icon(Icons.comment, color: Colors.amber, size: 18.0),
                            const SizedBox(width: 4.0),
                            Text(
                              '${SocialCubit.get(context).commentsCount[SocialCubit.get(context).postsId[index]] ?? 0} comments',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),

                      // Comments List
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Builder(
                          builder: (context) {
                            final postId = SocialCubit.get(context).postsId[index];
                            final comments = SocialCubit.get(context).postComments[postId] ?? [];
                            if (comments.isEmpty) {
                              return Center(
                                child: Text(
                                  'No comments yet.',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                                ),
                              );
                            }
                            return ListView.separated(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: comments.length,
                              separatorBuilder: (context, i) => const SizedBox(height: 8.0),
                              itemBuilder: (context, i) {
                                final comment = comments[i];
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: NetworkImage(comment.image ?? ''),
                                  ),
                                  title: Text(
                                    comment.name ?? 'Unknown User',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(comment.comment),
                                  trailing: Text(
                                    comment.dateTime ?? '',
                                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),

                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: commentController,
                              decoration: InputDecoration(
                                hintText: 'Write a comment...',
                                hintStyle: TextStyle(
                                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              ),
                              onSubmitted: (value) {
                                {

                                }
                              },
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.send, color: Theme.of(context).colorScheme.primary),
                            onPressed: () {
                              if (commentController.text.trim().isNotEmpty)
                              SocialCubit.get(context).addCommentPost(
                                postId: post.postId,
                                text: commentController.text, // Replace with actual input from TextField
                              );
                              commentController.clear();
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ),

              ],
            ),
          ),
        );
      },
      listener: (context, state) {},
    );
  }

  String _formatDate(String dateTime) {
    try {
      final date = DateTime.parse(dateTime);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays}d ago';
      } else if (difference.inHours > 0) {
        return '${difference.inHours}h ago';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes}m ago';
      } else {
        return 'Just now';
      }
    } catch (e) {
      return dateTime;
    }
  }
}