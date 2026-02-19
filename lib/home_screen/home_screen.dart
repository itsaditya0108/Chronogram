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

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   int currentIndex = 0; // important
  
//   @override
//   Widget build(BuildContext context) {
//     final List<Widget> pages = [
//     PhotoScreen(),
//     VideoScreen(),
//     ChatScreen(),
//     ProfileScreen(),
//     ];
//     return Scaffold(

//       //safe body
//       body: IndexedStack(
//         index: currentIndex,
//         children: pages,
//       ), // important

//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: currentIndex,
//         onTap: (index) {
//           setState(() {
//             currentIndex = index; // Tab Cahnge
//           });
//         },
//         type: BottomNavigationBarType.fixed,
//         backgroundColor: Colors.white.withOpacity(0.8),
//         selectedItemColor: Color(0XFFd97706),
//         unselectedItemColor: Colors.black54,
//         showSelectedLabels: true,
//         showUnselectedLabels: true,
//         items: [
//           BottomNavigationBarItem(icon: Icon(Icons.photo), label: 'Photos'),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.video_collection),
//             label: 'Videos',
//           ),
//           BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
//           BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
//         ],
//       ),
//     );
//   }
// }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {

  int currentIndex = 0;

  late AnimationController glowController;

  @override
  void initState() {
    super.initState();

    glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {

    final List<Widget> pages = [
      PhotoScreen(),
      VideoScreen(),
      ChatScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.black,

      body: SafeArea(
        child: Column(
          children: [

            /// 🔥 HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Row(
                children: [

                  /// profile glow
                  AnimatedBuilder(
                    animation: glowController,
                    builder: (context, child) {
                      return Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xffFF8C00),
                              Color(0xffFF5E00),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xffFF8C00)
                                  .withOpacity(0.6),
                              blurRadius: 20,
                            )
                          ],
                        ),
                        padding: const EdgeInsets.all(2),
                        child: Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xff1C1C1E),
                          ),
                          child: const Center(
                            child: Icon(Icons.person,
                                color: Colors.white, size: 20),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(width: 12),

                  /// welcome text
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Welcome back",
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        "Chronogram User",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  /// online dot
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  )
                ],
              ),
            ),

            /// PAGES
            Expanded(
              child: IndexedStack(
                index: currentIndex,
                children: pages,
              ),
            ),
          ],
        ),
      ),

      /// 🔥 PREMIUM BOTTOM NAV
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xff111111),
          border: Border(
            top: BorderSide(color: Colors.white12),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                navItem(Icons.photo, "Photos", 0),
                navItem(Icons.play_circle, "Videos", 1),
                navItem(Icons.chat, "Chat", 2),
                navItem(Icons.person, "Profile", 3),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// NAV ITEM
  Widget navItem(IconData icon, String label, int index) {
    bool active = currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() => currentIndex = index);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active
                  ? const Color(0xffFF8C00).withOpacity(.15)
                  : Colors.transparent,
            ),
            child: Icon(
              icon,
              color: active ? const Color(0xffFF8C00) : Colors.grey,
              size: 24,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            label,
            style: TextStyle(
              color: active ? const Color(0xffFF8C00) : Colors.grey,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    glowController.dispose();
    super.dispose();
  }
}

