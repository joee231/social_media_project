import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialmediaproject/modules/login_screen/cubit/states.dart';
import 'package:socialmediaproject/modules/post_details_screen/post_details_screen.dart';

import '../models/post_model.dart';
import '../modules/archive_screen/archive_screen.dart';
import '../modules/cubit/cubit.dart';
import '../modules/cubit/states.dart';
import '../modules/new_post/new_post_screen.dart';
import '../shared/components/compnents.dart';
import '../shared/style/pasticon_button.dart';



class SocialLayout extends StatefulWidget {
  const SocialLayout({super.key});

  @override
  State<SocialLayout> createState() => _SocialLayoutState();
}

class _SocialLayoutState extends State<SocialLayout> {
  final GlobalKey _moreIconKey = GlobalKey();
  final TextEditingController _searchController = TextEditingController();
  List<PostModel> _searchResults = [];

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Search Posts'),
          content: TextField(
            controller: _searchController,
            decoration: const InputDecoration(hintText: 'Enter search query'),
            onSubmitted: (value) {
              setState(() {
                _searchResults = SocialCubit.get(context).searchPosts(value);
              });
              Navigator.pop(context);
              _showSearchResults(context);
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _searchResults = SocialCubit.get(context).searchPosts(_searchController.text);
                });
                Navigator.pop(context);
                _showSearchResults(context);
              },
              child: const Text('Search'),
            ),
          ],
        );
      },
    );
  }

  void _showSearchResults(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Search Results'),
          content: SizedBox(
            width: double.maxFinite,
            child: _searchResults.isEmpty
                ? const Text('No results found.')
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final post = _searchResults[index];
                      return InkWell(
                        onTap: () {
                          Navigator.pop(context); // Close search results dialog
                          final cubit = SocialCubit.get(context);
                          final postIndex = cubit.posts.indexWhere((p) => p.postId == post.postId);
                          if (postIndex != -1) {
                            navigateTo(context, PostDetailsScreen(index: postIndex));
                          }
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20.0,
                                      backgroundImage: NetworkImage(post.image),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(post.name, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                                          Text(post.dateTime, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(post.text, style: Theme.of(context).textTheme.bodyMedium),
                                if (post.tags.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Wrap(
                                      spacing: 5.0,
                                      runSpacing: 5.0,
                                      children: post.tags.map((tag) {
                                        return Chip(
                                          label: Text(tag ?? ''),
                                          backgroundColor: const Color.fromRGBO(0, 0, 255, 0.1),
                                          labelStyle: const TextStyle(color: Colors.blue),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                if (post.postImage.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Container(
                                      height: 140,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4.0),
                                        image: DecorationImage(
                                          image: NetworkImage(post.postImage),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SocialCubit , SocialStates>(
      listener: (context , state)
      {

        if(state is SocialNewPostState)
        {
          navigateTo(context, NewPostScreen(),);
        }
        // Remove redundant user data loading on login success
        // if (state is SocialLoginSuccessState) {
        //   SocialCubit.get(context).getUserData();
        // }
        if (state is SocialSendEmailVerificationSuccessState) {
          // Toast already shown in cubit method
          showToast(
            text: 'Verification email sent. Please check your inbox.',
            state: ToastStates.SUCCESS,
          );
        }
        if (state is SocialSendEmailVerificationErrorState) {
          showToast(
            text: 'Failed to send verification email. Please try again.',
            state: ToastStates.ERROR,
          );
          // Toast already shown in cubit method
        }
        if (state is SocialRefreshUserSuccessState ||
            state is SocialRefreshUserErrorState) {
          // Dismiss loading dialog
          Navigator.of(context, rootNavigator: true).pop();
        }

        if (state is SocialRefreshUserSuccessState) {
          final userModel = SocialCubit.get(context).userModel;
          if (userModel != null && userModel.isEmailVerified) {
            showToast(
              text: 'Email verified successfully!',
              state: ToastStates.SUCCESS,
            );
          } else {
            showToast(
              text: 'Email not yet verified. Please check your email and try again.',
              state: ToastStates.WARNING,
            );
          }
        }

        if (state is SocialRefreshUserErrorState) {
          showToast(
            text: 'Error checking verification: ${state.error}',
            state: ToastStates.ERROR,
          );
        }

      },
      builder: ( context,  state)
      {
        var cubit = SocialCubit.get(context);
        // If userModel is null, show a loading or fallback screen
        if (cubit.userModel == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(
                cubit.titles[cubit.currentIndex]
            ),
            actions: [
              IconButton(
                icon: Icon(IconButtonIcons.search),
                onPressed: () {
                  _showSearchDialog(context);
                },
              ),

              IconButton(
                key: _moreIconKey,
                icon: Icon(Icons.more_vert),
                onPressed: () async {
                  final RenderBox button = _moreIconKey.currentContext!.findRenderObject() as RenderBox;
                  final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
                  final Offset position = button.localToGlobal(Offset.zero, ancestor: overlay);
                  await showMenu(
                    context: context,
                    position: RelativeRect.fromLTRB(
                      position.dx,
                      position.dy + button.size.height,
                      overlay.size.width - position.dx - button.size.width,
                      overlay.size.height - position.dy - button.size.height,
                    ),
                    items: [
                      _AnimatedMenuItem(
                        icon: IconButtonIcons.logout,
                        label: 'Logout',
                        color: Colors.red,
                        onTap: () {
                          SocialCubit.get(context).logout(context);
                        },
                      ),
                      _AnimatedMenuItem(
                        icon: IconButtonIcons.archive,
                        label: 'Archive',
                        color: Colors.amber,
                        onTap: () {
                          final cubit = SocialCubit.get(context);
                          cubit.archivePost(cubit.postsId[cubit.currentIndex]);
                          navigateTo(context, ArchiveScreen());
                        },
                      ),
                      _AnimatedMenuItem(
                        icon: IconButtonIcons.brightness_4,
                        label: 'Theme',
                        color: SocialCubit.get(context).isDark ? Colors.grey : Colors.black,
                        onTap: () {
                          SocialCubit.get(context).changeAppMode();
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          body: cubit.screens[cubit.currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: cubit.currentIndex,
            onTap: (index) {

              cubit.changeBottomNavBar(index );
            },
            items: [
              BottomNavigationBarItem(
                icon: Icon(IconButtonIcons.family_vella),
                label: 'main',
              ),
              BottomNavigationBarItem(
                icon: Icon(IconButtonIcons.conversation),
                label: 'conversation',
              ),

              BottomNavigationBarItem(
                icon: Icon(IconButtonIcons.upload),
                label: 'post',
              ),

              BottomNavigationBarItem(
                icon: Icon(IconButtonIcons.ters),
                label: 'options',
              ),
            ],
          ),
        );
      },
    );
  }
}

// Custom animated menu item for showMenu
class _AnimatedMenuItem extends PopupMenuEntry<int> {
  final dynamic icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  _AnimatedMenuItem({
    required this.icon,
    required this.label,
    this.color,
    required this.onTap,
  });

  @override
  double get height => 76; // Slightly bigger menu item height

  @override
  bool represents(int? value) => false;

  @override
  State<_AnimatedMenuItem> createState() => _AnimatedMenuItemState();
}

class _AnimatedMenuItemState extends State<_AnimatedMenuItem> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: Offset(1, 0), end: Offset.zero).animate(_fade);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: InkWell(
          onTap: () {
            Navigator.pop(context);
            widget.onTap();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0), // Slightly bigger padding
            child: Row(
              children: [
                Icon(widget.icon, color: widget.color, size: 19), // Slightly bigger icon
                const SizedBox(width: 15), // Slightly more space between icon and text
                Text(widget.label, style: const TextStyle(fontSize: 16)), // Slightly bigger text
              ],
            ),
          ),
        ),
      ),
    );
  }
}
