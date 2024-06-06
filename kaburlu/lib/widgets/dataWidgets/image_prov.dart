import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileImage extends StatefulWidget {
  ProfileImage({super.key, required this.id, required this.radius});
  final String id;
  final double radius;
  @override
  State<ProfileImage> createState() => _ProfileImageState();
}

class _ProfileImageState extends State<ProfileImage> {
  User user = FirebaseAuth.instance.currentUser!;
  String id = FirebaseAuth.instance.currentUser!.uid;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(widget.id)
          .snapshots(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircleAvatar(
            foregroundImage: const AssetImage('lib/assets/profileimage.jpg'),
            backgroundColor: Theme.of(context).colorScheme.onSurface,
            radius: widget.radius,
          );
        }
        if (!snapshot.hasData) {
          return CircleAvatar(
            foregroundImage: const AssetImage('lib/assets/profileimage.jpg'),
            backgroundColor: Theme.of(context).colorScheme.onSurface,
            radius: widget.radius,
          );
        } else {
          String url = snapshot.data!.get('image_url');
          return CircleAvatar(
            foregroundImage: Image.network(url).image,
            backgroundColor: Theme.of(context).colorScheme.onSurface,
            radius: widget.radius,
          );
        }
      },
    );
  }
}
