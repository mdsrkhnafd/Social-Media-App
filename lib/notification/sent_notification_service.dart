import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:social_media_app/models/user.dart';
import '../access_firebase_token.dart';
import '../providers/user_provider.dart';

class SentNotificationService {
  /// TODO: send Notification From One device to another device
  static Future<void> sendNotificationUsingApi({
     required String? deviceToken,
     required String? message,
    required BuildContext context,
  }) async {

    try {
      String severKey = await AccessFirebaseToken().getAccessToken();
      print('severKey: $severKey');
      String url = 'https://fcm.googleapis.com/v1/projects/photoblog-565fc/messages:send';

      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $severKey',
      };

      // message
      Map<String, dynamic> body = {
        "message" : {
          "token" :deviceToken,
          "notification" : {
            "title" : Provider.of<UserProvider>(context , listen: false).userModel!.displayName,
            "body" : message,
          },
        }
      };

      // TODO: hit api
      final http.Response response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print('Notification sent successfully');
      } else {
        print('Failed to send notification');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }

  }

  /// TODO: send Notification to Group
  // static Future<void> sendGroupNotificationUsingApi({
  //   required UserModel? userModel,
  //   required String? message,
  //   required BuildContext context,
  //   String? groupName,
  // }) async {
  //
  //   try {
  //     String severKey = await AccessFirebaseToken().getAccessToken();
  //     print('severKey: $severKey');
  //     String url = 'https://fcm.googleapis.com/v1/projects/chat-material3-5ecfd/messages:send';
  //
  //     var headers = {
  //       'Content-Type': 'application/json',
  //       'Authorization': 'Bearer $severKey',
  //     };
  //
  //     // message
  //     Map<String, dynamic> body = {
  //       "message" : {
  //         "token" : userModel!.pushToken,
  //         "notification" : {
  //           "title" : groupName == null ? Provider.of<ProviderApp>(context , listen: false).me!.name : groupName + " : " + "${Provider.of<ProviderApp>(context , listen: false).me!.name}",
  //           "body" : message,
  //         },
  //       }
  //     };
  //
  //     // TODO: hit api
  //     final http.Response response = await http.post(
  //       Uri.parse(url),
  //       headers: headers,
  //       body: jsonEncode(body),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       print('Notification sent successfully');
  //     } else {
  //       print('Failed to send notification');
  //     }
  //   } catch (e) {
  //     print('Error sending notification: $e');
  //   }
  //
  // }

  /// TODO: send Topic Notification
  static Future<void> sendTopicNotificationUsingApi({
    required String? topic,
    required String? title,
    required String? body,
    required Map<String, dynamic>? data,
  }) async {

    try {
      String severKey = await AccessFirebaseToken().getAccessToken();
      print('severKey: $severKey');
      String url = 'https://fcm.googleapis.com/v1/projects/chat-material3-5ecfd/messages:send';

      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $severKey',
      };

      // message
      Map<String, dynamic> message = {
        "message" : {
          "topic" : topic,
          "notification" : {
            "title" : title,
            "body" : body,
          },
          "data" : data
        }
      };

      // TODO: hit api
      final http.Response response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(message),
      );

      if (response.statusCode == 200) {
        print('Notification sent successfully');
      } else {
        print('Failed to send notification');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }

  }

  /// TODO: send Multicast Notification
  static Future<void> sendMulticastNotificationUsingApi({
    required List targetTokens,
    required String? title,
    required String? body,
  }) async {

    try {
      String severKey = await AccessFirebaseToken().getAccessToken();
      print('severKey: $severKey');
      String url = 'https://fcm.googleapis.com/v1/projects/chat-material3-5ecfd/messages:send';

      for (String token in targetTokens) {
        var headers = {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $severKey',
        };
        // message
        final message = {
          "message": {
            "token": token,
            "notification": {
              "title": title,
              "body": body,
            },
          }
        };

        // TODO: hit api
        final http.Response response = await http.post(
          Uri.parse(url),
          headers: headers,
          body: jsonEncode(message),
        );

        if (response.statusCode == 200) {
          print('Notification sent successfully');
        } else {
          print('Failed to send notification');
        }
      }

    } catch (e) {
      print('Error sending notification: $e');
    }

  }
}