import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kaburlu/widgets/dataWidgets/image_change.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key, required this.id});
  final String id;
  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _form = GlobalKey<FormState>();
  File? _selectedImage;
  String username = '';
  void _submit() async {
    final isValid = _form.currentState!.validate();

    if (!isValid) {
      return;
    }
    if (_selectedImage == null) {
      _form.currentState!.save();

      try {} on FirebaseAuthException catch (error) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message ?? 'Changes failed.'),
          ),
        );
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Saved Changes')));
      Navigator.pop(context);
    } else {
      _form.currentState!.save();

      try {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${widget.id}.jpg');

        await storageRef.putFile(_selectedImage!);
        final imageUrl = await storageRef.getDownloadURL();
        FirebaseFirestore.instance
            .collection('users')
            .doc(widget.id)
            .update({'image_url': imageUrl});
      } on FirebaseAuthException catch (error) {
        if (error.code == 'email-already-in-use') {
          // ...
        }
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message ?? 'Changes failed.'),
          ),
        );
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Saved Changes')));
      Navigator.pop(context);
    }
  }

  var isobscure = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.chevron_left_outlined),
        ),
        title: Text(
          'Edit profile',
          style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 15,
                      ),
                      ImageChange(
                        onPickImage: (pickedImage) {
                          _selectedImage = pickedImage;
                        },
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            10, 15, 10, 10),
                        child: Form(
                          key: _form,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              StreamBuilder(
                                stream: FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(widget.id)
                                    .snapshots(),
                                builder: (BuildContext context,
                                    AsyncSnapshot<DocumentSnapshot> snapshot) {
                                  if (!snapshot.hasData) {
                                    return const Center(
                                      child: Text('No image is uploaded'),
                                    );
                                  } else {
                                    username = snapshot.data!.get('username');
                                    return TextFormField(
                                      style: const TextStyle(
                                        color: Colors.black,
                                      ),
                                      autocorrect: false,
                                      keyboardType: TextInputType.emailAddress,
                                      textCapitalization:
                                          TextCapitalization.none,
                                      decoration: InputDecoration(
                                        labelStyle: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface,
                                            ),
                                        hintText: "Username: $username",
                                        hintStyle: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onSurface),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                            width: 1,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'Please enter a valid username.';
                                        }
                                        return null;
                                      },
                                      onSaved: (value) {
                                        if (username != value) {
                                          showDialog(
                                            context: context,
                                            builder: (context) =>
                                                const CupertinoActivityIndicator(),
                                          );
                                          FirebaseFirestore.instance
                                              .collection('users')
                                              .doc(widget.id)
                                              .update({'username': value});
                                        }
                                        Navigator.pop(context);
                                      },
                                    );
                                  }
                                },
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      alignment: Alignment.center,
                                      child: SizedBox(
                                        width: 200,
                                        height: 50,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            _submit();
                                          },
                                          style: ButtonStyle(
                                            backgroundColor:
                                                WidgetStateProperty.all(
                                                    Colors.grey.shade300),
                                          ),
                                          child: Text(
                                            'Save changes',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium!
                                                .copyWith(
                                                  color: Colors.black,
                                                  fontFamily: 'Lexend',
                                                  fontWeight: FontWeight.w600,
                                                ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
