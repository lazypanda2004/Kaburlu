import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_smart_reply/google_mlkit_smart_reply.dart';
import 'package:kaburlu/components/textfield/custom_textfield.dart';

class Chatroom extends StatefulWidget {
  const Chatroom(
      {super.key,
      required this.chatId,
      required this.recipientId,
      required this.recipientName});
  final String chatId;
  final String recipientId;
  final String recipientName;
  @override
  State<Chatroom> createState() => _ChatroomState();
}

class _ChatroomState extends State<Chatroom> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();
  final SmartReply _smartReply = SmartReply();
  User? _currentUser;
  String? _editingMessageId;
  List<String> _smartReplies = [];
  String lastSeen = '';

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    _updateLastSeen();
    _getLastSeen();
  }

  Future<void> _updateLastSeen() async {
    await _firestore.collection('users').doc(_currentUser!.uid).update({
      'lastSeen': DateTime.now().toIso8601String(),
    });
  }

  @override
  void dispose() {
    _smartReply.close();
    super.dispose();
  }

  void _generateSmartReplies() async {
    final response = await _smartReply.suggestReplies();
    setState(
      () {
        for (var suggest in response.suggestions) {
          _smartReplies.add(suggest);
        }
      },
    );
  }

  void _showSmartReplies() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        if (_smartReplies.isNotEmpty) {
          return Container(
            color: Colors.black,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _smartReplies.map((reply) {
                return ListTile(
                  title:
                      Text(reply, style: const TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    _messageController.text = reply;
                  },
                );
              }).toList(),
            ),
          );
        } else {
          return Container(
            color: Colors.black,
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Text("No Smart replies are available",
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) {
      return;
    }
    String message = _messageController.text.trim();
    if (_editingMessageId != null) {
      // Update the existing message
      await _firestore
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .doc(_editingMessageId)
          .update({
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });
      setState(() {
        _editingMessageId = null;
      });
      await _firestore.collection('chats').doc(widget.chatId).set({
        'user1': _currentUser!.uid,
        'user2': widget.recipientId,
        'lastMessage': message,
        'lastMessageTimestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } else {
      // Add a new message
      await _firestore
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .add({
        'senderUID': _currentUser!.uid,
        'receiverUID': widget.recipientId,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
        'deletedFor': [],
      });

      await _firestore.collection('chats').doc(widget.chatId).set({
        'user1': _currentUser!.uid,
        'user2': widget.recipientId,
        'lastMessage': message,
        'lastMessageTimestamp': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    _messageController.clear();
  }

  void _updateReadStatus(DocumentSnapshot document) async {
    if (document['senderUID'] != _currentUser!.uid && !document['read']) {
      await _firestore
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .doc(document.id)
          .update({'read': true});
    }
  }

  Future<void> _deleteMessageForMe(String messageId) async {
    DocumentReference messageRef = _firestore
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .doc(messageId);
    DocumentSnapshot messageSnapshot = await messageRef.get();
    List<dynamic> deletedFor = messageSnapshot['deletedFor'] ?? [];
    if (!deletedFor.contains(_currentUser!.uid)) {
      deletedFor.add(_currentUser!.uid);
      await messageRef.update({'deletedFor': deletedFor});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Message deleted for you')));
      }
    }
  }

  Future<void> _deleteMessageForEveryone(String messageId) async {
    DocumentReference messageRef = _firestore
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .doc(messageId);
    DocumentSnapshot messageSnapshot = await messageRef.get();
    List<dynamic> deletedFor = messageSnapshot['deletedFor'] ?? [];
    if (!deletedFor.contains(_currentUser!.uid)) {
      deletedFor.add(_currentUser!.uid);
    }
    if (!deletedFor.contains(widget.recipientId)) {
      deletedFor.add(widget.recipientId);
    }
    await messageRef.update({'deletedFor': deletedFor});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Message deleted for everyone')));
    }
  }

  void _startEditingMessage(String messageId, String message) {
    setState(() {
      _editingMessageId = messageId;
      _messageController.text = message;
    });
  }

  Widget _buildMessageItem(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    bool isSentByCurrentUser = data['senderUID'] == _currentUser!.uid;
    bool isDeletedForCurrentUser =
        (data['deletedFor'] as List<dynamic>).contains(_currentUser!.uid);

    if (isDeletedForCurrentUser) {
      return Container(); // Don't display this message
    }

    return GestureDetector(
      onLongPress: () =>
          _showMessageOptions(context, document.id, data['message']),
      child: Align(
        alignment:
            isSentByCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
          padding: const EdgeInsets.all(10.0),
          decoration: BoxDecoration(
            color: isSentByCurrentUser ? Colors.black : Colors.grey[300],
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(
            data['message'],
            style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 16.0,
                color: isSentByCurrentUser ? Colors.white : Colors.black),
          ),
        ),
      ),
    );
  }

  void _showMessageOptions(
      BuildContext context, String messageId, String message) async {
    DocumentReference messageRef = _firestore
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .doc(messageId);
    DocumentSnapshot messageSnapshot = await messageRef.get();
    String sentUser = messageSnapshot['senderUID'];

    bool isCurrentUser = sentUser == _currentUser!.uid ? true : false;
    if (mounted) {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return Wrap(
            children: [
              if (isCurrentUser)
                ListTile(
                  title: Text(messageSnapshot['read'] ? 'Read' : 'Not Read'),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              if (isCurrentUser)
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Edit'),
                  onTap: () {
                    Navigator.pop(context);
                    _startEditingMessage(messageId, message);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.delete),
                title: const Text('Delete For Me'),
                onTap: () {
                  Navigator.pop(context);
                  _deleteMessageForMe(messageId);
                },
              ),
              if (isCurrentUser)
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Delete For Everyone'),
                  onTap: () {
                    Navigator.pop(context);
                    _deleteMessageForEveryone(messageId);
                  },
                ),
            ],
          );
        },
      );
    }
  }

  Future<void> _getLastSeen() async {
    DocumentSnapshot snapshot =
        await _firestore.collection('users').doc(widget.recipientId).get();
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    lastSeen = data['lastSeen'] ?? '';
  }

  String? imageurl() {
    return _firestore
        .collection('users')
        .doc(widget.recipientId)
        .get()
        .then((value) => value.data()!['image_url'])
        .toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: FutureBuilder<DocumentSnapshot>(
          future: _firestore.collection('users').doc(widget.recipientId).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CupertinoActivityIndicator();
            }
            if (snapshot.hasError) {
              return const Text('Error');
            }
            if (!snapshot.hasData) {
              return const Text('Error');
            }
            _updateLastSeen();
            final mapData = snapshot.data!.data() as Map<String, dynamic>;
            bool imageExists = mapData['image_url'] != null;
            if (imageExists) {
              return Row(
                children: [
                  CircleAvatar(
                    foregroundImage:
                        NetworkImage(mapData['image_url'] as String),
                    radius: 20,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    widget.recipientName,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              );
            } else {
              return Row(
                children: [
                  const CircleAvatar(
                    foregroundImage: AssetImage('lib/assets/profileimage.jpg'),
                    radius: 20,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    widget.recipientName,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              );
            }
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .doc(widget.chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CupertinoActivityIndicator());
                }
                if (!snapshot.hasData) {
                  return const Text("No messages yet");
                }
                final messages = snapshot.data!.docs;
                // for (var message in messages) {
                //   final messageText = message['message'];
                //   final messageSenderId = message['senderUID'];

                //   final Timestamp? timestamp = message['timestamp'];
                //   if (messageSenderId == _currentUser!.uid &&
                //       timestamp != null) {
                //     _smartReply.addMessageToConversationFromLocalUser(
                //         messageText, timestamp.millisecondsSinceEpoch);
                //   } else {
                //     if (timestamp != null) {
                //       _smartReply.addMessageToConversationFromRemoteUser(
                //           messageText,
                //           timestamp.microsecondsSinceEpoch,
                //           messageSenderId);
                //     }
                //   }
                // }
                // _generateSmartReplies();
                return ListView.builder(
                  reverse: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    _updateReadStatus(snapshot.data!.docs[index]);
                    return _buildMessageItem(snapshot.data!.docs[index]);
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: cust_textfield(
                    controller: _messageController,
                    hint_text: "Enter Message...",
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.reply),
                  onPressed: _showSmartReplies,
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
