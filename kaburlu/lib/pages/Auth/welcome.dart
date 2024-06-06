import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:kaburlu/components/buttons/cust_button.dart';
import 'package:kaburlu/pages/Auth/LoginorRegisterpage.dart';
import 'package:kaburlu/pages/Auth/RegisterPage.dart';
import 'package:kaburlu/pages/Auth/login_page.dart';
import 'package:kaburlu/pages/Auth/registerorlogin.dart';

class WelcomeScreen extends StatefulWidget {
  static String id = 'welcome_screen';

  const WelcomeScreen({super.key});
  @override
  WelcomeScreenState createState() => WelcomeScreenState();
}

class WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation animation;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    animation = ColorTween(begin: Colors.blueGrey, end: Colors.white)
        .animate(controller);
    controller.forward();

    controller.addListener(() {
      setState(() {});
    });
  }

  void logintap() {
    Navigator.pushNamed(context, LoginorRegister.id);
  }

  void registertap() {
    Navigator.pushNamed(context, Registerorlogin.id);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[300],
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: <Widget>[
                    SizedBox(
                      width: 15,
                    ),
                    FittedBox(
                      fit: BoxFit.fitWidth,
                      alignment: Alignment.center,
                      child: AnimatedTextKit(
                        animatedTexts: [
                          TypewriterAnimatedText(
                            'Kaburlu',
                            textStyle: Theme.of(context)
                                .textTheme
                                .headlineMedium!
                                .copyWith(
                                  fontSize: 40.0,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.black,
                                ),
                            speed: const Duration(milliseconds: 300),
                          ),
                        ],
                        totalRepeatCount: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 48.0,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.04),
                child: cust_button(
                    ontap: logintap,
                    text: "Login",
                    width: MediaQuery.of(context).size.width * 0.7),
              ),
              SizedBox(
                height: 25.0,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.04),
                child: cust_button(
                    ontap: registertap,
                    text: "Register",
                    width: MediaQuery.of(context).size.width * 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
