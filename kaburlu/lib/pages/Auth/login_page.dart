import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kaburlu/components/buttons/cust_button.dart';
import 'package:kaburlu/components/textfield/custom_textfield.dart';
import 'package:kaburlu/components/buttons/google%20_button.dart';
import 'package:kaburlu/components/tiles/sqaure_tile.dart';
import 'package:kaburlu/pages/home_page.dart';
import 'package:kaburlu/services/auth_service.dart';
import 'package:lottie/lottie.dart';

class LoginPage extends StatefulWidget {
  static String id = 'login_page';
  const LoginPage({super.key, required this.ontap});
  final Function() ontap;
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController email_controller = TextEditingController();

  final TextEditingController password_controller = TextEditingController();

  Future<void> text_login() async {
    showDialog(
      context: context,
      builder: (context) => const CupertinoActivityIndicator(),
    );
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email_controller.text,
        password: password_controller.text,
      );
      if (mounted) {
        Navigator.pop(context); // for the loading indicator
        Navigator.pushNamed(context, HomePage.id);
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        Navigator.pop(context); // for the loading indicator
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: Text(e.message!),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Ok'),
              )
            ],
          ),
        );
      }
    }
  }

  void google_login() {
    AuthService().signinwithgoogle();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(23, 10, 23, 0),
                  child: Row(
                    children: [
                      Image.asset(
                        'lib/assets/header_icon.png',
                        width: 75,
                        height: 80,
                        fit: BoxFit.fitWidth,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                        ),
                        child: Text(
                          'Kaburlu',
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge!
                              .copyWith(
                                color: Colors.black,
                                fontFamily: 'Lexend',
                                fontWeight: FontWeight.w700,
                                fontStyle: FontStyle.italic,
                              ),
                        ),
                      )
                    ],
                  ),
                ),
                Lottie.asset('lib/assets/header.json'),
                cust_textfield(
                    hint_text: 'Email',
                    controller: email_controller,
                    obscure_text: false),
                const SizedBox(
                  height: 10,
                ),
                cust_textfield(
                    hint_text: 'Password',
                    controller: password_controller,
                    obscure_text: true),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      cust_button(ontap: text_login, text: 'Login', width: 80),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                // google sign- in
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    google_button(
                        ontap: google_login, text: "Login with ", width: 170),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Center(
                    child: cust_button(
                        ontap: widget.ontap,
                        text: 'Not a member? Register now',
                        width: 250),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
