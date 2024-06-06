import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kaburlu/components/buttons/cust_button.dart';
import 'package:kaburlu/components/buttons/cust_icon.dart';
import 'package:kaburlu/components/textfield/custom_textfield.dart';
import 'package:kaburlu/pages/chat/ViewProfile.dart';
import 'package:kaburlu/pages/chat/chatroom.dart';
import 'package:kaburlu/pages/profile/profile.dart';

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

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
  }

  void signout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pop(context);
    }
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
        ? '${userId1}_${userId2}'
        : '${userId2}_${userId1}';
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
        if (!snapshot.hasData) {
          return const ListTile(title: Text('Data not found'));
        }

        Map<String, dynamic> friendData = snapshot.data!.data()
            as Map<String, dynamic>; // get the user data as json
        String friendName = friendData['username'];

        return ListTile(
          leading: CircleAvatar(
            backgroundImage: NetworkImage(friendData['image_url']),
            radius: 10,
          ),
          title: Text(friendName),
          onTap: () => _navigateToChatScreen(friendId, friendName),
          onLongPress: () => _navigatetoview(friendId),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 10, 0),
          child: Text(
            'Kaburlu',
            style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                  color: Colors.black,
                  fontFamily: 'Lexend',
                  fontWeight: FontWeight.w700,
                  fontStyle: FontStyle.italic,
                ),
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        Profile_Screen()), // Ensure you have a ProfileScreen
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 20, 10, 20),
              child: Row(
                children: [
                  Expanded(
                    // child: TextField(
                    //   controller: _emailController,
                    //   decoration: InputDecoration(
                    //     hintText: 'Enter friend\'s email',
                    //     border: OutlineInputBorder(
                    //       borderRadius: BorderRadius.circular(10.0),
                    //     ),
                    //   ),
                    // ),
                    child: cust_textfield(
                      hint_text: 'Enter friend\'s email',
                      obscure_text: false,
                      controller: _emailController,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: _addFriend,
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('users')
                    .doc(_currentUser!.uid)
                    .collection('friends')
                    .snapshots(),
                builder: (context, snapshot) {
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 10, 10),
        child: CustIcon(
          ontap: _addFriend,
          icon: Icons.add,
          width: 60,
          height: 60,
        ),
      ),
    );
  }
}
