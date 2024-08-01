import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() {
    return _NewMessageState();
  }
}

class _NewMessageState extends State<NewMessage> {
  final _messageController = TextEditingController();
  void _submitMessage() async
  {
    final enteredMessage = _messageController.text;

    if(enteredMessage.trim().isEmpty)
    {
      return;
    }
    FocusScope.of(context).unfocus();
    _messageController.clear();
    final user = FirebaseAuth.instance.currentUser!;
    final userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    await FirebaseFirestore.instance
        .collection('user_data')
        .doc(user.uid)
        .set({
      'username': userData.data()!['username'],
      'email': userData.data()!['email'],
    });

    // Add a new document to the images subcollection
    await FirebaseFirestore.instance
        .collection('user_data')
        .doc(user.uid)
        .collection('chat')
        .add({
          'message': enteredMessage,
        'createdAt': Timestamp.now(),
        'reply': '',
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15, right: 1, bottom: 14),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              enableSuggestions: true,
              decoration: const InputDecoration(labelText: 'Send a message...'),
              textCapitalization: TextCapitalization.sentences,
              controller: _messageController,
              autocorrect: true,
            ),
          ),
          IconButton(
            color: Theme.of(context).colorScheme.primary,
            onPressed: _submitMessage,
            icon: const Icon(Icons.send),
          )
        ],
      ),
    );
  }
}
