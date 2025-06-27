import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class CloudinaryMethod {

  FirebaseAuth auth = FirebaseAuth.instance;

  uploadImageToCloudinary(XFile file , String childName, bool isPost) async {
    String ext = file.path.split('.').last;

    final cloudinary = CloudinaryPublic('dcoyszecc', 'vuwyknwj');
    CloudinaryResponse? cloudinaryResponse;
    // upload each image to Cloudinary
    if (isPost) {
      cloudinaryResponse = await cloudinary.uploadFile(
          CloudinaryFile.fromFile( file.path, folder: '$childName/${DateTime.now().millisecondsSinceEpoch}.$ext', resourceType: CloudinaryResourceType.Image));
    }

    String imageUrl =
        cloudinaryResponse!.secureUrl;

    debugPrint('Image URL: $imageUrl');

    return imageUrl;
  }

  // uploadProfilePic(XFile file) async {
  //   String ext = file.path.split('.').last;
  //
  //   final cloudinary = CloudinaryPublic('dcoyszecc', 'vuwyknwj');
  //
  //   // upload each image to Cloudinary
  //   CloudinaryResponse cloudinaryResponse = await cloudinary.uploadFile(
  //       CloudinaryFile.fromFile( file.path, folder: 'profile/${DateTime.now().millisecondsSinceEpoch}.$ext', resourceType: CloudinaryResourceType.Image));
  //
  //   String imageUrl =
  //       cloudinaryResponse.secureUrl;
  //
  //   return imageUrl;
  // }
}