import 'package:animated_conditional_builder/animated_conditional_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../models/messege_model.dart';
import '../../models/user_model.dart';
import '../cubit/cubit.dart';
import '../cubit/states.dart';
import '../image_viewer_screen/image_viewer_screen.dart';

class ChatDetailsScreen extends StatefulWidget {
  final SocialUserModel userModel;

  ChatDetailsScreen({super.key, required this.userModel});

  @override
  State<ChatDetailsScreen> createState() => _ChatDetailsScreenState();
}

class _ChatDetailsScreenState extends State<ChatDetailsScreen> {
  DateTime? lastMessageTime;

  @override
  void initState() {
    super.initState();

    _startMessageListener();
  }



  Future<void> _startMessageListener() async {
    var cubit = SocialCubit.get(context);

    FirebaseFirestore.instance
        .collection('users')
        .doc(cubit.userModel?.uId)
        .collection('chats')
        .doc(widget.userModel.uId)
        .collection('messages')
        .orderBy('dateTime')
        .snapshots()
        .listen((snapshot) async {
      if (snapshot.docs.isNotEmpty) {
        var latestMessage = snapshot.docs.last.data();
        var messageTime = DateTime.parse(latestMessage['dateTime']);

        if (latestMessage['senderId'] != cubit.userModel?.uId &&
            latestMessage['senderId'] == widget.userModel.uId &&
            (lastMessageTime == null || messageTime.isAfter(lastMessageTime!))) {

          lastMessageTime = messageTime;

          // Include user ID in payload for navigation
          await cubit.showLocalNotification(
            title: "New message from ${widget.userModel.name}",
            body: latestMessage['text']?.isNotEmpty == true
                ? latestMessage['text']
                : latestMessage['messageImage']?.isNotEmpty == true
                ? "📷 Image"
                : "New message",
            payload: "message_alert_${widget.userModel.uId}", // Include user ID
          );
        }
      }
    });
  }




  @override
  Widget build(BuildContext context) {
    var cubit = SocialCubit.get(context);

    return BlocConsumer<SocialCubit, SocialStates>(
      listener: (context, state) {
        if (state is SocialSendMessegeSuccessState) {
          cubit.clearMessageInput();
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back ,
              color: SocialCubit.get(context).isDark? Colors.white : Colors.black,),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            titleSpacing: 0,
            backgroundColor: SocialCubit.get(context).isDark? Colors.blueGrey :Colors.lightBlue[200],
            title: Row(
              children: [
                CircleAvatar(
                  radius: 20.0,
                  backgroundImage: (widget.userModel.image != null &&
                      widget.userModel.image!.isNotEmpty &&
                      Uri.tryParse(widget.userModel.image!) != null &&
                      Uri.parse(widget.userModel.image!).hasScheme)
                      ? NetworkImage(widget.userModel.image!)
                      : null,
                  backgroundColor: Colors.grey[300],
                  child: (widget.userModel.image == null ||
                      widget.userModel.image!.isEmpty ||
                      Uri.tryParse(widget.userModel.image!) == null ||
                      !Uri.parse(widget.userModel.image!).hasScheme)
                      ? Icon(Icons.person, color: Colors.grey[600])
                      : null,
                ),
                SizedBox(width: 15.0),
                Text(
                  widget.userModel.name ?? 'Unknown User',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .doc(cubit.userModel?.uId)
                        .collection('chats')
                        .doc(widget.userModel.uId)
                        .collection('messages')
                        .orderBy('dateTime')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text('Error: ${snapshot.error}'),
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Text(
                            'No messages yet. Start the conversation!',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        );
                      }

                      List<MessegeModel> messages = snapshot.data!.docs
                          .map((doc) => MessegeModel.fromJson(doc.data() as Map<String, dynamic>))
                          .toList();

                      return ListView.separated(
                        physics: BouncingScrollPhysics(),
                        reverse: false,
                        itemBuilder: (context, index) {
                          var message = messages[index];
                          if (message.senderId == cubit.userModel!.uId) {
                            return buildMyMessage(message, context);
                          } else {
                            return buildMessage(message, context);
                          }
                        },
                        separatorBuilder: (context, index) => SizedBox(height: 10.0),
                        itemCount: messages.length,
                      );
                    },
                  ),
                ),
                // Show selected image preview
                if (cubit.selectedMessageImage != null)
                  Container(
                    margin: EdgeInsets.only(bottom: 10.0),
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(10.0),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.file(
                            cubit.selectedMessageImage!,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(width: 10.0),
                        Expanded(
                          child: Text(
                            'Image selected',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                        IconButton(
                          onPressed: () => cubit.clearSelectedMessageImage(),
                          icon: Icon(Icons.close, color: Colors.red),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                    ),
                  ),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1.0),
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  height: 50.0,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: cubit.messageController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: '  Type a message...',
                            hintStyle: TextStyle(
                              color: Theme.of(context).textTheme.bodySmall!.color
                            )
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => cubit.pickMessageImage(),
                        icon: Icon(
                          cubit.selectedMessageImage != null
                              ? Icons.camera_alt
                              : Icons.camera_alt_outlined,
                          color: cubit.selectedMessageImage != null
                              ? Colors.green
                              : Colors.blue,
                          size: 20.0,
                        ),
                      ),
                      Container(
                        height: 60.0,
                        margin: EdgeInsetsDirectional.only(end: 1.0),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: MaterialButton(
                          minWidth: 1.0,
                          onPressed: () {
                            cubit.sendMessageWithImage(
                              receiverId: widget.userModel.uId!,
                              dateTime: DateTime.now().toString(),
                            );
                          },
                          child: Icon(
                            Icons.send,
                            color: Colors.blue,
                            size: 16.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildMessage(MessegeModel message, context) => Align(
    alignment: AlignmentDirectional.centerStart,
    child: Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadiusDirectional.only(
          bottomEnd: Radius.circular(10),
          topEnd: Radius.circular(10),
          topStart: Radius.circular(10),
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 10.0,
        vertical: 5.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (message.messageImage != null && message.messageImage!.isNotEmpty)
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ImageViewerScreen(
                      imageUrl: message.messageImage!,
                      heroTag: 'message_image_${message.dateTime}',
                    ),
                  ),
                );
              },
              child: Hero(
                tag: 'message_image_${message.dateTime}',
                child: Container(
                  margin: EdgeInsets.only(bottom: message.text.isNotEmpty ? 8.0 : 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      message.messageImage!,
                      width: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 200,
                          height: 100,
                          color: Colors.grey[300],
                          child: Icon(Icons.broken_image, color: Colors.grey[600]),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 200,
                          height: 100,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          if (message.text.isNotEmpty)
            Text(
              message.text,
              style: TextStyle(
                color:Colors.black,
              ),
            ),
        ],
      ),
    ),
  );

  Widget buildMyMessage(MessegeModel message, context) => Align(
    alignment: AlignmentDirectional.centerEnd,
    child: Container(
      decoration: BoxDecoration(
        color:SocialCubit.get(context).isDark? Colors.blueGrey :Colors.lightBlue[100],
        borderRadius: BorderRadiusDirectional.only(
          bottomStart: Radius.circular(10),
          topEnd: Radius.circular(10),
          topStart: Radius.circular(10),
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 10.0,
        vertical: 5.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (message.messageImage != null && message.messageImage!.isNotEmpty)
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ImageViewerScreen(
                      imageUrl: message.messageImage!,
                      heroTag: 'my_message_image_${message.dateTime}',
                    ),
                  ),
                );
              },
              child: Hero(
                tag: 'my_message_image_${message.dateTime}',
                child: Container(
                  margin: EdgeInsets.only(bottom: message.text.isNotEmpty ? 8.0 : 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      message.messageImage!,
                      width: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 200,
                          height: 100,
                          color: Colors.grey[300],
                          child: Icon(Icons.broken_image, color: Colors.grey[600]),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: 200,
                          height: 100,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          if (message.text.isNotEmpty)
            Text(
              message.text ,
              style: TextStyle(
                color:Theme.of(context).textTheme.bodySmall!.color,
              ),
            ),
        ],
      ),
    ),
  );
}