import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import '../colors/app_color.dart';
import '../models/user.dart';
import '../notification/sent_notification_service.dart';
import '../providers/user_provider.dart';
import '../services/cloud.dart';

class CommentScreen extends StatefulWidget {
  final postId;
  final uid;
  final pushToken;
  const CommentScreen({super.key , required this.postId , required this.uid , required this.pushToken});

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  TextEditingController commentCon = TextEditingController();
  final myUid = FirebaseAuth.instance.currentUser!.uid;
  postComment(String uid, String displayName, String username, String profilePic) async {
    String res = await CloudMethods().commentPost(
      postId: widget.postId,
      uid: widget.uid,
      fromUid: myUid,
      displayName: displayName,
      username: username,
      profilePic: profilePic,
      commentText: commentCon.text,
      context: context,
      deviceToken: widget.pushToken
    );
    if (res == 'success') {

      setState(() {
        commentCon.text = '';
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    debugPrint(widget.postId);
    debugPrint(widget.uid);
    debugPrint(myUid);
  }

  @override
  Widget build(BuildContext context) {
    UserModel userModel = Provider.of<UserProvider>(context).userModel!;
    return Scaffold(
      appBar: AppBar(surfaceTintColor: Colors.white, title: Text('Comments')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('posts')
                    .doc(widget.postId)
                    .collection('comments')
                    .snapshots(),
                builder: (context, asyncSnapshot) {
                  if (asyncSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (asyncSnapshot.hasError) {
                    return Center(child: Text('Error'));
                  } else if (asyncSnapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No comments'));
                  } else {
                  return ListView.builder(
                    itemCount: asyncSnapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      dynamic item = asyncSnapshot.data!.docs[index];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: kWhiteColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  item['profilePic'] == "" ? CircleAvatar(backgroundImage: AssetImage('assets/images/man.png'),) : CircleAvatar(
                                    backgroundImage: NetworkImage(item['profilePic']),
                                  ),
                                  Gap(10),
                                  Text(
                                    item['displayName'],),
                                  Spacer(),
                                  Text(item['date'].toDate().toString()),
                                ],
                              ),
                              Gap(10),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      item['commentText'],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                  }
                }
              )
            ),
            Gap(10),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: kPrimaryColor),
                      color: kWhiteColor,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: TextField(
                      controller: commentCon,
                      cursorColor: kPrimaryColor,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.all(8.0),
                        hintText: 'Type a comment...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                Gap(10),
                IconButton(
                  style: ButtonStyle(
                    padding: const MaterialStatePropertyAll(EdgeInsets.all(16)),
                    backgroundColor: MaterialStatePropertyAll(kSecondaryColor),
                    foregroundColor: MaterialStatePropertyAll(kWhiteColor),
                  ),
                  icon: Icon(Icons.send),
                  onPressed: () async {
                    await postComment(
                      userModel.uid,
                      userModel.displayName,
                      userModel.username,
                      userModel.profilePic,
                    );
                  },
                ),
              ],
            ),
            Gap(10),
          ],
        ),
      ),
    );
  }
}
