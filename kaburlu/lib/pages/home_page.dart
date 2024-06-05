import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kaburlu/pages/welcome.dart';

class HomePage extends StatefulWidget {
  static String id = 'home_page';
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final User user = FirebaseAuth.instance.currentUser!;

  void signout() async {
    await FirebaseAuth.instance.signOut();
    if(mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    User user = FirebaseAuth.instance.currentUser!;
    String id = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kaburlu'),
        actions: [
          IconButton(
            onPressed: signout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          SizedBox(height: 20),
          Text('Welcome '),
        ],
      )),
    );
  }
}
