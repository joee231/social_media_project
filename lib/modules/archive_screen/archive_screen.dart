import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialmediaproject/shared/components/compnents.dart';
import '../cubit/cubit.dart';
import '../cubit/states.dart';
import '../post_details_screen/post_details_screen.dart';

class ArchiveScreen extends StatelessWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SocialCubit, SocialStates>(
      listener: (context, state) {},
      builder: (context, state) {
        // Filter archived posts
        final archivedPosts = SocialCubit.get(context)
            .posts
            .where((post) => post.isArchived == true) // make sure PostModel has isArchived field
            .toList();

        return Scaffold(
          appBar: AppBar(
            title: const Text('Archived Posts'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(10.0),
            child: archivedPosts.isEmpty
                ? const Center(
              child: Text(
                'No archived posts yet',
                style: TextStyle(fontSize: 18.0),
              ),
            )
                : GridView.builder(
              itemCount: archivedPosts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10.0,
                crossAxisSpacing: 10.0,
                childAspectRatio: 1.0,
              ),
              itemBuilder: (context, index) {
                final post = archivedPosts[index];
                // Find the correct index in the full posts list
                final fullIndex = SocialCubit.get(context).posts.indexWhere((p) => p.postId == post.postId);
                return GestureDetector(
                  onTap: () {
                    if (fullIndex != -1) {
                      navigateTo(context, PostDetailsScreen(index: fullIndex));
                    }
                  },
                  child: Stack(
                    alignment: Alignment.topRight,
                    children:[
                      Container(
                        decoration:  BoxDecoration(
                          color: Colors.blueGrey,
                          borderRadius: BorderRadius.circular(10.0),
                          image: DecorationImage(
                            image: NetworkImage(post.postImage),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            post.text,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          SocialCubit.get(context).unarchivePost(post.postId);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Unarchived successfully")),
                          );
                        },
                        icon: Icon(
                          Icons.unarchive_outlined,
                          color: Colors.red,
                          size: 30.0,
                        ),
                      ),
                    ]
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
