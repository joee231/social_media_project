import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:socialmediaproject/modules/cubit/states.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../models/comment_model.dart';
import '../../models/messege_model.dart';
import '../../models/post_model.dart';
import '../../models/user_model.dart';
import '../../shared/components/compnents.dart';
import '../../shared/components/constants.dart';
import '../../shared/network/local/cash_helper.dart';
import '../chats/chats_screen.dart';
import '../feeds/feeds_screen.dart';
import '../login_screen/social_login-screen.dart';
import '../new_post/new_post_screen.dart';
import '../settings/settings_screen.dart';
import '../users/users_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class SocialCubit extends Cubit<SocialStates> {
  SocialCubit({required this.isDark}) : super(SocialInitialState());
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static SocialCubit get(BuildContext context) => BlocProvider.of(context);

  SocialUserModel? userModel;
  bool isDark;

  // ---------------- USER ----------------
  Future <void> getUserData() async {
    if (uId == null || uId!.isEmpty) {
      print('getUserData aborted: uId is null or empty');
      emit(SocialGetUserErrorState('uId is null or empty'));
      return;
    }
    emit(SocialGetUserLoadingState());

    FirebaseFirestore.instance
        .collection('users')
        .doc(uId)
        .get()
        .then((value) {
      print('Raw Firestore data: ${value.data()}');
      userModel = SocialUserModel.fromJson(value.data()!);
      print('UserModel isEmailVerified: ${userModel!.isEmailVerified}');
      // Sync photoUrls with Firestore
      photoUrls = userModel!.photos;
      emit(SocialGetUserSuccessState());
    }).catchError((error) {
      print('getUserData error: $error');
      emit(SocialGetUserErrorState(error.toString()));
    });
  }

  int currentIndex = 0;

  final List<Widget> screens = [
    FeedsScreen(),
    ChatsScreen(),
    NewPostScreen(),
    SettingsScreen(),
  ];

  final List<String> titles = [
    'news feed',
    'Chats',
    'New Post',
    'Settings',
  ];

  void changeBottomNavBar(int index) {
    if (index == 1) {
      getUsers();
    }
    if (index == 2) {
      emit(SocialNewPostState());
      return;
    }
    currentIndex = index;
    emit(SocialChangeBottomNavState());
  }


  void changeAppMode({bool? fromShared}) {
    if (fromShared != null) {
      isDark = fromShared;
      emit(SocialChangeModeState());
      return;
    }
    isDark = !isDark;
    CashHelper.saveData(key: 'isDark', value: isDark).then((_) {
      emit(SocialChangeModeState());
    });
  }

  final ImagePicker _picker = ImagePicker();

  // ---------------- PROFILE IMAGE ----------------
  File? profileImage;

  Future<void> getProfileImage({
    required String name,
    required String phone,
    required String bio,
  }) async {
    final granted = await _requestGalleryPermission();
    if (!granted) return;

    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) {
      emit(SocialProfileImagePickedErrorState());
      return;
    }
    profileImage = File(picked.path);
    emit(SocialProfileImagePickedSuccessState());

    if (profileImage != null) {
      final url = await uploadProfileImageToSupabase(
        profileImage!,
        name: name,
        phone: phone,
        bio: bio,
      );
      if (url == null) {
        emit(SocialUploadProfileImageErrorState('Upload failed'));
      }
    }
  }

  Future<String?> uploadProfileImageToSupabase(File file, {
    required String name,
    required String phone,
    required String bio,
  }) async {
    emit(SocialUploadProfileImageLoadingState());
    try {
      final fileName = 'profile_${DateTime
          .now()
          .millisecondsSinceEpoch}.jpg';
      final bytes = await file.readAsBytes();

      final path = await Supabase.instance.client.storage
          .from('profileimage')
          .uploadBinary(fileName, bytes);

      if (path.isEmpty) {
        emit(SocialUploadProfileImageErrorState('Empty path'));
        return null;
      }

      final publicUrl = Supabase.instance.client.storage
          .from('profileimage')
          .getPublicUrl(fileName);

      await updateUser(
        image: publicUrl,
        name: name,
        phone: phone,
        bio: bio,
      );
      emit(SocialUploadProfileImageSuccessState(publicUrl));
      return publicUrl;
    } catch (e) {
      emit(SocialUploadProfileImageErrorState(e.toString()));
      return null;
    }
  }

  // ---------------- COVER IMAGE ----------------
  File? coverImage;

  Future<void> getCoverImage({
    required String name,
    required String phone,
    required String bio,
  }) async {
    final granted = await _requestGalleryPermission();
    if (!granted) return;

    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) {
      emit(SocialCoverImagePickedErrorState());
      return;
    }
    coverImage = File(picked.path);
    emit(SocialCoverImagePickedSuccessState());

    if (coverImage != null) {
      final url = await uploadCoverImageToSupabase(
        coverImage!,
        name: name,
        phone: phone,
        bio: bio,
      );
      if (url == null) {
        emit(SocialUploadCoverImageErrorState('Upload failed'));
      }
    }
  }

  Future<String?> uploadCoverImageToSupabase(File file, {
    required String name,
    required String phone,
    required String bio,
  }) async {
    emit(SocialUploadCoverImageLoadingState());
    try {
      final fileName = 'cover_${DateTime
          .now()
          .millisecondsSinceEpoch}.jpg';
      final bytes = await file.readAsBytes();

      final path = await Supabase.instance.client.storage
          .from('coverimage')
          .uploadBinary(fileName, bytes);

      if (path.isEmpty) {
        emit(SocialUploadCoverImageErrorState('Empty path'));
        return null;
      }

      final publicUrl = Supabase.instance.client.storage
          .from('coverimage')
          .getPublicUrl(fileName);

      await updateUser(
        backgrounder: publicUrl,
        name: name,
        phone: phone,
        bio: bio,
      );
      emit(SocialUploadCoverImageSuccessState(publicUrl));
      return publicUrl;
    } catch (e) {
      emit(SocialUploadCoverImageErrorState(e.toString()));
      return null;
    }
  }

  // ---------------- POSTS ----------------
  File? postImage;

  Future<void> getPostImage() async {
    final granted = await _requestGalleryPermission();
    if (!granted) return;

    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked == null) {
      return emit(SocialPostImagePickedErrorState('No image selected'));
    }
    postImage = File(picked.path);
    emit(SocialPostImagePickedSuccessState());
  }

  void removePostImage() {
    postImage = null;
    emit(SocialRemovePostImagePickedState());
  }

  Future<void> uploadPostImage({
    required String dateTime,
    required String text,
    File? postImage,
    List<String>? tags, // <-- add tags param
  }) async {
    emit(SocialPostImagePickedLoadingState());

    try {
      final file = postImage!;
      final fileName = 'post_${DateTime
          .now()
          .millisecondsSinceEpoch}.jpg';
      final fileBytes = await file.readAsBytes();

      // Upload to Supabase
      await Supabase.instance.client.storage
          .from('postimage')
          .uploadBinary(fileName, fileBytes);

      final imageUrl = Supabase.instance.client.storage
          .from('postimage')
          .getPublicUrl(fileName);

      // After upload → create post with image URL and tags
      createPost(
          dateTime: dateTime, text: text, postImageUrl: imageUrl, tags: tags);

      emit(SocialPostImagePickedSuccessState());
    } catch (error) {
      emit(SocialPostImagePickedErrorState(error.toString()));
    }
  }

  void createPost({
    required String dateTime,
    required String text,
    String? postImageUrl,
    List<String>? tags, // <-- new
  }) {
    if (userModel == null) {
      emit(SocialCreatePostErrorState('User not loaded'));
      return;
    }
    emit(SocialCreatePostLoadingState());

    final postRef = FirebaseFirestore.instance.collection('posts').doc();
    final post = PostModel(
      uId: userModel!.uId,
      name: userModel!.name,
      image: userModel!.image,
      dateTime: dateTime,
      text: text,
      postImage: postImageUrl ?? '',
      postId: postRef.id,
      tags: tags ?? [],
      isArchived: false,
      // default value
      isEmailVerified: userModel!
          .isEmailVerified, // use user's verification status
    );

    postRef.set(post.toMap()).then((_) {
      posts.add(post);
      postsId.add(post.postId);
      emit(SocialCreatePostSuccessState());
    }).catchError((e) {
      emit(SocialCreatePostErrorState(e.toString()));
    });
  }


  // ---------------- FETCH POSTS ----------------
  List<PostModel> posts = [];
  List<String> postsId = [];
  List<int> likes = [];
  List<int> commentCount = [];

  Map<String, List<CommentModel>> postComments = {};
  Map<String, int> commentsCount = {};

  Future<void> getPosts() async {
    posts.clear();
    postsId.clear();
    likes.clear();
    commentCount.clear();
    emit(SocialGetPostLoadingState());

    try {
      final value = await FirebaseFirestore.instance.collection('posts').get();
      for (var element in value.docs) {
        final likesSnapshot = await element.reference.collection('likes').get();
        final commentsSnapshot =
        await element.reference.collection('comments').get();

        likes.add(likesSnapshot.docs.length);
        commentCount.add(commentsSnapshot.docs.length);

        postsId.add(element.id);
        posts.add(PostModel.fromJson(element.data()));

        // fetch comments for each post
        await getCommentsPost(element.id);
      }
      emit(SocialGetPostSuccessState());
    } catch (error) {
      emit(SocialGetPostErrorState(error.toString()));
    }
  }

  void likePost(String postId) {
    if (userModel == null) {
      emit(SocialLikePostErrorState('User not loaded'));
      return;
    }
    FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('likes')
        .doc(userModel!.uId)
        .set({'like': true}).then((value) {
      emit(SocialLikePostSuccessState());
      getPosts(); // Refresh likes count
    }).catchError((error) {
      emit(SocialLikePostErrorState(error.toString()));
    });
  }

  void unlikePost(String postId) {
    if (userModel == null) {
      emit(SocialUnlikePostErrorState('User not loaded'));
      return;
    }
    FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('likes')
        .doc(userModel!.uId)
        .delete()
        .then((value) {
      emit(SocialUnlikePostSuccessState());
      getPosts(); // Refresh likes count
    }).catchError((error) {
      emit(SocialUnlikePostErrorState(error.toString()));
    });
  }


  // ---------------- COMMENTS ----------------
  Future<void> getCommentsPost(String postId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .orderBy('dateTime', descending: true)
          .get();

      postComments[postId] = snapshot.docs
          .map((doc) =>
      CommentModel.fromJson(doc.data())
        ..commentId = doc.id)
          .toList();

      commentsCount[postId] = postComments[postId]?.length ?? 0;

      emit(SocialGetCommentsPostSuccessState());
    } catch (error) {
      emit(SocialGetCommentsPostErrorState(error.toString()));
    }
  }

  Future<void> addCommentPost({
    required String postId,
    required String text,
  }) async {
    if (userModel == null) {
      emit(SocialAddCommentPostErrorState('User not loaded'));
      return;
    }
    final commentRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(); // auto-generate ID

    final comment = CommentModel(
      name: userModel!.name,
      image: userModel!.image,
      uId: userModel!.uId,
      comment: text,
      dateTime: DateTime.now().toIso8601String(),
      commentId: commentRef.id,
    );

    await commentRef.set(comment.toMap());

    await getCommentsPost(postId);
    emit(SocialAddCommentPostSuccessState());
  }

  Future<void> deleteCommentPost({
    required String postId,
    required String commentId,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .delete();

      await getCommentsPost(postId);
      emit(SocialRemoveCommentPostSuccessState());
    } catch (error) {
      emit(SocialRemoveCommentPostErrorState(error.toString()));
    }
  }

  // ---------------- USERS ----------------
  List<SocialUserModel> users = [];

  Future<void> getUsers() async {
    users.clear();
    emit(SocialGetAllUsersLoadingState());
    FirebaseFirestore.instance.collection('users').get().then((value) {
      for (var element in value.docs) {
        if (element.data()['uId'] != uId && element.data()['uId'] != null) {
          users.add(SocialUserModel.fromJson(element.data()));
        }
      }
      emit(SocialGetAllUsersSuccessState());
    }).catchError((error) {
      emit(SocialGetAllUsersErrorState(error.toString()));
    });
  }

  // ---------------- MESSAGES ----------------
  Future<void> sendMessage({
    required String receiverId,
    required String dateTime,
    String? text,
    String? messageImage, // optional
  }) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception("User not logged in");

      final messageData = {
        'senderId': user.id,
        'receiverId': receiverId,
        'dateTime': dateTime,
        'text': text ?? '', // empty string if no text
        'messageImage': messageImage ?? '', // empty string if no image
      };

      // ✅ Insert into Supabase `messages` table
      final response = await Supabase.instance.client
          .from('messages')
          .insert(messageData);

      if (response.error != null) {
        throw Exception("Failed to send message: ${response.error!.message}");
      }

      print("Message sent successfully ✅");
    } catch (e) {
      print("sendMessage error: $e");
    }
  }

  List<MessegeModel> messages = [];
  DateTime? lastMessageTime;

  void getMessages({required String receiverId}) {
    if (userModel == null) {
      emit(SocialGetMessegeErrorState('User not loaded'));
      return;
    }
    // Clear messages only once when starting to listen
    messages.clear();

    FirebaseFirestore.instance
        .collection('users')
        .doc(userModel!.uId)
        .collection('chats')
        .doc(receiverId)
        .collection('messages')
        .orderBy('dateTime')
        .snapshots()
        .listen((event) {
      // Clear and rebuild the entire list to avoid duplicates
      messages.clear();

      for (var element in event.docs) {
        final msg = MessegeModel.fromJson(element.data());
        messages.add(msg);
      }
      emit(SocialGetMessegeSuccessState());
    }, onError: (error) {
      emit(SocialGetMessegeErrorState(error.toString()));
    });
  }


  // ---------------- HELPERS ----------------
  Future<void> updateUser({
    required String name,
    required String phone,
    required String bio,
    String? image,
    String? backgrounder,
  }) async {
    if (userModel == null) return;
    emit(SocialUpdateUserLoadingState());

    final updated = SocialUserModel(
      name: name,
      image: image ?? userModel!.image,
      backgrounder: backgrounder ?? userModel!.backgrounder,
      bio: bio,
      phone: phone,
      email: userModel!.email,
      uId: userModel!.uId,
      isEmailVerified: userModel!.isEmailVerified,
    );

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userModel!.uId)
          .update(updated.toMap());
      await getUserData();
      emit(SocialUpdateUserSuccessState());
    } catch (e) {
      emit(SocialUpdateUserErrorState(e.toString()));
    }
  }

  Future<bool> _requestGalleryPermission() async {
    final status = await Permission.photos.request();
    return status.isGranted;
  }

  void deletePost(String postId) {
    if (userModel == null) {
      emit(SocialDeletePostErrorState('User not loaded'));
      return;
    }
    FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .delete()
        .then((value) {
      posts.removeWhere((post) => post.postId == postId);
      postsId.remove(postId);
      likes.removeAt(postsId.indexOf(postId));
      commentCount.removeAt(postsId.indexOf(postId));
      postComments.remove(postId);
      commentsCount.remove(postId);
      emit(SocialDeletePostSuccessState());
    }).catchError((error) {
      emit(SocialDeletePostErrorState(error.toString()));
    });
  }

  Future<void> editPost({
    required String postId,
    required String text,
    File? newPostImage, // optional new image file
  }) async {
    if (userModel == null) {
      emit(SocialEditPostErrorState('User not loaded'));
      return;
    }
    emit(SocialEditPostLoadingState());

    String? postImageUrl;

    // If user selects a new image, upload it to Supabase
    if (newPostImage != null) {
      try {
        final fileName = 'post_${DateTime
            .now()
            .millisecondsSinceEpoch}.jpg';
        final bytes = await newPostImage.readAsBytes();

        await Supabase.instance.client.storage
            .from('postimage')
            .uploadBinary(fileName, bytes);

        postImageUrl = Supabase.instance.client.storage
            .from('postimage')
            .getPublicUrl(fileName);
      } catch (e) {
        emit(SocialEditPostErrorState('Image upload failed: $e'));
        return;
      }
    }

    // Keep old image if no new image is provided
    final oldPost = posts.firstWhere((post) => post.postId == postId);
    postImageUrl ??= oldPost.postImage;

    final updatedPost = PostModel(
      uId: userModel!.uId,
      name: userModel!.name,
      image: userModel!.image,
      dateTime: DateTime.now().toIso8601String(),
      text: text,
      postImage: postImageUrl,
      postId: postId,
      isArchived: oldPost.isArchived,
      // preserve archive status
      likes: oldPost.likes, // preserve likes
    );

    try {
      await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .update(updatedPost.toMap());

      // Update local list immediately
      final index = posts.indexWhere((post) => post.postId == postId);
      if (index != -1) posts[index] = updatedPost;

      emit(SocialEditPostSuccessState());
    } catch (e) {
      emit(SocialEditPostErrorState(e.toString()));
    }
  }

  void logout(BuildContext context) {
    FirebaseAuth.instance.signOut().then((value) {
      Future.wait([
        CashHelper.removeData(key: 'uId'),
        CashHelper.removeData(key: 'uID'),
      ]).then((_) {
        uId = null;
        userModel = null;
        posts.clear();
        postsId.clear();
        likes.clear();
        commentCount.clear();
        postComments.clear();
        commentsCount.clear();
        emit(SocialLogoutSuccessState());
        // Immediately navigate to login screen and remove all previous routes
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => SocialLoginScreen()),
              (route) => false,
        );
      });
    }).catchError((error) {
      emit(SocialLogoutErrorState(error.toString()));
    });
  }

// Archive a post
  void archivePost(String postId) {
    if (userModel == null) {
      emit(SocialArchivePostErrorState('User not loaded'));
      return;
    }
    final index = posts.indexWhere((post) => post.postId == postId);
    if (index == -1) return;

    if (posts[index].isArchived) {
      emit(SocialArchivePostSuccessState()); // Already archived
      return;
    }

    FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .update({'isArchived': true})
        .then((_) {
      posts[index].isArchived = true; // update local state only after success
      emit(SocialArchivePostSuccessState());
      getPosts(); // Refresh posts after archive
    }).catchError((error) {
      emit(SocialArchivePostErrorState(error.toString()));
    });
  }

// Unarchive a post
  void unarchivePost(String postId) {
    if (userModel == null) {
      emit(SocialUnarchivePostErrorState('User not loaded'));
      return;
    }
    final index = posts.indexWhere((post) => post.postId == postId);
    if (index == -1) return;

    if (!posts[index].isArchived) {
      emit(SocialUnarchivePostSuccessState()); // Already unarchived
      return;
    }

    FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .update({'isArchived': false})
        .then((_) {
      posts[index].isArchived = false; // update local state only after success
      emit(SocialUnarchivePostSuccessState());
      getPosts(); // Refresh posts after unarchive
    }).catchError((error) {
      emit(SocialUnarchivePostErrorState(error.toString()));
    });
  }

  void addTags(String postId, List<String> tags) {
    if (userModel == null) {
      emit(SocialAddTagsErrorState('User not loaded'));
      return;
    }
    final index = posts.indexWhere((post) => post.postId == postId);
    if (index == -1) return;

    // Update local state
    posts[index].tags = tags;

    // Save to Firestore
    FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .update({'tags': tags}).then((_) {
      emit(SocialAddTagsSuccessState());
    }).catchError((error) {
      emit(SocialAddTagsErrorState(error.toString()));
    });
  }

  void isVerifiedEmail() {
    if (userModel == null) {
      emit(SocialSendEmailVerificationErrorState('User not loaded'));
      return;
    }
    emit(SocialSendEmailVerificationLoadingState());

    FirebaseAuth.instance.currentUser?.sendEmailVerification().then((_) {
      emit(SocialSendEmailVerificationSuccessState());
      showToast(
        text: 'Verification email sent! Check your inbox.',
        state: ToastStates.SUCCESS,
      );
    }).catchError((error) {
      emit(SocialSendEmailVerificationErrorState(error.toString()));
      showToast(
        text: 'Failed to send verification email: ${error.toString()}',
        state: ToastStates.ERROR,
      );
    });
  }

  void refreshUserVerificationStatus() {
    if (userModel == null) {
      emit(SocialRefreshUserErrorState('User not loaded'));
      return;
    }
    emit(SocialLoadingState());

    FirebaseAuth.instance.currentUser?.reload().then((_) {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null && userModel != null) {
        // Check if verification status changed
        bool isNowVerified = currentUser.emailVerified;

        print('Current Firebase Auth verification: $isNowVerified');
        print('Current userModel verification: ${userModel!.isEmailVerified}');

        if (isNowVerified && !userModel!.isEmailVerified) {
          // User just got verified - update Firestore
          updateEmailVerificationStatus(isNowVerified);
        } else if (isNowVerified == userModel!.isEmailVerified) {
          // Status hasn't changed, just emit success
          emit(SocialRefreshUserSuccessState());
        } else {
          // Refresh user data from Firestore
          getUserData();
        }
      }
    }).catchError((error) {
      print('Error reloading user: $error');
      emit(SocialRefreshUserErrorState(error.toString()));
    });
  }

  void updateEmailVerificationStatus(bool isVerified) {
    if (userModel == null) return;

    print('Updating Firestore verification status to: $isVerified');

    FirebaseFirestore.instance
        .collection('users')
        .doc(userModel!.uId)
        .update({'isEmailVerified': isVerified})
        .then((_) {
      print('Firestore updated successfully');

      // Update local model
      userModel!.isEmailVerified = isVerified;

      emit(SocialRefreshUserSuccessState());

      if (isVerified) {
        showToast(
          text: 'Email verified successfully!',
          state: ToastStates.SUCCESS,
        );
      }
    }).catchError((error) {
      print('Error updating Firestore: $error');
      emit(SocialRefreshUserErrorState(error.toString()));
      showToast(
        text: 'Error updating verification status',
        state: ToastStates.ERROR,
      );
    });
  }

  void sendImageMessage({
    required String receiverId,
    required String dateTime,
    required File imageFile,
  }) async {
    emit(SocialSendImageMessageLoadingState());

    try {
      final fileName = 'message_${DateTime
          .now()
          .millisecondsSinceEpoch}.jpg';
      final bytes = await imageFile.readAsBytes();

      // Upload to Supabase
      await Supabase.instance.client.storage
          .from('messages')
          .uploadBinary(fileName, bytes);

      final imageUrl = Supabase.instance.client.storage
          .from('messages')
          .getPublicUrl(fileName);

      sendMessage(
        receiverId: receiverId,
        dateTime: dateTime,
        text: imageUrl,
      );

      emit(SocialSendImageMessageSuccessState());
    } catch (error) {
      emit(SocialSendImageMessageErrorState(error.toString()));
    }
  }

  void getImageMessages({required String receiverId}) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(userModel!.uId)
        .collection('chats')
        .doc(receiverId)
        .collection('messages')
        .where('text', isNotEqualTo: '')
        .orderBy('dateTime')
        .snapshots()
        .listen(
          (event) {
        messages.clear();
        for (var element in event.docs) {
          messages.add(MessegeModel.fromJson(element.data()));
        }
        emit(SocialGetImageMessageSuccessState());
      },
      onError: (error) {
        emit(SocialGetImageMessageErrorState(error.toString()));
      },
    );
  }

  TextEditingController messageController = TextEditingController();
  File? selectedMessageImage;

  // Initialize message controller
  void initializeChatController() {
    messageController = TextEditingController();
  }

  // Pick image for message
  Future<void> pickMessageImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedMessageImage = File(image.path);
      emit(SocialPickMessageImageSuccessState());
    } else {
      emit(SocialPickMessageImageErrorState());
    }
  }

  // Clear selected message image
  void clearSelectedMessageImage() {
    selectedMessageImage = null;
    emit(SocialClearMessageImageState());
  }

  // Clear message input
  void clearMessageInput() {
    messageController.clear();
    selectedMessageImage = null;
    emit(SocialClearMessageInputState());
  }

  // Send message with optional image
  void sendMessageWithImage({
    required String receiverId,
    required String dateTime,
  }) async {
    if (userModel == null) {
      emit(SocialSendMessegeErrorState('User not loaded'));
      return;
    }
    if (messageController.text
        .trim()
        .isEmpty && selectedMessageImage == null) {
      return;
    }

    emit(SocialSendMessageLoadingState());

    MessegeModel message = MessegeModel(
      senderId: userModel!.uId,
      receiverId: receiverId,
      dateTime: dateTime,
      text: messageController.text.trim(),
      messageId: '', // Firestore will auto-generate ID
    );

    if (selectedMessageImage != null) {
      try {
        final fileName = 'messages_${DateTime
            .now()
            .millisecondsSinceEpoch}.jpg';
        final bytes = await selectedMessageImage!.readAsBytes();

        await Supabase.instance.client.storage
            .from('messages')
            .uploadBinary(
            fileName, bytes, fileOptions: const FileOptions(upsert: true));

        final imageUrl = Supabase.instance.client.storage
            .from('messages')
            .getPublicUrl(fileName);

        message.messageImage = imageUrl;
      } catch (error) {
        print('Supabase upload error: $error'); // Debug log
        emit(SocialSendMessegeErrorState(error.toString()));
        return;
      }
    }

    _sendMessageToFirestore(message, receiverId);
    clearMessageInput();
  }


  // Helper method to send message to Firestore
  void _sendMessageToFirestore(MessegeModel message, String receiverId) {
    if (userModel == null) {
      emit(SocialSendMessegeErrorState('User not loaded'));
      return;
    }
    // Set message for sender
    FirebaseFirestore.instance
        .collection('users')
        .doc(userModel!.uId)
        .collection('chats')
        .doc(receiverId)
        .collection('messages')
        .add(message.toMap())
        .then((value) {
      emit(SocialSendMessegeSuccessState()); // Only emit for sender
    }).catchError((error) {
      emit(SocialSendMessegeErrorState(error.toString()));
    });

    // Set message for receiver
    FirebaseFirestore.instance
        .collection('users')
        .doc(receiverId)
        .collection('chats')
        .doc(userModel!.uId)
        .collection('messages')
        .add(message.toMap())
    // Remove emit here to avoid double notification
        .catchError((error) {
      emit(SocialSendMessegeErrorState(error.toString()));
    });
  }

  @override
  Future<void> close() {
    messageController.dispose();
    return super.close();
  }


  Future<void> uploadMessageImage({
    required File image,
    required String receiverId,
    required String dateTime,
    String text = '',
  }) async {
    try {
      final fileName = DateTime
          .now()
          .millisecondsSinceEpoch
          .toString() +
          "_" +
          image.path
              .split('/')
              .last;

      final storageResponse = await Supabase.instance.client.storage
          .from('messages')
          .upload(fileName, image);

      if (storageResponse.isEmpty) {
        throw Exception("Image upload failed");
      }

      final imageUrl = Supabase.instance.client.storage
          .from('messages')
          .getPublicUrl(fileName);

      sendMessage(
        receiverId: receiverId,
        dateTime: dateTime,
        text: text,
        messageImage: imageUrl,
      );
    } catch (e) {
      emit(SocialSendMessegeErrorState(e.toString()));
    }
  }

/*  Future<void> showLocalNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'default_channel_id',
      'Default Channel',
      channelDescription: 'This channel is used for default notifications.',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails =
    NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformDetails,
    );
  }*/

  Future<void> initializeLocalNotifications() async {
    // Request permissions first (crucial for Android 13+)
    final granted = await requestNotificationPermission();
    if (!granted) {
      print("❌ Notification permission denied!");
      return;
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print('Notification tapped: ${response.payload}');
      },
    );

    // Create high-priority notification channels
    await _createNotificationChannels();

    print("✅ Local notifications initialized successfully");
  }

  void _handleNotificationTap(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');

    if (response.payload != null) {
      final payload = response.payload!;

      if (payload.startsWith('message_alert_')) {
        // Extract user ID from payload
        final userId = payload.replaceFirst('message_alert_', '');

        // Store the navigation data for later use
        _pendingNavigation = {
          'type': 'chat',
          'userId': userId,
        };

        // Emit state to trigger navigation
        emit(SocialNavigationRequiredState(userId));
      } else if (payload == 'chat_reminder') {
        print("Chat reminder notification tapped!");
      }
    }
  }

// Add this variable to store pending navigation
  Map<String, String>? _pendingNavigation;

// Getter for pending navigation
  Map<String, String>? get pendingNavigation => _pendingNavigation;

// Clear pending navigation
  void clearPendingNavigation() {
    _pendingNavigation = null;
  }

  Future<void> _createNotificationChannels() async {
    final androidPlugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      // Chat notifications channel
      const AndroidNotificationChannel chatChannel = AndroidNotificationChannel(
        'chat_channel_id',
        'Chat Notifications',
        description: 'Notifications for new chat messages',
        importance: Importance.max,
        // Changed to max
        playSound: true,
        enableVibration: true,
        enableLights: true,
        ledColor: Color.fromARGB(255, 255, 0, 0),
      );

      // Scheduled notifications channel
      const AndroidNotificationChannel scheduledChannel = AndroidNotificationChannel(
        'scheduled_channel_id',
        'Scheduled Notifications',
        description: 'Scheduled reminder notifications',
        importance: Importance.max,
        // Changed to max
        playSound: true,
        enableVibration: true,
        enableLights: true,
      );

      await androidPlugin.createNotificationChannel(chatChannel);
      await androidPlugin.createNotificationChannel(scheduledChannel);
    }
  }

  Future<void> scheduleLocalNotification({
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'scheduled_channel_id',
      'Scheduled Notifications',
      channelDescription: 'This channel is used for scheduled notifications.',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails platformDetails =
    NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      DateTime
          .now()
          .millisecondsSinceEpoch
          .remainder(100000),
      title,
      body,
      tz.TZDateTime.from(scheduledTime, tz.getLocation('UTC')),
      platformDetails,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  StreamSubscription<QuerySnapshot>? messagesStream;


  // Call to start streaming messages for a chat
  void startMessageStreamer({required String receiverId}) {
    if (userModel == null) {
      emit(SocialGetMessegeErrorState('User not loaded'));
      return;
    }
    messagesStream?.cancel(); // Cancel previous stream if any

    messagesStream = FirebaseFirestore.instance
        .collection('users')
        .doc(userModel!.uId)
        .collection('chats')
        .doc(receiverId)
        .collection('messages')
        .orderBy('dateTime')
        .snapshots()
        .listen((snapshot) {
      List<MessegeModel> newMessages = snapshot.docs
          .map((doc) =>
          MessegeModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      // Trigger notification for new incoming messages
      if (messages.isNotEmpty && newMessages.length > messages.length) {
        var latest = newMessages.last;
        if (latest.senderId != userModel!.uId) {
          showLocalNotification(
            title: "New message from ${latest.receiverId}",
            body: latest.text.isNotEmpty ? latest.text : "Image",
          );
        }
      }

      messages = newMessages;
      emit(SocialGetMessegeSuccessState());
    }, onError: (error) {
      emit(SocialGetMessegeErrorState(error.toString()));
    });
  }

  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'chat_channel_id',
      'Chat Notifications',
      channelDescription: 'Notifications for new chat messages',
      importance: Importance.max,
      // Changed to max
      priority: Priority.max,
      // Changed to max
      playSound: true,
      enableVibration: true,
      enableLights: true,
      icon: '@mipmap/ic_launcher',
      ticker: 'New Message',
      autoCancel: true,
      fullScreenIntent: true,
      // Add this for Xiaomi
      category: AndroidNotificationCategory.message,
      visibility: NotificationVisibility.public,
    );

    const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      DateTime
          .now()
          .millisecondsSinceEpoch
          .remainder(100000),
      title,
      body,
      platformDetails,
      payload: payload,
    );

    print('✅ Notification shown: $title - $body');
  }

  // Dispose the stream when leaving chat
  Future<bool> requestNotificationPermission() async {
    if (Platform.isAndroid) {
      final androidImplementation = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

      // Request notification permission (Android 13+)
      final granted = await androidImplementation
          ?.requestNotificationsPermission() ?? false;

      // Also request exact alarm permission for scheduled notifications
      final exactAlarmGranted = await androidImplementation
          ?.requestExactAlarmsPermission() ?? false;

      print("Notification permission: $granted");
      print("Exact alarm permission: $exactAlarmGranted");

      return granted;
    }
    return true;
  }

  // Search posts by text or tags
  List<PostModel> searchPosts(String query) {
    final lowerQuery = query.toLowerCase();
    return posts.where((post) {
      final textMatch = post.text.toLowerCase().contains(lowerQuery);
      final tagsMatch = post.tags.any((tag) =>
      tag != null && tag.toLowerCase().contains(lowerQuery));
      return textMatch || tagsMatch;
    }).toList();
  }

  List<String> photoUrls = [];

  Future<void> addPhoto() async {
    if (userModel == null) {
      emit(SocialPhotosUpdatedState()); // emit error state if needed
      return;
    }
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final file = File(picked.path);
      final fileName = 'photo_${DateTime
          .now()
          .millisecondsSinceEpoch}.jpg';
      final bytes = await file.readAsBytes();
      // Upload to Supabase bucket 'photos'
      final path = await Supabase.instance.client.storage
          .from('photos')
          .uploadBinary(fileName, bytes);
      if (path.isNotEmpty) {
        final publicUrl = Supabase.instance.client.storage
            .from('photos')
            .getPublicUrl(fileName);
        // Add to Firestore user's photos array
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userModel!.uId)
            .update({
          'photos': FieldValue.arrayUnion([publicUrl])
        });
        photoUrls.add(publicUrl);
        emit(SocialPhotosUpdatedState());
      }
    }
  }


  void removePhoto(String url) async {
    if (userModel == null) {
      emit(SocialPhotosUpdatedState()); // emit error state if needed
      return;
    }
    // Remove from Firestore user's photos array
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userModel!.uId)
        .update({
      'photos': FieldValue.arrayRemove([url])
    });
    photoUrls.remove(url);
    emit(SocialPhotosUpdatedState());
  }
  void clearMessagesStream() {
    messagesStream?.cancel();
    messagesStream = null;
  }

  void deleteChat(String receiverId) async {
    if (userModel == null) {
      emit(SocialDeleteChatErrorState('User not loaded'));
      return;
    }
    // Delete all messages for sender
    var senderMessages = await FirebaseFirestore.instance
        .collection('users')
        .doc(userModel!.uId)
        .collection('chats')
        .doc(receiverId)
        .collection('messages')
        .get();
    for (var doc in senderMessages.docs) {
      await doc.reference.delete();
    }
    // Delete chat for sender
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userModel!.uId)
        .collection('chats')
        .doc(receiverId)
        .delete()
        .then((_) {
      emit(SocialDeleteChatSuccessState());
    }).catchError((error) {
      emit(SocialDeleteChatErrorState(error.toString()));
    });

    // Delete all messages for receiver
    var receiverMessages = await FirebaseFirestore.instance
        .collection('users')
        .doc(receiverId)
        .collection('chats')
        .doc(userModel!.uId)
        .collection('messages')
        .get();
    for (var doc in receiverMessages.docs) {
      await doc.reference.delete();
    }
    // Delete chat for receiver
    await FirebaseFirestore.instance
        .collection('users')
        .doc(receiverId)
        .collection('chats')
        .doc(userModel!.uId)
        .delete()
        .catchError((error) {
      emit(SocialDeleteChatErrorState(error.toString()));
    });
  }


  void deleteMessage(String messageId, String receiverId) {
    if (userModel == null) {
      emit(SocialDeleteMessageErrorState('User not loaded'));
      return;
    }
    // Delete from sender's collection
    FirebaseFirestore.instance
        .collection('users')
        .doc(userModel!.uId)
        .collection('chats')
        .doc(receiverId)
        .collection('messages')
        .doc(messageId)
        .delete()
        .then((_) {
      emit(SocialDeleteMessageSuccessState());
    }).catchError((error) {
      emit(SocialDeleteMessageErrorState(error.toString()));
    });

    // Delete from receiver's collection
    FirebaseFirestore.instance
        .collection('users')
        .doc(receiverId)
        .collection('chats')
        .doc(userModel!.uId)
        .collection('messages')
        .doc(messageId)
        .delete()
        // No need to emit success again
        .catchError((error) {
      emit(SocialDeleteMessageErrorState(error.toString()));
    });
  }
  String formatDate(String? dateTime) {
    if (dateTime == null || dateTime.isEmpty) return 'Unknown';
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
      return 'Unknown';
    }
  }

}
