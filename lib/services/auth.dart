import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/models/user.dart';

class AuthMethods {
  FirebaseAuth _auth = FirebaseAuth.instance;
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  getUserDetails() async {
    User? user = _auth.currentUser; // This can be null after sign-out
    if (user == null) {
      print('No authenticated user found.');
      return;
    }
    if (user != null) {
      DocumentSnapshot documentSnapshot = await users.doc(user.uid).get();
      return UserModel.fromSnap(documentSnapshot);
    } else {
      return null; // Or handle this case appropriately
    }
  }




  signUp({
    required String email,
    required String password,
    required String displayName,
    required String username,
  }) async {
    String res = "Some error occurred";
    try {
      if (email.isNotEmpty ||
          password.isNotEmpty ||
          displayName.isNotEmpty ||
          username.isNotEmpty) {
        UserCredential userCredential = await _auth
            .createUserWithEmailAndPassword(email: email, password: password);

        UserModel userModel = UserModel(
          uid: userCredential.user!.uid,
          email: email,
          displayName: displayName,
          username: username,
          bio: '',
          profilePic: '',
          pushToken: '',
          followers: [],
          following: [],
        );

        users.doc(userCredential.user!.uid).set(userModel.toJson());

        res = "success";
      } else {
        res = "Please enter all the fields";
      }
    } on Exception catch (e) {
      return e.toString();
    }
    return res;
  }

  /// TODO: get device token
  Future getDeviceToken(String token) async {
    await users
        .doc(_auth.currentUser!.uid)
        .update({'push_token': token});
  }

  signIn({
    required String email,
    required String password,
  }) async {
    String res = "Some error occurred";
    try {
      if (email.isNotEmpty || password.isNotEmpty) {
        await _auth.signInWithEmailAndPassword(email: email, password: password);
        res = "success";
      } else {
        res = "Please enter all the fields";
      }
    } on Exception catch (e) {

      return e.toString();
    }
    return res;
  }

}
