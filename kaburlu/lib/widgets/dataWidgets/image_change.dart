import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageChange extends StatefulWidget {
  const ImageChange({super.key, required this.onPickImage});
  final void Function(File pickedimage) onPickImage;
  @override
  State<ImageChange> createState() => _ImageChangeState();
}

class _ImageChangeState extends State<ImageChange> {
  File? _pickedImageFile;
  User user = FirebaseAuth.instance.currentUser!;
  String id = FirebaseAuth.instance.currentUser!.uid;
  void _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
      maxWidth: 150,
    );

    if (pickedImage == null) {
      return;
    }
    setState(() {
      _pickedImageFile = File(pickedImage.path);
    });

    widget.onPickImage(_pickedImageFile!);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream:
          FirebaseFirestore.instance.collection('users').doc(id).snapshots(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircleAvatar(
            foregroundImage: const AssetImage('lib/assets/profileimage.jpg'),
            backgroundColor: Theme.of(context).colorScheme.onSurface,
            radius: 60,
          );
        }
        if (!snapshot.hasData) {
          return CircleAvatar(
            foregroundImage: const AssetImage('lib/assets/profileimage.jpg'),
            backgroundColor: Theme.of(context).colorScheme.onSurface,
            radius: 60,
          );
        } else {
          String url = snapshot.data!.get('image_url');

          return Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                  foregroundImage: _pickedImageFile != null
                      ? FileImage(_pickedImageFile!)
                      : Image.network(url).image,
                ),
              ),
              TextButton.icon(
                style: ButtonStyle(
                  foregroundColor: WidgetStateProperty.all(Colors.black),
                ),
                onPressed: _pickImage,
                icon: const Icon(Icons.image),
                label: const Text(
                  'Change Image',
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
              )
            ],
          );
        }
      },
    );
  }
}
