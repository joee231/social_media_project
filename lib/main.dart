import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialmediaproject/modules/cubit/states.dart';
import 'package:socialmediaproject/shared/components/compnents.dart';
import 'package:socialmediaproject/shared/components/constants.dart';
import 'package:socialmediaproject/shared/network/bloc_observer.dart';
import 'package:socialmediaproject/shared/network/local/cash_helper.dart';
import 'package:socialmediaproject/shared/network/remote/dio_helper.dart';
import 'package:socialmediaproject/shared/style/themes.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;




import 'layout/social_layout.dart';
import 'modules/cubit/cubit.dart';
import 'modules/login_screen/cubit/cubit.dart';
import 'modules/login_screen/cubit/states.dart';
import 'modules/login_screen/social_login-screen.dart';



void createNotificationChannel() async {
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'default_channel_id', // Must match value in AndroidManifest.xml
    'Default Channel',
    description: 'This channel is used for default notifications.',
    importance: Importance.high,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
}

final supabase = Supabase.instance.client; // Thi
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
  print(' background message data: ${message.data}');
  showToast(text: 'on background message', state: ToastStates.SUCCESS);

}


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones(); // Add this line
  await Firebase.initializeApp();

  await CashHelper.init(); // Ensure cache is initialized first
  DioHelper.init();
  await Supabase.initialize(
    url: 'https://bvyadusivaukkvnpksjd.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJ2eWFkdXNpdmF1a2t2bnBrc2pkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQ5MjEyMDYsImV4cCI6MjA3MDQ5NzIwNn0.qDj3qM60hNAk207AG1sk1wcq4qoIesFwOdj_d0zPyJc',
  );

  var token = await FirebaseMessaging.instance.getToken();
  print('Firebase Messaging Token: $token');

  // Load settings
  bool isDark = CashHelper.getData(key: 'isDark') ?? false;
  uId = CashHelper.getData(key: 'uID');
  Widget startWidget;
  if (uId != null && uId!.isNotEmpty) {
    startWidget = SocialLayout();
  } else {
    startWidget = SocialLoginScreen();
  }

  runApp(MyApp(isDark: isDark, startWidget: startWidget));
}

class MyApp extends StatelessWidget {
  final bool isDark;
  final Widget startWidget;

  const MyApp({super.key, required this.isDark, required this.startWidget});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => SocialLoginCubit(),
        ),
        BlocProvider(
          create: (context) {
            final cubit = SocialCubit(isDark: isDark);
            if (uId != null && uId!.isNotEmpty) {
              cubit.getUserData();
              cubit.getPosts();
            }
            return cubit;
          },
        ),
      ],
      child: BlocConsumer<SocialCubit, SocialStates>(
        listener: (context, state) {
          if (state is SocialNavigationRequiredState) {
            navigateTo(context, state.userId);
          }
        },
        builder: (context, state) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: lighttheme,
            darkTheme: darktheme,
            themeMode: (SocialCubit.get(context).isDark ? ThemeMode.dark : ThemeMode.light),
            home: startWidget,
          );
        },
      ),
    );
  }
}
