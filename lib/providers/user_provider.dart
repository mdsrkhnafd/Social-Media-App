import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/services/auth.dart';

import '../models/user.dart';

class UserProvider with ChangeNotifier {

  UserModel? userModel;
  bool isLoading = true;

  getDetails() async {
    userModel = await AuthMethods().getUserDetails();

    /// TODO: for Notification
    FirebaseMessaging.instance.requestPermission();
    await FirebaseMessaging.instance.getToken().then((value) {
      if (value != null) {
        userModel!.pushToken = value;
        AuthMethods().getDeviceToken(value);
      }
    });
    isLoading = false;
    notifyListeners();
  }
}