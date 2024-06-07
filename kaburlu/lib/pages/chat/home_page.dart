import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kaburlu/components/buttons/cust_icon.dart';
import 'package:kaburlu/components/textfield/custom_textfield.dart';
import 'package:kaburlu/pages/chat/ViewProfile.dart';
import 'package:kaburlu/pages/chat/chatroom.dart';
import 'package:kaburlu/pages/profile/profile.dart';
import 'package:lottie/lottie.dart';

class HomePage extends StatefulWidget {
  static String id = 'home_page';
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _emailController = TextEditingController();
  User? _currentUser;

  void setupPushNotifications() async{
      final fcm = FirebaseMessaging.instance;
      await fcm.requestPermission();
      final token = await fcm.getToken();
       // can store this token in the database
      print('Token: $token');
  }

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    _updateLastSeen();
    setupPushNotifications(); // we don't want to turn init to async so define another function which is async and use it here.

  }

  void signout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _updateLastSeen() async {
    await _firestore.collection('users').doc(_currentUser!.uid).update({
      'lastSeen': DateTime.now().toIso8601String(),
    });
  }

  Future<void> _addFriend() async {
    String email = _emailController.text.trim();
    if (email.isEmpty) {
      return;
    }
    try {
      QuerySnapshot userSnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      if (userSnapshot.docs.isNotEmpty) {
        String friendId = userSnapshot
            .docs[0].id; // .docs give all the doc list,first user found
        await _firestore
            .collection('users')
            .doc(_currentUser!.uid)
            .collection('friends')
            .doc(friendId)
            .set({
          'friendId': friendId,
          'addedAt': FieldValue.serverTimestamp(),
        });
        await _firestore
            .collection('users')
            .doc(friendId)
            .collection('friends')
            .doc(_currentUser!.uid)
            .set({
          // if not exit then create a new doc
          'friendId': _currentUser!.uid,
          'addedAt': FieldValue.serverTimestamp(),
        });
        _emailController.clear(); // dispose the email controller
      } else {
        // Handle user not found
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('User not found')));
        }
      }
    } catch (e) {
      // Handle error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString(),
            ),
          ),
        );
      }
    }
  }

  String _getChatId(String userId1, String userId2) {
    return userId1.compareTo(userId2) < 0
        ? '${userId1}_$userId2'
        : '${userId2}_$userId1';
  }

  void _navigateToChatScreen(String friendId, String friendName) {
    String chatId = _getChatId(_currentUser!.uid, friendId);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Chatroom(
          chatId: chatId,
          recipientId: friendId,
          recipientName: friendName,
        ),
      ),
    );
  }

  void _navigatetoview(String friendId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Viewprofile(userId: friendId),
      ),
    );
  }

  Widget _buildFriendItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    String friendId = data['friendId'];

    return FutureBuilder<DocumentSnapshot>(
      future: _firestore
          .collection('users')
          .doc(friendId)
          .get(), // get the user data
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(30),
            child: Align(
              alignment: Alignment.centerLeft,
              child: CupertinoActivityIndicator(),
            ),
          );
        }
        if (!snapshot.hasData) {
          return const ListTile(title: Text('Data not found'));
        }

        Map<String, dynamic> friendData = snapshot.data!.data()
            as Map<String, dynamic>; // get the user data as json
        String friendName = friendData['username'];
        friendName = friendName.toUpperCase();
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(friendData['image_url']),
              radius: 30,
            ),
            title: Text(friendName,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    )),
            onTap: () => _navigateToChatScreen(friendId, friendName),
            onLongPress: () => _navigatetoview(friendId),
          ),
        );
      },
    );
  }

  void _addfunction() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 10, 20),
                child: Row(
                  children: [
                    Expanded(
                      child: cust_textfield(
                        hint_text: 'Enter friend\'s email to be added',
                        obscure_text: false,
                        controller: _emailController,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: _addFriend,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Lottie.asset('lib/assets/addFriends.json'),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 10, 0),
          child: Text(
            'Kaburlu',
            style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                  color: Colors.white,
                  fontFamily: 'Lexend',
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.italic,
                ),
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        const Profile_Screen()), // Ensure you have a ProfileScreen
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 5,
          vertical: 20,
        ),
        child: Center(
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _firestore
                      .collection('users')
                      .doc(_currentUser!.uid)
                      .collection('friends')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No friends added yet'));
                    }
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        return _buildFriendItem(snapshot.data!.docs[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 10, 10),
        child: CustIcon(
          ontap: _addfunction,
          icon: Icons.add,
          width: 60,
          height: 60,
        ),
      ),
    );
  }
}
