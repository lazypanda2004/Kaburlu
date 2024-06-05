import 'package:flutter/material.dart';
import 'package:kaburlu/pages/Auth/RegisterPage.dart';
import 'package:kaburlu/pages/Auth/login_page.dart';

class LoginorRegister extends StatefulWidget {
  static String id = 'loginorregister';
  const LoginorRegister({super.key});

  @override
  State<LoginorRegister> createState() => _LoginorRegisterState();
}

class _LoginorRegisterState extends State<LoginorRegister> {
  bool showlogin = true;
  void toggle() {
    setState(() {
      showlogin = !showlogin;
    });
  }
  @override
  Widget build(BuildContext context) {
    if(showlogin){
      return LoginPage(ontap: toggle);
    }
    else{
      return RegisterPage(ontap: toggle);
    }
  }
}