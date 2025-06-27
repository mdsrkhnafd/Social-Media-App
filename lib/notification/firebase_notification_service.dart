import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:app_settings/app_settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../main.dart';

// fbe33077-88d8-4efd-b077-bd79ee47194a
class FirebaseNotificationService {
  FirebaseMessaging messages = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotification =
  FlutterLocalNotificationsPlugin();

  /// TODO : request notification permission
  void requestNotificationPermission() async {
    NotificationSettings settings = await messages.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      log('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      log('User granted provisional permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
      log('User declined or has not accepted permission');
      // Show snackbar or dialog and open notification settings
      Future.delayed(const Duration(seconds: 2)).then((_) {
        AppSettings.openAppSettings(type: AppSettingsType.notification);
      });
    }
  }

  /// TODO : get device token
  Future<String> getDeviceToken() async {
    NotificationSettings settings = await messages.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );
    String? token = await messages.getToken();

    messages.onTokenRefresh.listen((fcmToken) {
      token = fcmToken;
      log('FCM Token refreshed: $token');
    });

    return token!;
  }

  /// TODO : initialize local notification
  void initLocalNotification(
      BuildContext context, RemoteMessage message) async {
    var androidInitialize =
    const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosInitialize = const DarwinInitializationSettings();

    var initializeSettings =
    InitializationSettings(android: androidInitialize, iOS: iosInitialize);

    await flutterLocalNotification.initialize(
      initializeSettings,
      onDidReceiveNotificationResponse: (payload) {
        handleMessage(message);
      },
    );
  }

  /// TODO: firebase init forGroundMessage Notification
  void firebaseInit(BuildContext context) async {
    FirebaseMessaging.onMessage.listen((message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (kDebugMode) {
        print('Notification Title: ${notification!.title}');
        print('Notification Body: ${notification.body}');
      }
      //TODO: for IOS
      if (Platform.isIOS) {
        iosForegroundMessage();
      }

      /// TODO: for Android
      if (Platform.isAndroid) {
        initLocalNotification(context, message);
        // handleMessage(context, message);
        showNotification(message);
      }
    });
  }

  /// TODO: show notification
  Future<void> showNotification(RemoteMessage message) async {
    AndroidNotificationChannel channel = AndroidNotificationChannel(
      'channelId',
      'channelName',
      importance: Importance.high,
      showBadge: true,
      playSound: true,
      enableVibration: true,
      enableLights: true,
    );

    // android setting
    AndroidNotificationDetails androidNotificationDetails =
    AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: 'Channel Description',
      importance: Importance.high,
      // color: Colors.blue,
      playSound: true,
      enableVibration: true,
      enableLights: true,
    );

    // IOS setting
    DarwinNotificationDetails iosNotificationDetails =
    DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    // merge setting
    NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
    );

    // show notification
    await flutterLocalNotification.show(
      0,
      message.notification!.title.toString(),
      message.notification!.body.toString(),
      notificationDetails,
      payload: "my_data",
    );
  }

  /// TODO: background and terminated message notification
  Future<void> setupInteractedMessage(BuildContext context) async {
    // background state
    FirebaseMessaging.onMessageOpenedApp.listen(
          (message) {
        handleMessage(message);
      },
    );

    // terminated state
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null && message.data.isNotEmpty) {
        handleMessage(message);
      }
    });
  }

  /// TODO: handle message
  void handleMessage(RemoteMessage message) {
    print('Message Data: ${message.data}');
    // navigatorKey.currentState?.push(
    //   MaterialPageRoute(builder: (_) => NotificationScreen()),
    // );


    // if (message.data['screen'] == 'cart') {
    //   navigatorKey.currentState?.push(
    //     MaterialPageRoute(builder: (_) => const CartScreen()),
    //   );
    // } else {
    //   navigatorKey.currentState?.push(
    //     MaterialPageRoute(builder: (_) => NotificationScreen(message: message,)),
    //   );
    // }
  }

  /// TODO: foreground message for IOS
  Future iosForegroundMessage() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
}