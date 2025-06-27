import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  String uid;
  String displayName;
  String username;
  String profilePic;
  String description;
  String postId;
  String postImage;
  String pushToken;
  DateTime date;
  dynamic like;

  PostModel({
    required this.uid,
    required this.displayName,
    required this.username,
    required this.profilePic,
    required this.description,
    required this.postId,
    required this.postImage,
    required this.pushToken,
    required this.date,
    required this.like
  });

  factory PostModel.fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return PostModel(
        uid: snapshot['uid'],
        displayName: snapshot['displayName'],
        username: snapshot['username'],
        profilePic: snapshot['profilePic'],
        description: snapshot['description'],
        postId: snapshot['postId'],
        postImage: snapshot['postImage'],
        pushToken: snapshot['pushToken'],
        date: snapshot['date'],
        like: snapshot['like']
    );
  }

  Map<String, dynamic> toJson() => {
    "uid": uid,
    "displayName": displayName,
    "username": username,
    "profilePic": profilePic,
    "description": description,
    "postId": postId,
    "postImage": postImage,
    "pushToken": pushToken,
    "date": date,
    "like": like
  };
}