import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crop_desease_detection/widgets/send_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:crop_desease_detection/screens/helper.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  File? _selectedImage;
  // final _spreadsheetId = 'your_spreadsheet_id';
  final _googleSheetsHelper = GoogleSheetsHelper('1PMHGHpgZhec6-Q39N0JKVl3kyDSk_LFucsD2KIdIzX8');

  void _submit() async {
    if (_selectedImage == null) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser!;
    final userData = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final storageRef = FirebaseStorage.instance
        .ref()
        .child('crop_photo')
        .child('${user.uid}${Timestamp.now()}.jpg');
    await storageRef.putFile(_selectedImage!);
    final imageUrl = await storageRef.getDownloadURL();

    // Update the main document in the user_data collection
    await FirebaseFirestore.instance.collection('user_data').doc(user.uid).set({
      'username': userData.data()!['username'],
      'email': userData.data()!['email'],
    });

    // Add a new document to the images subcollection
    await FirebaseFirestore.instance
        .collection('user_data')
        .doc(user.uid)
        .collection('images')
        .add({
      'imageUrl': imageUrl,
      'createdAt': Timestamp.now(),
      'label': '',
      'advice': '',
    });

    // Append data to Google Sheets
    await _googleSheetsHelper.appendRow([
      user.uid,
      'image',
    ]);

    // Clear the selected image after submitting
    setState(() {
      _selectedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Farm Expert'),
        actions: [
          IconButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            icon: const Icon(Icons.exit_to_app),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('user_data')
                  .doc(user.uid)
                  .collection('images')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (ctx, AsyncSnapshot<QuerySnapshot> chatSnapshots) {
                if (chatSnapshots.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!chatSnapshots.hasData ||
                    chatSnapshots.data!.docs.isEmpty) {
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
                  reverse: true,
                  padding: const EdgeInsets.all(
                      10), // Add padding around the ListView
                  itemCount: loadedMessages.length,
                  itemBuilder: (ctx, index) {
                    final messageData =
                        loadedMessages[index].data() as Map<String, dynamic>;
                    final imageUrl = messageData['imageUrl'] ?? '';
                    final label = messageData['label'] ?? 'No label';
                    final advice = messageData['advice'] ?? 'No advice';

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Display the image and "You" text
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.5,
                                height: MediaQuery.of(context).size.width * 0.5,
                                margin: const EdgeInsets.only(top: 4.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Label Chat Bubble
                            const Text(
                              'Label',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            Container(
                              constraints: BoxConstraints(
                                maxWidth: screenWidth *
                                    0.6, // Limit width to 60% of screen
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 14),
                              margin: const EdgeInsets.only(top: 4.0),
                              decoration: BoxDecoration(
                                color: Colors.green[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                label,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Advice Chat Bubble
                            const Text(
                              'Remedy',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            Container(
                              constraints: BoxConstraints(
                                maxWidth: screenWidth *
                                    0.6, // Limit width to 60% of screen
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 10, horizontal: 14),
                              margin: const EdgeInsets.only(top: 4.0),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                advice,
                                style: const TextStyle(fontSize: 16),
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
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                SendImage(
                  selectedImage: _selectedImage,
                  onPickImage: (pickedImage) {
                    setState(() {
                      _selectedImage = pickedImage;
                    });
                  },
                ),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                  ),
                  child: const Text('Send'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}