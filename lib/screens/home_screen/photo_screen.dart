// import 'package:chronogram/login/login_helper/aseet_helper.dart';
// import 'package:flutter/material.dart';

// class PhotoScreen extends StatefulWidget {
//   const PhotoScreen({super.key});

//   @override
//   State<PhotoScreen> createState() => _PhotoScreenState();
// }

// class _PhotoScreenState extends State<PhotoScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         height: double.maxFinite,
//         width: double.maxFinite,
//         decoration: BoxDecoration(
//           image: DecorationImage(
//             image: AssetImage(ScreenImage.loginBg),
//             fit: BoxFit.cover,
//           ),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(18.0),
//           child: ListView.separated(
//             shrinkWrap: true,
//             itemBuilder: (context, index) {
//               return Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(10),
//                   color: Color(0XFFd97706),
//                 ),
//                 child: Center(
//                   child: Padding(
//                     padding: const EdgeInsets.fromLTRB(18, 25, 18, 25),
//                     child: Text(
//                       'Chronogram',
//                       style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ),
//               );
//             },
//             separatorBuilder: (context, index) =>
//                 Divider(color: Colors.transparent),
//             itemCount: 4,
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class PhotoScreen extends StatefulWidget {
  const PhotoScreen({super.key});

  @override
  State<PhotoScreen> createState() => _PhotoScreenState();
}

class _PhotoScreenState extends State<PhotoScreen> {
  List<Map<String, dynamic>> photoList = [{}];
  @override
  Widget build(BuildContext context) {
   
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// 🔥 Responsive Grid
            GridView.builder(
              itemCount: photoList.length,
              shrinkWrap: true,
              //  physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              //  childAspectRatio: cardSize / (cardSize * 1.1),
              ),
              itemBuilder: (context, index) {
                return photoCard(context, index);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 🔥 Responsive Photo Card
  Widget photoCard(BuildContext context, int index) {
    final size = MediaQuery.of(context).size;

    return Container(
      decoration: BoxDecoration(
        // borderRadius: BorderRadius.circular(0),
        gradient: const LinearGradient(
          colors: [Color(0xff2A1A0A), Color(0xff3B260D), Color(0xff2A1A0A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white12),
      ),
    );
  }
}
