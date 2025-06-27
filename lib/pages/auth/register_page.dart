import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:social_media_app/pages/auth/login_page.dart';

import '../../colors/app_color.dart';
import '../../layout.dart';
import '../../services/auth.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  TextEditingController displayCon = TextEditingController();
  TextEditingController usernameCon = TextEditingController();
  TextEditingController emailCon = TextEditingController();
  TextEditingController passwordCon = TextEditingController();

  register() async {
    try {
      String res = await AuthMethods().signUp(
        email: emailCon.text,
        password: passwordCon.text,
        username: usernameCon.text,
        displayName: displayCon.text,
      );
      if(res == 'success') {
        setState(() {
          displayCon.text = '';
          usernameCon.text = '';
          emailCon.text = '';
          passwordCon.text = '';
        });
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LayoutPage()), (_) => false);
        print('success');
      } else {
        print(res);
      }
    } on Exception catch (e) {
      print(e);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // logo
                Center(
                  child: SvgPicture.asset('assets/svg/n_logo.svg' ,
                    height: 150,
                    width: 150,
                    colorFilter: ColorFilter.mode(kPrimaryColor, BlendMode.srcIn),),
                ),
                Gap(10),
                // appName
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('06' , style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                    Text('16' , style: TextStyle(fontSize: 26,color: kPrimaryColor , fontWeight: FontWeight.bold),),
                  ],
                ),
                Gap(20),
                Text('Welcome back' , style: TextStyle(fontSize: 18,),),
                Gap(20),
                // display name
                TextField(
                  controller: displayCon,
                  decoration: InputDecoration(
                    fillColor: kWhiteColor,
                    filled: true,
                    prefixIcon: Icon(Icons.person),
                    hintText: 'Display Name',
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
                // username
                TextField(
                  controller: usernameCon,
                  decoration: InputDecoration(
                    fillColor: kWhiteColor,
                    filled: true,
                    prefixIcon: Icon(Icons.person),
                    hintText: 'Username',
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
                // email textfield
                TextField(
                  controller: emailCon,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    fillColor: kWhiteColor,
                    filled: true,
                    prefixIcon: Icon(Icons.email),
                    hintText: 'Email',
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
                // password textfield
                TextField(
                  controller: passwordCon,
                  obscureText: true,
                  decoration: InputDecoration(
                    fillColor: kWhiteColor,
                    filled: true,
                    prefixIcon: Icon(Icons.password),
                    hintText: 'Password',
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
                // login button
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
                          onPressed: (){
                            register();
                          },
                          child: Text('Register'.toUpperCase() , style: TextStyle(color: kWhiteColor),)),
                    ),
                  ],
                ),
                Gap(20),
                // have account?
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Already have an account? '),
                    GestureDetector(
                        onTap: (){
                          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => LoginPage()), (route) => false);
                        },
                        child: Text('Login Now' , style: TextStyle(color: kPrimaryColor),))
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
