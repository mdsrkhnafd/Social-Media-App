import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/layout.dart';
import 'package:social_media_app/pages/auth/login_page.dart';
import 'package:social_media_app/providers/user_provider.dart';
import 'access_firebase_token.dart';
import 'firebase_options.dart';
import 'notification/firebase_notification_service.dart';

FirebaseNotificationService firebaseNotificationService =
FirebaseNotificationService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const SocialApp());
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  print('Handling a background message ${message.messageId}');
}

class SocialApp extends StatefulWidget {
  const SocialApp({super.key});

  @override
  State<SocialApp> createState() => _SocialAppState();
}

class _SocialAppState extends State<SocialApp> {


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // getAccessToken();
    firebaseNotificationService.requestNotificationPermission();

    /// TODO: Get device token
    firebaseNotificationService.getDeviceToken().then(
          (value) => {log('Device token: $value')},
    );

    /// TODO: Handle token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
      // Update token in your backend or local storage
      log('New token: $newToken');
    });

    firebaseNotificationService.firebaseInit(context);
    firebaseNotificationService.setupInteractedMessage(context);

    /// TODO: Subscribe to topic here
    subscribeToTopic();
  }

  /// TODO: Get server token
  getAccessToken() async {
    String accessKey = await AccessFirebaseToken().getAccessToken();

    print('Access Key: $accessKey');
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Social Media App',
        theme: ThemeData(
          useMaterial3: true,
          appBarTheme: AppBarTheme(
            surfaceTintColor: Colors.white,
          ),
        ),
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),  // Changed to authStateChanges()
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());  // Show loading while waiting for auth state
            }
            if (snapshot.hasData) {
              // User is signed in
              print("User is signed in");
              return LayoutPage();
            } else {
              // User is signed out
              print("User is signed out");
              return LoginPage();
            }
          },
        ),
      ),
    );
  }

  void subscribeToTopic() async {
    FirebaseMessaging.instance.subscribeToTopic("all").then((_) {
      log('Subscribed to topic: all');
    }).catchError((error) {
      log('Failed to subscribe to topic: $error');
    });
  }
}
