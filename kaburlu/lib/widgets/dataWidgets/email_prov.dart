import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EmailProv extends StatelessWidget {
  const EmailProv({super.key,required this.documentid,required this.color});
  final String documentid;
  final Color color;
  @override
  Widget build(BuildContext context) {
   CollectionReference users = FirebaseFirestore.instance.collection('users');
    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(documentid).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;

          return Text(
            '${data['email']}',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: color,
                  fontSize: 22,
                ),
          );
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        return const Text('Error');
      },
    );
  }
}