import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/post.dart';
import '../notification/sent_notification_service.dart';
import '../providers/user_provider.dart';
import 'cloudinary.dart';

class CloudMethods {
  CollectionReference posts = FirebaseFirestore.instance.collection('posts');
  CollectionReference users = FirebaseFirestore.instance.collection('users');

  // Method to upload a post with an image
  uploadPost({
    required String description,
    required String uid,
    required String displayName,
    required String username,
    required XFile file, // Image as Uint8List
    String? profilePic, // Optional profile picture
    String? deviceToken,
  }) async {
    String res = "Some error occurred";

    try {
      String postId = Uuid().v1();
      // Upload image to Cloudinary and get the image URL
      String? postImage = await CloudinaryMethod().uploadImageToCloudinary(
        file,
        'posts',
        true,
      );

      // If image upload fails, return an error message
      if (postImage == null) {
        res = "Failed to upload image.";
        return res;
      }

      // Create a PostModel object
      PostModel postModel = PostModel(
        uid: uid,
        displayName: displayName,
        username: username,
        profilePic: profilePic ?? "", // Default to empty string if null
        description: description,
        postId: postId,
        postImage: postImage, // Store the image URL
        pushToken: deviceToken ?? "",
        date: DateTime.now(),
        like: [], // Initialize likes as empty
      );

      // Store the post data in Firestore
      await posts.doc(postId).set(postModel.toJson());

      res = "success";
    } catch (err) {
      res = err.toString();
      debugPrint("Error uploading post: $err");
    }

    return res; // Return result (success or error message)
  }

  // Method for comments to a post
  commentPost({
    required String postId,
    required String uid,
    required String fromUid,
    required String displayName,
    required String username,
    required String profilePic,
    required String commentText,
    required BuildContext context,
    required String deviceToken,
  }) async {
    String res = "Some error occurred";
    try {
      if (commentText.isNotEmpty) {
        String commentId = Uuid().v1();
        await posts.doc(postId).collection("comments").doc(commentId).set({
          "commentId": commentId,
          "profilePic": profilePic,
          "displayName": displayName,
          "username": username,
          "uid": uid,
          "fromUid": fromUid,
          "commentText": commentText,
          "date": DateTime.now(),

        }).then((value) => {
          SentNotificationService.sendNotificationUsingApi(
            deviceToken: deviceToken,
            message: commentText,
            context: context,
          )
        });
        res = "success";
      } else {
        res = "Please enter text";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }

  // Method to like a post
  likePost(String postId, String uid, List likes) async {
    String res = "Some error occurred";
    try {
      if (likes.contains(uid)) {
        await posts.doc(postId).update({
          "like": FieldValue.arrayRemove([uid]),
        });
      } else {
        await posts.doc(postId).update({
          "like": FieldValue.arrayUnion([uid]),
        });
      }
      res = "success";
    } catch (e) {
      res = e.toString();
      print(e.toString());
    }
    return res;
  }

  // Method for Follow and Unfollow
  followUser(String uid, String followUserId) async {
    String res = "Some error occurred";
    try {
      // Fetching the data of the current user (uid)
      DocumentSnapshot snap = await users.doc(uid).get();

      // Get the list of users that the current user is following
      List following = (snap.data()! as dynamic)['following'];

      // Check if the current user is already following the target user (followUserId)
      if (following.contains(followUserId)) {
        // If already following, unfollow by removing the target user from both lists
        await users.doc(uid).update({
          'following': FieldValue.arrayRemove([followUserId]),  // Remove from following list
        });

        await users.doc(followUserId).update({
          'followers': FieldValue.arrayRemove([uid]),  // Remove from followers list of the target user
        });
      } else {
        // If not following, follow the user by adding the target user to following list and vice versa
        await users.doc(uid).update({
          'following': FieldValue.arrayUnion([followUserId]),  // Add to following list
        });

        await users.doc(followUserId).update({
          'followers': FieldValue.arrayUnion([uid]),  // Add to followers list of the target user
        });
      }
      res = "success";  // Operation was successful
    } catch (e) {
      res = e.toString();  // Error message if the operation fails
      print(e.toString());
    }
    return res;
  }

  // Method for deleting a post
  Future<String> deletePost(String postId) async {
    String res = "Some error occurred";
    try {
      // Get the logged-in user
      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        return "User is not logged in";  // Return an error if no user is logged in
      }

      // Get the post data to verify if the current user is the owner
      DocumentSnapshot postSnap = await posts.doc(postId).get();

      // Check if the logged-in user is the owner of the post
      if (postSnap['uid'] != user.uid) {
        return "You are not the owner of this post";  // Return a message if the user is not the owner
      }

      // 1. Delete all comments associated with the post
      var commentsSnapshot = await posts
          .doc(postId)
          .collection('comments')
          .get();  // Get all the comments for the post

      // Check if comments exist
      if (commentsSnapshot.docs.isEmpty) {
        print('No comments found for postId: $postId');
      }

      // Delete each comment
      for (var comment in commentsSnapshot.docs) {
        print('Deleting comment: ${comment.id}');
        await comment.reference.delete();  // Delete each comment
      }

      // 2. Delete the post itself
      print('Deleting post: $postId');
      await posts.doc(postId).delete();  // Delete the post from Firestore

      res = "success";  // Return success after deletion
    } catch (err) {
      res = err.toString();  // Return error message if something goes wrong
      print("Error deleting post and comments: $err");
    }
    return res;
  }

  // Method for edit profile
  editProfile({
    required String uid,
    required String displayName,
    required String username,
    XFile? file,
    String bio = "",
    String profilePic = "",
  }) async {
    String res = "Some error occurred";
    try {
      profilePic = file != null
          ? await CloudinaryMethod().uploadImageToCloudinary(
              file,
              'users',
              true,
            )
          : "";

      if (displayName != "" && username != "") {
        await users.doc(uid).update({
          "displayName": displayName,
          "username": username,
          "bio": bio,
          "profilePic": profilePic,
        });
        res = "success";
      }
    } catch (err) {
      res = err.toString();
    }
    return res;
  }
}
