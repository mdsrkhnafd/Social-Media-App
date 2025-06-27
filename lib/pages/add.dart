import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/colors/app_color.dart';
import 'package:social_media_app/services/cloud.dart';
import 'package:social_media_app/utils/picker.dart';

import '../models/user.dart';
import '../providers/user_provider.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  XFile? file;
  TextEditingController descCon = TextEditingController();

  uploadPost(String uid , String displayName, String username , String pic , String deviceToken) async {
    try {
      String res = await CloudMethods().uploadPost(
        description: descCon.text,
        uid: uid,
        displayName: displayName,
        file: file!,
        username: username,
        profilePic: pic,
        deviceToken: deviceToken
      );
      if (res == 'success') {
        setState(() {
          file = null;
          descCon.text = '';
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    UserModel userModel = Provider.of<UserProvider>(context).userModel!;
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.white,
        title: Text('Add Post'),
        actions: [
          TextButton(onPressed: () {
            uploadPost(userModel.uid, userModel.displayName, userModel.username, userModel.profilePic , userModel.pushToken);
          }, child: Text('post'),),],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
               userModel.profilePic == "" ? CircleAvatar(
                  backgroundImage: AssetImage('assets/images/man.png'),
                ) : CircleAvatar(
                  backgroundImage: NetworkImage(userModel.profilePic),
               ),
                Gap(20),
                Expanded(
                  child: TextField(
                    controller: descCon,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: 'What is in your mind',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: file == null
                  ? Container()
                  : Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: FileImage(File(file!.path)),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
            ),
            Gap(40),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: kSecondaryColor,
                shape: CircleBorder(),
                padding: EdgeInsets.all(20),
              ),
              onPressed: () async {
                XFile? myFile = await pickImage();
                setState(() {
                  file = myFile;
                });
              },
              child: Icon(Icons.camera, size: 30, color: kWhiteColor),
            ),
            Gap(100),
          ],
        ),
      ),
    );
  }
}
