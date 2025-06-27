import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/colors/app_color.dart';
import 'package:social_media_app/pages/profile.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchCon = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Find Users')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            SearchBar(
              // leading: Icon(Icons.search),
              controller: searchCon,
              onChanged: (value) {
                setState(() {
                  searchCon.text = value;
                });
              },
              trailing: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.search, color: kPrimaryColor),
                ),
              ],
              hintText: 'Search by username',
              backgroundColor: MaterialStateColor.resolveWith(
                (states) => Colors.white,
              ),
              elevation: MaterialStateProperty.resolveWith((states) => 0),
              shape: MaterialStateProperty.resolveWith(
                (states) => RoundedRectangleBorder(
                  side: BorderSide(color: kPrimaryColor),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .where('username', isEqualTo: searchCon.text)
                    .get(),
                builder: (context, asyncSnapshot) {
                  if (asyncSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (asyncSnapshot.hasError) {
                    return Center(child: Text('Error'));
                  } else if (asyncSnapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No users found'));
                  } else {
                  return ListView.builder(
                    itemCount: searchCon.text.isEmpty ? 0 : asyncSnapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      dynamic item = asyncSnapshot.data!.docs[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage(uid: item['uid']),));
                        },
                        child: ListTile(
                          leading: item ['profilePic'] == "" ? CircleAvatar(
                            backgroundImage: AssetImage('assets/images/man.png'),
                          ) : CircleAvatar(
                            backgroundImage: NetworkImage(item['profilePic']),
                          ),
                          title: Text(item['displayName']),
                          subtitle: Text('@' + item['username']),
                        ),
                      );
                    },
                  );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
