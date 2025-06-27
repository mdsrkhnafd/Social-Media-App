import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/models/user.dart';
import 'package:social_media_app/services/cloud.dart';

import '../colors/app_color.dart';
import '../providers/user_provider.dart';
import '../utils/picker.dart';

class EditUserPage extends StatefulWidget {
  const EditUserPage({super.key});

  @override
  State<EditUserPage> createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  XFile? file;

  @override
  Widget build(BuildContext context) {
    UserModel userModel = Provider.of<UserProvider>(context).userModel!;
    TextEditingController displayNameCon = TextEditingController(
      text: userModel.displayName,);
    TextEditingController userNameCon = TextEditingController(
      text: userModel.username,
    );
    TextEditingController bioCon = TextEditingController(text: userModel.bio);


    updateUser() async {
      try {
        String res = await CloudMethods().editProfile(
          uid: userModel.uid,
          displayName: displayNameCon.text,
          username: userNameCon.text,
          bio: bioCon.text,
          file: file,
        );

        if (res == 'success') {
          Navigator.pop(context);
        }
      } catch (e) {
        print(e);
      }
      Provider.of<UserProvider>(context, listen: false).getDetails();
    }

    return Scaffold(
      appBar: AppBar(title: Text('Profile Details')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              Gap(20),
              Center(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    userModel.profilePic != "" ? CircleAvatar(
                      radius: 70,
                      backgroundImage: NetworkImage(userModel.profilePic),
                    ) :
                    file == null
                        ? CircleAvatar(
                            radius: 70,
                            backgroundImage: AssetImage(
                              'assets/images/man.png',
                            ),
                          )
                        : CircleAvatar(
                            radius: 70,
                            backgroundImage: FileImage(File(file!.path)),
                          ),
                    Positioned(
                      bottom: -10,
                      right: -10,
                      child: IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          XFile? _file = await pickImage();
                          setState(() {
                            file = _file;
                          });
                        },
                        icon: Icon(Icons.edit, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              Gap(30),
              TextField(
                controller: displayNameCon,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  fillColor: kWhiteColor,
                  filled: true,
                  prefixIcon: Icon(Icons.person),
                  labelText: 'Display Name',
                  labelStyle: TextStyle(color: kPrimaryColor),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: kPrimaryColor),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              Gap(20),
              TextField(
                controller: userNameCon,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  fillColor: kWhiteColor,
                  filled: true,
                  prefixIcon: Icon(Icons.attachment_sharp),
                  labelText: 'User Name',
                  labelStyle: TextStyle(color: kPrimaryColor),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: kPrimaryColor),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              Gap(20),
              TextField(
                controller: bioCon,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  fillColor: kWhiteColor,
                  filled: true,
                  prefixIcon: Icon(Icons.info),
                  labelText: 'BIO',
                  labelStyle: TextStyle(color: kPrimaryColor),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: kPrimaryColor),
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              Gap(20),
              // update button
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.all(16),
                        backgroundColor: kSecondaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        updateUser();
                      },
                      child: Text(
                        'Update'.toUpperCase(),
                        style: TextStyle(color: kWhiteColor),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
