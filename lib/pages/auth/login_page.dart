import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:social_media_app/pages/auth/register_page.dart';
import '../../colors/app_color.dart';
import '../../layout.dart';
import '../../services/auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailCon = TextEditingController();
  TextEditingController passwordCon = TextEditingController();

  login() async {
    try {
      String res = await AuthMethods().signIn(
        email: emailCon.text,
        password: passwordCon.text,
      );

      if (res == 'success') {
        print('login success');
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LayoutPage(),) , (route) => false);
      } else {
        print(res);
      }
    } catch (e) {
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
                  child: SvgPicture.asset(
                    'assets/svg/n_logo.svg',
                    height: 150,
                    width: 150,
                    colorFilter: ColorFilter.mode(kPrimaryColor, BlendMode.srcIn),
                  ),
                ),
                Gap(10),
                // appName
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '06',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '16',
                      style: TextStyle(
                        fontSize: 26,
                        color: kPrimaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Gap(20),
                Text('Welcome back', style: TextStyle(fontSize: 18)),
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
                        onPressed: () {
                          login();
                        },
                        child: Text(
                          'Login'.toUpperCase(),
                          style: TextStyle(color: kWhiteColor),
                        ),
                      ),
                    ),
                  ],
                ),
                Gap(20),
                // have account?
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Don\'t have an account? '),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => RegisterPage()),
                          (route) => false,
                        );
                      },
                      child: Text(
                        'Register Now',
                        style: TextStyle(color: kPrimaryColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
