import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/pages/comment_screen.dart';
import 'package:social_media_app/services/cloud.dart';

import '../colors/app_color.dart';
import '../models/user.dart';
import '../providers/user_provider.dart';

class PostCard extends StatefulWidget {
  final item;
  const PostCard({super.key, required this.item});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  String myUid = FirebaseAuth.instance.currentUser!.uid;  // Get current user's UID

  @override
  Widget build(BuildContext context) {
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
              children: [
                widget.item['profilePic'] == ""
                    ? CircleAvatar(
                  backgroundImage: AssetImage('assets/images/man.png'),
                )
                    : CircleAvatar(
                  backgroundImage: NetworkImage(widget.item['profilePic']),
                ),
                Gap(10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.item['displayName']),
                    Text("@" + widget.item['username']),
                  ],
                ),
                Spacer(),
                Text(widget.item['date'].toDate().toString()),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: widget.item['postImage'] != ""
                      ? Container(
                    height: 300,
                    margin: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(widget.item['postImage']),
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                      : Container(),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(child: Text(widget.item['description'], maxLines: 3)),
              ],
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () async {
                    await CloudMethods().likePost(
                      widget.item['postId'],
                      myUid,  // Use current user's UID to like the post
                      widget.item['like'],
                    );
                  },
                  icon: widget.item['like'].contains(myUid)
                      ? Icon(Icons.favorite, color: Colors.red)
                      : Icon(Icons.favorite_outline),
                ),
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('posts')
                      .doc(widget.item['postId'])
                      .snapshots(),
                  builder: (context, asyncSnapshot) {
                    if (asyncSnapshot.connectionState == ConnectionState.waiting) {
                      return Text('0');
                    } else if (asyncSnapshot.hasError) {
                      return Text('0');
                    } else {
                      return Text(asyncSnapshot.data!['like'].length.toString());
                    }
                  },
                ),
                Gap(20),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CommentScreen(postId: widget.item['postId'] , uid: widget.item['uid'],pushToken: widget.item['pushToken'],),
                      ),
                    );
                  },
                  icon: Icon(Icons.comment),
                ),
                StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('posts')
                      .doc(widget.item['postId'])
                      .collection('comments')
                      .snapshots(),
                  builder: (context, asyncSnapshot) {
                    if (asyncSnapshot.connectionState == ConnectionState.waiting) {
                      return Text('0');
                    } else if (asyncSnapshot.hasError) {
                      return Text('0');
                    } else if (asyncSnapshot.data!.docs.isEmpty) {
                      return Text('0');
                    } else {
                      return Text(asyncSnapshot.data!.docs.length.toString());
                    }
                  },
                ),
                const Spacer(),
                // Only allow post deletion if the logged-in user is the post owner
                widget.item['uid'] == myUid
                    ? IconButton(
                  onPressed: () async {
                    // Call deletePost method when delete button is pressed
                    await CloudMethods().deletePost(widget.item['postId']);
                    debugPrint('Post deleted');
                  },
                  icon: Icon(Icons.delete, color: Colors.red),
                )
                    : Container(),  // Do nothing if not the owner
              ],
            ),
          ],
        ),
      ),
    );
  }
}

