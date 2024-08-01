import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Handle the case where the user is not authenticated
      return Scaffold(
        appBar: AppBar(
          title: const Text('User Profile'),
        ),
        body: const Center(
          child: Text('No user is currently logged in.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text('No user data found.'),
            );
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Display profile picture
                  CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.grey,
                    backgroundImage: userData['imageUrl'] != null
                        ? NetworkImage(userData['imageUrl'])
                        : null,
                  ),
                  const SizedBox(height: 16),
                  // Display username
                  Text(
                    userData['username'] ?? 'Username not available',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Display email
                  Text(
                    userData['email'] ?? 'Email not available',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  // Add more user details if available
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}









// import 'package:flutter/material.dart';

// class UserProfileScreen extends StatelessWidget
// {
//   const UserProfileScreen ({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Farm Expert'),
//       ),
//       body:const SingleChildScrollView(
//         child: Center(
//           child: Column(
//             children: [
//               CircleAvatar(
//                 radius: 40,
//                 backgroundColor: Colors.grey,
//               ),
//               Text('Username')
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

