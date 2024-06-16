import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kaburlu/components/videoPlayer.dart';
import 'package:video_player/video_player.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:google_mlkit_smart_reply/google_mlkit_smart_reply.dart';
import 'package:intl/intl.dart';
import 'package:kaburlu/components/textfield/custom_textfield.dart';

class GroupChatroom extends StatefulWidget {
  final String groupId;
  final String groupName;

  const GroupChatroom({required this.groupId, required this.groupName});

  @override
  _GroupChatroomState createState() => _GroupChatroomState();
}

class _GroupChatroomState extends State<GroupChatroom> {
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
    setState(() {
      _smartReplies = response.suggestions;
    });
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
                  title: Text(reply, style: const TextStyle(color: Colors.white)),
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

  Future<void> _sendMessage({String? imageUrl, String? videoUrl}) async {
    if (_messageController.text.trim().isEmpty && imageUrl == null && videoUrl == null) {
      return;
    }
    String message = _messageController.text.trim();
    Map<String, dynamic> messageData = {
      'senderUID': _currentUser!.uid,
      'timestamp': FieldValue.serverTimestamp(),
      'readBy': [],
    };

    if (imageUrl != null) {
      messageData['imageUrl'] = imageUrl;
    } else if (videoUrl != null) {
      messageData['videoUrl'] = videoUrl;
    } else {
      messageData['message'] = message;
    }

    if (_editingMessageId != null) {
      // Update the existing message
      await _firestore
          .collection('groups')
          .doc(widget.groupId)
          .collection('messages')
          .doc(_editingMessageId)
          .update(messageData);
      setState(() {
        _editingMessageId = null;
      });
    } else {
      // Add a new message
      await _firestore
          .collection('groups')
          .doc(widget.groupId)
          .collection('messages')
          .add(messageData);
    }

    await _firestore.collection('groups').doc(widget.groupId).update({
      'lastMessage': message.isNotEmpty ? message : (imageUrl != null ? 'Image' : 'Video'),
      'lastMessageTimestamp': FieldValue.serverTimestamp(),
    });

    _messageController.clear();
  }

  Future<void> _uploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final ref = FirebaseStorage.instance
          .ref()
          .child('groups/${widget.groupId}/images/${DateTime.now().millisecondsSinceEpoch}');
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      _sendMessage(imageUrl: downloadUrl);
    }
  }

  Future<void> _uploadVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final ref = FirebaseStorage.instance
          .ref()
          .child('groups/${widget.groupId}/videos/${DateTime.now().millisecondsSinceEpoch}');
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();
      _sendMessage(videoUrl: downloadUrl);
    }
  }

  void _updateReadStatus(DocumentSnapshot document) async {
    if (document['senderUID'] != _currentUser!.uid && !(document['readBy'] as List).contains(_currentUser!.uid)) {
      await _firestore
          .collection('groups')
          .doc(widget.groupId)
          .collection('messages')
          .doc(document.id)
          .update({
        'readBy': FieldValue.arrayUnion([_currentUser!.uid]),
      });
    }
  }

  void _getLastSeen() async {
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(_currentUser!.uid).get();
    setState(() {
      lastSeen = userDoc['lastSeen'];
    });
  }
  void showMediaOptions(BuildContext context, String messageId) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            
            ListTile(
              title: const Text('Cancel'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot document) {
    bool isOwnMessage = document['senderUID'] == _currentUser!.uid;
    bool isRead = (document['readBy'] as List).contains(_currentUser!.uid);
    String formattedTime = DateFormat('HH:mm').format(document['timestamp'].toDate());
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    _updateReadStatus(document);

    return ListTile(
      title: Align(
        alignment: isOwnMessage ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isOwnMessage ? Colors.blue : Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: isOwnMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              if (data.containsKey('message'))
                Text(
                  document['message'],
                  style: TextStyle(color: isOwnMessage ? Colors.white : Colors.black),
                ),
              if (data.containsKey('imageUrl'))
                Image.network(document['imageUrl']),
              if (data.containsKey('videoUrl'))
                VideoWidget(
        videoUrl: data['videoUrl'],
        showMediaOptions: showMediaOptions,
        id: document.id,
      ),
              SizedBox(height: 5),
              Text(
                formattedTime,
                style: TextStyle(
                  fontSize: 12,
                  color: isOwnMessage ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
      trailing: isOwnMessage
          ? IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _editingMessageId = document.id;
                  _messageController.text = document['message'];
                });
              },
            )
          : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () => _getLastSeen(),
          ),
          IconButton(
            icon: Icon(Icons.chat_bubble),
            onPressed: _showSmartReplies,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('groups')
                  .doc(widget.groupId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                var documents = snapshot.data!.docs;
                return ListView.builder(
                  reverse: true,
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    return _buildMessageItem(documents[index]);
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.image),
                  onPressed: _uploadImage,
                ),
                IconButton(
                  icon: Icon(Icons.video_library),
                  onPressed: _uploadVideo,
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () => _sendMessage(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
