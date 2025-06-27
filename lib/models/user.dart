import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String uid;
  String email;
  String displayName;
  String username;
  String bio;
  String profilePic;
  String pushToken;
  List followers;
  List following;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.username,
    required this.bio,
    required this.profilePic,
    required this.pushToken,
    required this.followers,
    required this.following
});

  factory UserModel.fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return UserModel(
      uid: snapshot['uid'],
      email: snapshot['email'],
      displayName: snapshot['displayName'],
      username: snapshot['username'],
      bio: snapshot['bio'],
      profilePic: snapshot['profilePic'],
      pushToken: snapshot['pushToken'],
      followers: snapshot['followers'],
      following: snapshot['following']
    );
  }

  Map<String, dynamic> toJson() => {
    "uid": uid,
    "email": email,
    "displayName": displayName,
    "username": username,
    "bio": bio,
    "profilePic": profilePic,
    "pushToken": pushToken,
    "followers": followers,
    "following": following
  };
}