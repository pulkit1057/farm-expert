import 'package:crop_desease_detection/screens/chat.dart';
import 'package:crop_desease_detection/screens/interactive.dart';
import 'package:crop_desease_detection/screens/user_profile.dart';
import 'package:flutter/material.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() {
    return _TabsScreenState();
  }
}

class _TabsScreenState extends State<TabsScreen> {
  int _selectedPageIndex = 0;

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget _activePage = const ChatScreen();

    if (_selectedPageIndex == 1) {
      _activePage = const InteractiveScreen();
    } else if (_selectedPageIndex == 2) {
      _activePage = const UserProfileScreen();
    }
    return Scaffold(
      // appBar: AppBar(
      //   title: const Text('Farm Expert'),
      // ),
      body: _activePage,
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectPage,
        currentIndex: _selectedPageIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.camera),
            label: 'Image',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
