import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:image_stack/image_stack.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/colors/app_color.dart';
import 'package:social_media_app/models/user.dart';
import 'package:social_media_app/services/cloud.dart';
import 'package:social_media_app/widgets/post_card.dart';

import '../providers/user_provider.dart';
import '../services/auth.dart';
import 'auth/login_page.dart';
import 'edit_user.dart';

class ProfilePage extends StatefulWidget {
  final String uid;
  const ProfilePage({super.key, required this.uid});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  late TabController tabController = TabController(length: 2, vsync: this);
  String myUid = FirebaseAuth.instance.currentUser!.uid;

  var userInfo = {};
  bool isFollowing = false;
  bool isLoading = true;
  getUserData() async {
    try {
      var userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();
      userInfo = userData.data()!;
      isFollowing = (userData.data()! as dynamic)['followers'].contains(myUid);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void initState() {
    // Fetch user details when the profile page is loaded
    Provider.of<UserProvider>(context, listen: false).getDetails();
    getUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Safely check if userModel is null
    UserModel? userModel = Provider.of<UserProvider>(context).userModel;
      return isLoading ? Scaffold(
        appBar: AppBar(),
        body: Center(
          child: CircularProgressIndicator(),
        ), // Show loading until user details are fetched
      )

    // If userModel is not null, proceed with the UI
    : Scaffold(
      appBar: userInfo['uid'] == myUid ?  AppBar(
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditUserPage()),
              );
            },
            icon: Icon(Icons.edit),
          ),
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance
                  .signOut(); // Sign the user out from Firebase
              debugPrint('User logged out');

              // Navigate to LoginPage after sign-out
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
            icon: Icon(Icons.logout_rounded),
          ),
        ],
      ) : AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Display user profile picture or default image
            Row(
              children: [
                userModel!.profilePic == ""
                    ? const CircleAvatar(
                        radius: 40,
                        backgroundImage: AssetImage('assets/images/man.png'),
                      )
                    : CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(userModel.profilePic),
                      ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: kWhiteColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      ImageStack(
                        imageSource: ImageSource.Asset,
                        imageList: [
                          'assets/images/man.png',
                          'assets/images/woman.png',
                        ],
                        totalCount: 0,
                        imageRadius: 30,
                        imageBorderWidth: 2,
                        imageBorderColor: Colors.white,
                      ),
                      Gap(5),
                      Row(children: [
                        StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .doc(widget.uid)
                              .snapshots(),
                          builder: (context, asyncSnapshot) {
                            if (asyncSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (asyncSnapshot.hasError) {
                              return Text('Error');
                            } else if (asyncSnapshot.data!.exists) {
                              dynamic data =
                                  asyncSnapshot.data!.data()!;
                              return Text(data['followers'].length.toString());
                            } else {
                              return Text('0');
                            }
                          }
                        ),
                        Gap(5),
                        Text('Followers'),],),
                    ],
                  ),
                ),
                Gap(15),
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: kWhiteColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      ImageStack(
                        imageSource: ImageSource.Asset,
                        imageList: [
                          'assets/images/man.png',
                          'assets/images/woman.png',
                        ],
                        totalCount: 0,
                        imageRadius: 30,
                        imageBorderWidth: 2,
                        imageBorderColor: Colors.white,
                      ),
                      Gap(5),
                      Row(children: [
                        StreamBuilder(
                          stream: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(widget.uid)
                                  .snapshots(),
                          builder: (context, asyncSnapshot) {
                            if (asyncSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            } else if (asyncSnapshot.hasError) {
                              return Text('Error');
                            } else if (asyncSnapshot.data!.exists) {
                              dynamic data =
                                  asyncSnapshot.data!.data()!;
                              return Text(data['following'].length.toString());
                            }
                            return Text('0');
                          }
                        ),
                        Gap(5),
                        Text('Following'),
                      ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Gap(5),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(0),
                    title: Text(
                      userInfo['displayName'],
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text("@" + userInfo['username']),
                  ),
                ),
                userInfo['uid'] == myUid ? Container() : Row(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: kWhiteColor,
                        backgroundColor: kPrimaryColor,
                      ),
                      onPressed: () async {
                        if (userInfo['uid'] != myUid) {
                          await CloudMethods().followUser(myUid, userInfo['uid']);
                          setState(() {
                            isFollowing = !isFollowing;
                          });
                        }
                      },
                      child: Row(
                        children: [Text(isFollowing ? 'UnFollow' : 'Follow'), Gap(5), Icon( isFollowing ? Icons.remove : Icons.add)],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(
                          side: BorderSide(color: kSecondaryColor),
                        ),
                        foregroundColor: kSecondaryColor,
                        backgroundColor: Colors.white,
                      ),
                      onPressed: () {},
                      child: Icon(Icons.message),
                    ),
                  ],
                ),
              ],
            ),
            Gap(10),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: kPrimaryColor.withOpacity(0.2),
                    ),
                    child: Center(
                      child: Text(
                        userInfo['bio'] == "" ? "BIO" : userInfo['bio'],
                        style: TextStyle(color: kPrimaryColor, fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Gap(10),
            TabBar(
              controller: tabController,
              tabs: [
                Tab(text: 'Photos'),
                Tab(text: 'Posts'),
              ],
            ),
            Gap(20),
            Expanded(
              child: TabBarView(
                controller: tabController,
                children: [
                  // Photos tab logic (StreamBuilder for photos)
                  StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('posts')
                        .where(
                          'uid',
                          isEqualTo: userInfo['uid'],
                        )
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error'));
                      } else if (snapshot.data!.docs.isEmpty) {
                        return Center(child: Text('No Photos'));
                      } else {
                        dynamic data = snapshot.data! as dynamic;
                        return RefreshIndicator(
                          onRefresh: () async {
                            setState(() {
                              getUserData();
                            });
                          },
                          child: GridView.builder(
                            itemCount: snapshot.data!.docs.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  mainAxisSpacing: 3,
                                  crossAxisSpacing: 3,
                                ),
                            itemBuilder: (context, index) {
                              dynamic item = data.docs[index];
                              return Container(
                                padding: const EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  color: kPrimaryColor,
                                  borderRadius: BorderRadius.circular(6),
                                  image: DecorationImage(
                                    fit: BoxFit.fill,
                                    image: NetworkImage(item['postImage']),
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }
                    },
                  ),
                  // Posts tab logic (StreamBuilder for posts)
                  StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('posts')
                        .where(
                          'uid',
                          isEqualTo: userInfo['uid'],
                        )
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error'));
                      } else if (snapshot.data!.docs.isEmpty) {
                        return Center(child: Text('No Posts'));
                      } else {
                        dynamic data = snapshot.data! as dynamic;
                        return ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            dynamic item = data.docs[index];
                            return PostCard(item: item);
                          },
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
