import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:social_media_app/colors/app_color.dart';

import '../widgets/post_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    CollectionReference posts = FirebaseFirestore.instance.collection('posts');
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text.rich(TextSpan(children: [
          TextSpan(text: '06', style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18)),
          TextSpan(
              text: '16',
              style: TextStyle(fontSize: 26, color: kPrimaryColor , fontWeight: FontWeight.bold)),],),),
        actions: [
          IconButton(onPressed: (){}, icon: Icon(Icons.message))
        ],
      ),
      body: StreamBuilder(
        stream: posts.orderBy('date', descending: true).snapshots(),
        builder: (context, asyncSnapshot) {
          if (asyncSnapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(),);
          } else if (asyncSnapshot.hasError) {
            return Center(child: Text('Error'),);
          } else if (asyncSnapshot.data!.docs.isEmpty) {
            return Center(child: Text('No posts'),);
          } else {
           // Map<String, dynamic> data = asyncSnapshot.data! as Map<String, dynamic>;
           dynamic data = asyncSnapshot.data! as dynamic;
          return ListView.builder(
            itemCount: asyncSnapshot.data!.docs.length,
            itemBuilder: (context, index) {
              dynamic item = data.docs[index];
              return PostCard(item: item,);
            },
          );
          }
        }
      ),
    );
  }
}
