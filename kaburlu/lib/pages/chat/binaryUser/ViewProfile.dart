import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class Viewprofile extends StatefulWidget {
  const Viewprofile({super.key, required this.userId});
  final String userId;
  @override
  State<Viewprofile> createState() => _ViewprofileState();
}

class _ViewprofileState extends State<Viewprofile> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _lastController = TextEditingController();
  final TextEditingController _createdController = TextEditingController();
  String? email;
  DateTime? last_seen;
  late DateTime created_at;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  Future<void> _getUserData() async {
    DocumentSnapshot userData =
        await _firestore.collection('users').doc(widget.userId).get();
    Map<String, dynamic> userDataMap = userData.data() as Map<String, dynamic>;
    _displayNameController.text = userDataMap['username'];
    _statusController.text = userDataMap['status'];
    email = userDataMap['email'];
    _emailController.text = userDataMap['email'];
    ;
  }

  String truncateString(String input) {
    if (input.length <= 10) {
      return input;
    } else {
      return input.substring(0, 10);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Profile', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: StreamBuilder<DocumentSnapshot>(
            stream:
                _firestore.collection('users').doc(widget.userId).snapshots(),
            builder: (context, snapshot) {
              final mapData = snapshot.data!;
              _lastController.text = snapshot.data!['lastSeen'];
              _createdController.text = snapshot.data!['createdAt'];
              _lastController.text =
                  '${_lastController.text.substring(0, 10)} ${_lastController.text.substring(11, 16)}';
              _createdController.text =
                  _createdController.text.substring(0, 10);
              bool imageExists = mapData['image_url'] != null;
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData) {
                return const Text('No data found');
              }
              if (imageExists) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        CircleAvatar(
                          foregroundImage: NetworkImage(mapData['image_url']),
                          radius: 60,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _displayNameController,
                      decoration:
                          const InputDecoration(labelText: 'Display Name'),
                      readOnly: true,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _statusController,
                      decoration: const InputDecoration(labelText: 'Status'),
                      readOnly: true,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                        readOnly: true),
                    const SizedBox(height: 20),
                    TextField(
                        controller: _lastController,
                        decoration:
                            const InputDecoration(labelText: 'Last seen'),
                        readOnly: true),
                    const SizedBox(height: 20),
                    TextField(
                        controller: _createdController,
                        decoration: const InputDecoration(labelText: 'Joined'),
                        readOnly: true),
                    const SizedBox(height: 20),
                  ],
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      foregroundImage:
                          AssetImage('lib/assets/profileimage.jpg'),
                      radius: 60,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: _displayNameController,
                      decoration:
                          const InputDecoration(labelText: 'Display Name'),
                      readOnly: true,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _statusController,
                      decoration: const InputDecoration(labelText: 'Status'),
                      readOnly: true,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                        readOnly: true),
                    const SizedBox(height: 20),
                    TextField(
                        controller: _lastController,
                        decoration:
                            const InputDecoration(labelText: 'Last seen'),
                        readOnly: true),
                    const SizedBox(height: 20),
                    TextField(
                        controller: _createdController,
                        decoration: const InputDecoration(labelText: 'Joined'),
                        readOnly: true),
                    const SizedBox(height: 20),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
