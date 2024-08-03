import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kaburlu/pages/Auth/LoginorRegisterpage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kaburlu/pages/chat/home_page.dart';
import 'package:kaburlu/pages/Auth/registerorlogin.dart';
import 'package:kaburlu/pages/Auth/spalsh_screen.dart';
import 'package:kaburlu/pages/Auth/welcome.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: 'kaburlu',
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kaburlu',
      routes: {
        WelcomeScreen.id: (context) => const WelcomeScreen(),
        LoginorRegister.id: (context) => const LoginorRegister(),
        Registerorlogin.id: (context) => const Registerorlogin(),
        HomePage.id: (context) => const HomePage(),
      },
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: splashscreen(),
            );
          }
          else if (snapshot.hasData) {
            return HomePage();
          }
          return const WelcomeScreen();
        },
      ),
    );
  }
}
