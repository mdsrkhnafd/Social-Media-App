import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/pages/add.dart';
import 'package:social_media_app/pages/auth/login_page.dart';
import 'package:social_media_app/pages/home.dart';
import 'package:social_media_app/pages/profile.dart';
import 'package:social_media_app/pages/search.dart';
import 'package:social_media_app/providers/user_provider.dart';
import 'package:social_media_app/services/auth.dart';

import 'colors/app_color.dart';

class LayoutPage extends StatefulWidget {
  const LayoutPage({super.key});

  @override
  State<LayoutPage> createState() => _LayoutPageState();
}

class _LayoutPageState extends State<LayoutPage> with WidgetsBindingObserver {
  int currentIndex = 0;
  PageController pageCon = PageController();
  @override
  void initState() {
    Provider.of<UserProvider>(context, listen: false).getDetails();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    pageCon.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Provider.of<UserProvider>(context).isLoading ? Scaffold(body: Center(child: CircularProgressIndicator())) : Scaffold(
      resizeToAvoidBottomInset: false,
      extendBody: true,
      body: PageView(
        controller: pageCon,
        children: [HomePage(), AddPage(), SearchPage(), ProfilePage(uid: FirebaseAuth.instance.currentUser!.uid,)],
        onPageChanged: (value) => setState(() {
          currentIndex = value;
        }),
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (value) => setState(() {
          currentIndex = value;
          pageCon.jumpToPage(value);
        }),
        elevation: 0,
        backgroundColor: kWhiteColor.withOpacity(0.8),
        selectedIndex: currentIndex,
        indicatorColor: kPrimaryColor.withOpacity(0.2),
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: "Home",
            selectedIcon: Icon(Icons.home, color: kPrimaryColor),
          ),
          NavigationDestination(
            icon: Icon(Icons.add),
            label: "add",
            selectedIcon: Icon(Icons.add, color: kPrimaryColor),
          ),
          NavigationDestination(
            icon: Icon(Icons.search),
            label: "Search",
            selectedIcon: Icon(Icons.search, color: kPrimaryColor),
          ),
          NavigationDestination(
            icon: Icon(Icons.person),
            label: "Profile",
            selectedIcon: Icon(Icons.person, color: kPrimaryColor),
          ),
        ],
      ),
    );
  }
}
