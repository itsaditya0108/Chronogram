import 'package:chronogram/home_screen/chat_screen.dart';
import 'package:chronogram/home_screen/photo_screen.dart';
import 'package:chronogram/home_screen/profile_screen.dart';
import 'package:chronogram/home_screen/video_screen.dart';
import 'package:chronogram/login/login_helper/aseet_helper.dart';
import 'package:chronogram/login/login_provider/login_screen_provider.dart';
import 'package:chronogram/login/login_screen/login_screen.dart';
import 'package:chronogram/sign_up/sign_up_screen/sign_up_email_screen.dart';
import 'package:chronogram/sign_up/sign_up_provider/sign_up_screen_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0; // important
  
  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
    PhotoScreen(),
    VideoScreen(),
    ChatScreen(),
    ProfileScreen(),
    ];
    return Scaffold(

      //safe body
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ), // important

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index; // Tab Cahnge
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white.withOpacity(0.8),
        selectedItemColor: Color(0XFFd97706),
        unselectedItemColor: Colors.black54,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.photo), label: 'Photos'),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_collection),
            label: 'Videos',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
