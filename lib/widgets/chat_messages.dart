import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:crop_desease_detection/screens/helper.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final screenWidth = MediaQuery.of(context).size.width;
    final googleSheetsHelper = GoogleSheetsHelper('1PMHGHpgZhec6-Q39N0JKVl3kyDSk_LFucsD2KIdIzX8');

    void _addToGoogleSheets(String userId, String contentType) async {
      await googleSheetsHelper.appendRow([
        userId,
        contentType,
      ]);
    }

    return Scaffold(
      backgroundColor: Colors.grey[200], // Set background color
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('user_data')
            .doc(user.uid)
            .collection('chat')
            .orderBy('createdAt', descending: false)
            .snapshots(),
        builder: (ctx, chatSnapshots) {
          if (chatSnapshots.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (!chatSnapshots.hasData || chatSnapshots.data!.docs.isEmpty) {
            return const Center(
              child: Text('No messages found yet.'),
            );
          }

          if (chatSnapshots.hasError) {
            return const Center(
              child: Text('Something went wrong ...'),
            );
          }

          final loadedMessages = chatSnapshots.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(10), // Add padding around the ListView
            itemCount: loadedMessages.length,
            itemBuilder: (ctx, index) {
              final messageData =
                  loadedMessages[index].data() as Map<String, dynamic>;
              final userMessage = messageData['message'] ?? '';
              final chatbotReply = messageData['reply'] ?? '';

              if (userMessage.isNotEmpty) {
                _addToGoogleSheets(user.uid, 'chat');
              }
              if (chatbotReply.isNotEmpty) {
                _addToGoogleSheets(user.uid, 'chat');
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (userMessage.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: Text(
                            'You',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: screenWidth * 0.6, // Limit width to 60% of screen
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.blue[100],
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              userMessage,
                              style: const TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                  if (chatbotReply.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Text(
                            'Bot',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: screenWidth * 0.6, // Limit width to 60% of screen
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 5),
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.green[100],
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              chatbotReply,
                              style: const TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}