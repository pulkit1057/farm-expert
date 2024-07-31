import 'package:flutter/material.dart';

class UserProfileScreen extends StatelessWidget
{
  const UserProfileScreen ({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farm Expert'),
      ),
      body:const SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.grey,
              ),
              Text('Username')
            ],
          ),
        ),
      ),
    );
  }
}

