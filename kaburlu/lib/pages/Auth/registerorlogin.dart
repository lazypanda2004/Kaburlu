import 'package:flutter/material.dart';
import 'package:kaburlu/pages/Auth/RegisterPage.dart';
import 'package:kaburlu/pages/Auth/login_page.dart';

class Registerorlogin extends StatefulWidget {
  static String id = 'registerorlogin';
  const Registerorlogin({super.key});

  @override
  State<Registerorlogin> createState() => _RegisterorLoginState();
}

class _RegisterorLoginState extends State<Registerorlogin> {
  bool showlogin = true;
  void toggle() {
    setState(() {
      showlogin = !showlogin;
    });
  }
  @override
  Widget build(BuildContext context) {
    if(!showlogin){
      return LoginPage(ontap: toggle);
    }
    else{
      return RegisterPage(ontap: toggle);
    }
  }
}