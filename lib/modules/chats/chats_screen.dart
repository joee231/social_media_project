import 'package:animated_conditional_builder/animated_conditional_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import '../../models/user_model.dart';
import '../../shared/components/compnents.dart';
import '../chat_details/chat_details_screen.dart';
import '../cubit/cubit.dart';
import '../cubit/states.dart';

class ChatsScreen extends StatelessWidget {
  const ChatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SocialCubit , SocialStates>(
      listener: (context , state) {},
      builder: (context , state) {
        return AnimatedConditionalBuilder(
          condition: SocialCubit.get(context).users.isNotEmpty,
          builder: (context) => ListView.separated(
            itemBuilder: (context, index) => buildChatItem(context , SocialCubit.get(context).users[index], ),
            separatorBuilder: (context, index) => myDividor(),
            itemCount: SocialCubit.get(context).users.length,
          ),
          fallback: (context) => Center(
            child: Text(
              'No Chats Yet',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                height: 1.4,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }
    );

  }

  Widget buildChatItem( BuildContext context , SocialUserModel model) {
    return InkWell(
      onTap: () {
        navigateTo(context, ChatDetailsScreen(userModel: model));
      },
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25.0,
              backgroundImage: NetworkImage(model.image),
            ),
            SizedBox(width: 15.0),
            Text(
              model.name,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                height: 1.4,
                fontWeight: FontWeight.bold,
              ),
            ),

          ],
        ),
      ),
    );
  }
}
