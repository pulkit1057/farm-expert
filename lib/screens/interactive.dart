import 'package:crop_desease_detection/widgets/chat_messages.dart';
import 'package:crop_desease_detection/widgets/new_message.dart';
import 'package:flutter/material.dart';

class InteractiveScreen extends StatefulWidget {
  const InteractiveScreen({super.key});

  @override
  State<InteractiveScreen> createState() {
    return _InteractiveScreenState();
  }
}

class _InteractiveScreenState extends State<InteractiveScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farm Expert'),
      ),
      body: const Column(
        children: [
          Expanded(
            child: ChatMessages(),
          ),
          NewMessage(),
        ],
      ),
    );
  }
}
