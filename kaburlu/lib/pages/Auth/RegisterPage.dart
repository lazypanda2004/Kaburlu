import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:kaburlu/components/buttons/cust_button.dart';
import 'package:kaburlu/components/textfield/custom_textfield.dart';
import 'package:kaburlu/components/buttons/google%20_button.dart';
import 'package:kaburlu/pages/chat/binaryUser/home_page.dart';
import 'package:kaburlu/services/auth_service.dart';
import 'package:kaburlu/widgets/userimagepicker.dart';

class RegisterPage extends StatefulWidget {
  static String id = 'register_page';
  const RegisterPage({super.key, required this.ontap});
  final Function() ontap;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController username_controller = TextEditingController();
  final TextEditingController email_controller = TextEditingController();
  final TextEditingController password_controller = TextEditingController();
  final TextEditingController confirmpassword_controller =
      TextEditingController();
  final TextEditingController? status_controller = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  File? _selectedImage;
  void google_login() {
    AuthService().signinwithgoogle();
  }

  Future<void> text_register() async {
    showDialog(
      context: context,
      builder: (context) => const CupertinoActivityIndicator(),
    );
    try {
      if (password_controller.text == confirmpassword_controller.text) {
        final newuserCredentials = await _auth.createUserWithEmailAndPassword(
          email: email_controller.text,
          password: password_controller.text,
        );

        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${newuserCredentials.user!.uid}.jpg');

        await storageRef.putFile(_selectedImage!);
        final imageUrl = await storageRef.getDownloadURL();

        final createdAt = DateTime.now().toIso8601String();
        await _firestore
            .collection('users')
            .doc(newuserCredentials.user!.uid)
            .set({
          'username': username_controller.text,
          'email': email_controller.text,
          'status': status_controller?.text ?? 'Hey there! I am using Kaburlu',
          'image_url': imageUrl,
          'createdAt': createdAt,
          'lastSeen': createdAt,
        });
        if (mounted) {
          Navigator.pop(context);
          Navigator.pushNamed(
              context, HomePage.id); // for the loading indicator
        }
      } else {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: const Text('Passwords do not match'),
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
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        Navigator.pop(context);
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

  @override
  void dispose() {
    super.dispose();
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
                  padding: const EdgeInsets.fromLTRB(23, 35, 23, 0),
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
                const SizedBox(
                  height: 15,
                ),
                Center(
                  child: Userimagepicker(
                    onPickImage: (pickedImage) {
                      _selectedImage = pickedImage;
                    },
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                cust_textfield(
                    hint_text: 'Username',
                    controller: username_controller,
                    obscure_text: false),
                const SizedBox(
                  height: 10,
                ),
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
                    obscure_text: false),
                const SizedBox(
                  height: 10,
                ),
                cust_textfield(
                    hint_text: 'Confirm Password',
                    controller: confirmpassword_controller,
                    obscure_text: false),
                const SizedBox(
                  height: 10,
                ),
                cust_textfield(
                    hint_text: 'Status',
                    controller: status_controller,
                    obscure_text: false),
                const SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 35),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      cust_button(
                          ontap: text_register,
                          text: 'Register',
                          width: 100,
                          height: 50),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    google_button(
                        ontap: google_login,
                        text: "Register with ",
                        width: 185),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Center(
                    child: cust_button(
                        ontap: widget.ontap,
                        text: 'Member?     Login now',
                        width: 250),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
